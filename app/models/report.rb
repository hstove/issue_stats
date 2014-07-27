require 'action_view'
include ActionView::Helpers::DateHelper
class Report < ActiveRecord::Base
  serialize :basic_distribution, Hash
  serialize :pr_distribution, Hash
  serialize :issues_distribution, Hash

  before_create :fetch_metadata
  after_create :bootstrap_async

  scope :ready, -> { where("median_close_time is not null") }

  class << self
    def from_key key
      report = self.find_or_create_by(github_key: key)
    end
  end

  def bootstrap_async
    self.last_enqueued_at = DateTime.now
    save!
    BootstrapReport.enqueue id
  end

  def bootstrap
    day_split = 8.0
    setup_distributions
    self.issues_count = 0
    durations = []
    _self = self
    begin
      issues do |issue|
        durations << issue.duration
        _self.issues_count += 1
        tier = issue.duration_tier
        _self.basic_distribution[tier] += 1
        if issue.pull_request
          _self.pr_distribution[tier] += 1
        else
          _self.issues_distribution[tier] += 1
        end
      end
    rescue Octokit::ClientError
      self.issues_disabled = true
    end
    self.issues_count = _self.issues_count
    self.basic_distribution = _self.basic_distribution
    self.pr_distribution = _self.pr_distribution
    self.issues_distribution = _self.issues_distribution
    self.median_close_time = durations.median
    self.last_enqueued_at = nil
    save!
  end

  def issues &block
    Issue.find(github_key, {state: 'closed'}, block)
  end

  def ready?
    !!median_close_time
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
    send("#{type}_distribution")[tier.to_i]
  end

  def fetch_metadata
    repository = GH.repo github_key # ensure repo exists
    metadata_attrs.each do |attr|
      send("#{attr}=", repository.send(attr))
    end
  end

  def stars; stargazers_count; end
  def forks; forks_count; end
  def duration; median_close_time; end

  def bytes
    size && size * 1000
  end

  def duration_index
    Issue.duration_index(median_close_time)
  end

  def duration_in_words
    distance_of_time_in_words(duration)
  end

  def badge_url
    colors = %w(#00bc8c #3498DB #AC6900 #E74C3C)
    colors = %w(brightgreen green yellowgreen yellow orange red)
    color = colors[duration_index / 2] || colors.last

    url = "http://img.shields.io/badge/Issues%20Closed%20In-"
    url << "#{URI.escape(duration_in_words)}-#{color}.svg"
    url
  end

  private

  def metadata_attrs
    %i(open_issues_count stargazers_count forks_count size language description)
  end
end
