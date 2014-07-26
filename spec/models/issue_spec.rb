require 'rails_helper'

RSpec.describe Issue, type: :model do
  describe "#duration_tier" do
    it "should fit into the right tier" do
      duration = Issue.duration_tiers[1] - 1.minute
      issue = Issue.new(
        created_at: 1.minute.ago - duration,
        closed_at: 1.minute.ago
      )
      expect(issue.duration_tier).to eql(Issue.duration_tiers[1])
    end
  end
end
