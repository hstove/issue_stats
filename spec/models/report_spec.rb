require 'rails_helper'

RSpec.describe Report, :type => :model do
  describe "#bootstrap" do
    let(:report) { build :report }
    let(:issue) {
      Issue.new({
        created_at: 30.minutes.ago,
        closed_at: 10.minutes.ago
      })
    }
    it "properly groups issues into their tier", :vcr do
      allow(report).to receive(:issues).and_return([issue])
      report.save
      first_tier = Issue.duration_tiers[0]
      expect(report.basic_distribution[first_tier.to_i]).to eql(1)
      expect(report.issues_distribution[first_tier.to_i]).to eql(1)
      expect(report.pr_distribution[first_tier.to_i]).to eql(0)
    end

    it "saves pull_requests into their own distribution" do
      issue.pull_request = {}
      allow(report).to receive(:issues).and_return([issue])
      report.save
      first_tier = Issue.duration_tiers[0]
      expect(report.basic_distribution[first_tier.to_i]).to eql(1)
      expect(report.issues_distribution[first_tier.to_i]).to eql(0)
      expect(report.pr_distribution[first_tier.to_i]).to eql(1)
    end
  end
end
