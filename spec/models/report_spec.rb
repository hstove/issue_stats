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
      expect(report.issue_close_time).to eql(issue.duration.to_i)
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
      expect(report.pr_close_time).to eql(issue.duration.to_i)
    end

    it "properly groups massive durations into the last tier", :vcr do
      last_tier = Issue.duration_tiers.last
      issue.created_at -= (last_tier * 2)
      allow_any_instance_of(Report).to receive(:issues).and_yield(issue) { }
      report.save
      report.reload
      expect(report.distribution(:basic, last_tier)).to eql(1)
      expect(report.distribution(:issues, last_tier)).to eql(1)
    end
  end

  describe "#after_create" do
    it "should fetch repo metadata", :vcr do
      report.github_key = "rubymotion/bubblewrap"
      allow(report).to receive(:bootstrap_async).and_return(nil)
      report.save
      report.reload
      expect(report.stargazers_count).to eql 1145
      expect(report.forks_count).to eql 207
      expect(report.open_issues_count).to eql 17
      expect(report.size).to eql 4200
      description = "Cocoa wrappers and helpers for RubyMotion (Ruby for iOS "
      description << "and OS X) - Making Cocoa APIs more Ruby like, one API at "
      description << "a time. Fork away and send your pull requests"
      expect(report.description).to eql description
      expect(report.language).to eql 'Ruby'
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

  describe ".from_key" do
    it "will not refresh a non-ready report if found with last_enqueued_at" do
      allow(report).to receive(:ready?).and_return(false)
      report.last_enqueued_at = DateTime.now
      allow(Report).to receive(:find_by).and_return(report)
      expect(report).not_to receive(:bootstrap_async)
      expect(report).not_to receive(:fetch_metadata)
      Report.from_key("blah/blah")
    end

    it "will refresh a non-ready report if found" do
      allow(report).to receive(:ready?).and_return(false)
      allow(Report).to receive(:find_by).and_return(report)
      expect(report).to receive(:bootstrap_async)
      expect(report).to receive(:fetch_metadata)
      Report.from_key("blah/blah")
    end
  end
end
