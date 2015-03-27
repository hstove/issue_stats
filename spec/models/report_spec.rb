require 'rails_helper'

RSpec.describe Report, :type => :model do
  let(:report) { build :report }

  describe ".language" do
    it "should return nil languages with a specific key" do
      report = build :report, language: nil
      allow(report).to receive(:fetch_metadata).and_return(true)
      allow(report).to receive(:bootstrap_async).and_return(true)
      report.save
      found_report = Report.language(Report::NO_LANGUAGE_KEY).first
      expect(found_report).to eql(report)
    end

    it "should return results by language if specified", :vcr do
      report.save
      found_report = Report.language(report.language.downcase).first
      expect(found_report).to eql(report)
    end
  end

  describe ".languages" do
    it "should return the list of unique languages", :vcr do
      report.save
      create :report, github_key: "jcla1/gisp"
      langs = Report.languages
      expect(langs.size).to eql(2)
      expect(langs).to include("Ruby")
      expect(langs).to include("Go")
    end
  end

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

    context "with issues disabled", :vcr do
      subject { Report.from_key("git/git").issues_disabled }
      it { is_expected.to eql(true) }
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

    it "will create if not found" do
      expect(Report).to receive(:create).and_return(true)
      Report.from_key("blah/blah")
    end
  end

  describe "#bytes" do
    it "should return the right conversion from KB" do
      report.size = 10000
      bytes = report.size * 1000
      expect(report.bytes).to eql(bytes)
    end
    it "should return false unless it has size" do
      report.size = nil
      expect(report.bytes).to eql(nil)
    end
  end

  describe "#badge_url" do
    before :each do
      allow(report).to receive(:issue_close_time).and_return(30)
      allow(report).to receive(:pr_close_time).and_return(30)
    end
    subject { report.badge_url("pr") }

    it { is_expected.to include("pull%20requests") }
    it { is_expected.to include("brightgreen.svg") }

    context "issue" do
      subject { report.badge_url("issue") }
      it { is_expected.to include("issue") }
    end

    it "should include the right color" do
      allow(Issue).to receive(:duration_index).and_return(1)
      expect(report.badge_url('pr')).to include("green.svg")
      allow(Issue).to receive(:duration_index).and_return(11)
      expect(report.badge_url('pr')).to include("yellow.svg")
      expect(report.badge_url('issue')).to include("red.svg")
    end
  end

  describe "#param_opts" do
    subject { report.param_opts }
    it { is_expected.to eql({owner: "hstove", repository: "rbtc_arbitrage"}) }
  end
end
