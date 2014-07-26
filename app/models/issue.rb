class Issue < Hashie::Mash
  class << self
    def find key, opts={}
      issues = GH.issues key, opts
      issues.map do |pr|
        self.new pr.to_hash
      end
    end

    def duration_tiers
      [1.hour] + (1..10).map do |n|
        (3 ** n).hours
      end.map(&:to_i)
    end
  end

  def duration
    if closed_at and created_at
      closed_at - created_at
    else
      0
    end
  end

  def duration_tier
    self.class.duration_tiers.each_with_index do |tier, index|
      last_tier = index == 0 ? 0 : Issue.duration_tiers[index - 1]
      if (duration <= tier) && (duration > last_tier)
        return tier
      end
    end
  end
end