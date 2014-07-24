class Report < ActiveRecord::Base
  serialize :basic_distribution, Hash

  class << self
    def from_key key
      report = self.find_or_create_by(github_key: key) do |r|
        r.bootstrap
      end
    end
  end

  def bootstrap
    day_split = 8.0
    distro = {}
    Issue.duration_tiers.each do |tier|
      distro[tier.to_i] = 0
    end
    self.issues_count = issues.size
    issues.each do |issue|
      duration = issue.duration
      Issue.duration_tiers.each_with_index do |tier, index|
        last_tier = Issue.duration_tiers[index-1] || 0
        if (duration <= tier) && (duration > last_tier)
          distro[tier.to_i] += 1
        end
      end
    end
    self.basic_distribution = distro
    self.median_close_time = issues.map(&:duration).median
    save!
  end

  def issues
    @issues ||= Issue.find github_key, state: 'closed'
  end
end
