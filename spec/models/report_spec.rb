require 'rails_helper'

RSpec.describe Report, :type => :model do
  let(:report) { build :report }
  describe "#bootstrap" do
    let(:issue) do
      Issue.new(
        created_at: 30.minutes.ago,
        closed_at: 10.minutes.ago
      )
    end
    it "properly groups issues into their tier", :vcr do
      allow_any_instance_of(Report).to receive(:issues).and_yield(issue) { }
      report.save
      report.reload
      first_tier = Issue.duration_tiers[0]
      expect(report.distribution(:basic, first_tier)).to eql(1)
      expect(report.distribution(:issues, first_tier)).to eql(1)
      expect(report.distribution(:pr, first_tier)).to eql(0)
    end

    it "saves pull_requests into their own distribution", :vcr do
      issue.pull_request = {}
      allow_any_instance_of(Report).to receive(:issues).and_yield(issue) { }
      report.save
      report.reload
      first_tier = Issue.duration_tiers[0]
      expect(report.distribution(:basic, first_tier)).to eql(1)
      expect(report.distribution(:issues, first_tier)).to eql(0)
      expect(report.distribution(:pr, first_tier)).to eql(1)
    end
  end

  describe "#setup_distributions" do
    it "sets up blank hashes properly" do
      report.setup_distributions
      %w(pr basic issues).each do |prefix|
        keys = report.send("#{prefix}_distribution".to_sym).keys
        expect(keys).to eql Issue.duration_tiers
      end
    end
  end
end
