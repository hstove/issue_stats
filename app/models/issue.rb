class Issue < Hashie::Mash
  class << self
    def find key, opts={}, block
      GH.skinny("repos/#{key}/issues", opts) do |issues|
        issues.map do |pr|
          block.call self.new pr.to_hash
        end
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