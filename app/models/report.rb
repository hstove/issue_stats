require 'action_view'
include ActionView::Helpers::DateHelper
class Report < ActiveRecord::Base
  serialize :basic_distribution, Hash
  serialize :pr_distribution, Hash
  serialize :issues_distribution, Hash

  before_create :fetch_metadata
  after_create :bootstrap_async

  NO_LANGUAGE_KEY = "__no_language__"

  scope :ready, -> { where("pr_close_time > 0 and issue_close_time > 0") }
  scope :with_issues, -> { where("issues_count > 25") }
  scope :language, -> language {
    if language == NO_LANGUAGE_KEY
      where("language is null")
    else
      where("lower(language) = ?", language.downcase)
    end
  }

  class << self
    def from_key key
      attrs = {github_key: key}
      if report = find_by(attrs)
        if !report.ready? && !report.last_enqueued_at
          report.fetch_metadata
          report.bootstrap_async
        end
      else
        report = create(attrs)
      end
      report
    end

    def languages
      select(:language).map(&:language).uniq.compact.sort
    end
  end

  def bootstrap_async
    self.last_enqueued_at = DateTime.now
    save!
    BootstrapReport.perform_later github_key
  end

  def bootstrap
    day_split = 8.0
    setup_distributions
    self.issues_count = 0
    durations = []
    issue_durations = []
    pr_durations = []
    _self = self
    issues do |issue|
      durations << issue.duration
      _self.issues_count += 1
      tier = issue.duration_tier
      _self.basic_distribution[tier] += 1
      if issue.pull_request
        pr_durations << issue.duration
        _self.pr_distribution[tier] += 1
      else
        issue_durations << issue.duration
        _self.issues_distribution[tier] += 1
      end
    end
    self.issues_count = _self.issues_count
    self.basic_distribution = _self.basic_distribution
    self.pr_distribution = _self.pr_distribution
    self.issues_distribution = _self.issues_distribution
    self.median_close_time = durations.median
    self.pr_close_time = pr_durations.median
    self.issue_close_time = issue_durations.median
    self.last_enqueued_at = nil
    save!
  end

  def issues &block
    Issue.find(github_key, {state: 'closed'}, block)
  end

  def ready?
    !!pr_close_time || !!issue_close_time
  end

  def setup_distributions
    hash = Hash.new(0)
    self.basic_distribution = hash.clone
    self.pr_distribution = hash.clone
    self.issues_distribution = hash.clone
    Issue.duration_tiers.each do |tier|
      basic_distribution[tier] = 0
      pr_distribution[tier] = 0
      issues_distribution[tier] = 0
    end
  end

  def distribution(type, tier)
    hash = send("#{type}_distribution")
    hash[tier.to_i] || hash[tier]
  end

  def fetch_metadata
    repository = GH.repo github_key # ensure repo exists
    self.issues_disabled = !repository.has_issues
    metadata_attrs.each do |attr|
      send("#{attr}=", repository.send(attr))
    end
  end

  def stars; stargazers_count; end
  def forks; forks_count; end

  def bytes
    size && size * 1000
  end

  # variant is either 'issue' or 'pr'
  def badge_url(variant, style: 'plastic', concise: false)
    preamble, words, color = badge_values(variant, concise)

    url = "https://img.shields.io/badge/#{URI.escape(preamble)}-"
    url << "#{URI.escape(words)}-#{color}.svg"
    url << "?style=#{style}" if style
    url
  end

  def param_opts
    owner, repository = github_key.split("/")
    { owner: owner, repository: repository }
  end

  def badge_preamble(variant, concise = false)
    badge_values(variant, concise)[0]
  end

  def badge_words(variant, concise = false)
    badge_values(variant, concise)[1]
  end

  def badge_color(variant, concise = false)
    badge_values(variant, concise)[2]
  end

  private

  # Returns [preable, words, color]
  def badge_values(variant, concise=false)
    duration = send("#{variant}_close_time")
    index = Issue.duration_index(duration)

    if variant == 'pr'
      word = concise ? "pull" : "pull requests"
      divisor = 3
    else
      word = concise ? "issue" : "issues"
      divisor = 2
    end
    if duration
      colors = %w(brightgreen green yellowgreen yellow orange red)
      color = colors[index / divisor] || colors.last
    else
      color = "red"
    end
    duration_in_words = time_in_words(duration, concise)
    suffix = concise ? "closure" : "closed in"
    ["#{word} #{suffix}", duration_in_words.downcase, color]
  end

  def metadata_attrs
    %i(open_issues_count stargazers_count forks_count size language description)
  end

  def time_in_words(duration, concise = false)
    if duration
      if concise
        concise_distance_of_time_in_words(duration)
      else
        distance_of_time_in_words(duration)
      end
    else
      "Not Available"
    end
  end

  # Get the approximate disntance of time in words from the given from_time
  # to the the given to_time. If to_time is not specified then it is set
  # to 0.
  # rubocop:disable Metrics/AbcSize
  def concise_distance_of_time_in_words(from_time, to_time = 0)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    from_time, to_time = to_time, from_time if from_time > to_time
    distance_in_min = ((to_time - from_time) / 60).round

    case distance_in_min
    when 0..44 then "#{distance_in_min} min"
    when 45..89 then '~1 hr'
    when 90..1439 then "#{(distance_in_min.to_f / 60.0).round} hrs"
    when 1440..2879 then '1 day'
    when 2880..43_199 then "#{(distance_in_min / 1440).round} days"
    when 43_200..525_959 then "#{(distance_in_min / 43_200).round} mon"
    when 525_960..788_940 then '~1 yr'
    else "> #{(distance_in_min / 525_960).round} yrs"
    end
  end
end
