require 'rails_helper'

RSpec.describe Report, :type => :model do
  describe "#bootstrap" do
    let(:report) { build :report }
    it "properly groups issues into their tier", :vcr do
      issue = Issue.new({
        created_at: 30.minutes.ago,
        closed_at: 10.minutes.ago
      })
      report.stub(:issues).and_return([issue])
      report.save
      first_tier = Issue.duration_tiers[0]
      report.basic_distribution[first_tier.to_i].should eql(1)
    end
  end
end
