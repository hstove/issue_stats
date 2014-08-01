require 'rails_helper'

RSpec.describe RepositoriesHelper, :type => :helper, vcr: true do
  before(:each) do
    create :report, github_key: "cloudflare/redoctober"
    create :report, github_key: "youtube/vitess"
    create :report, github_key: "gin-gonic/gin"
    create :report, github_key: "fiorix/freegeoip"
  end
  include HighchartsHelper
  include LazyHighCharts::LayoutHelper

  let(:attrs) { { stars: "Stars", forks: "Forks" } }
  let(:request) { Hashie::Mash.new(headers: {})}

  describe "#analysis_chart" do
    subject { analysis_chart(attrs) }
    it { is_expected.to include("<script") }
    it { is_expected.to include("Stars") }
    it { is_expected.to include("Forks") }
  end

  describe "#language_chart" do
    subject { language_chart }
    it { is_expected.to include("<script") }
  end

  describe "#reponse_distribution_chart" do
    subject { response_distribution_chart(Report.from_key("cloudflare/redoctober")) }
    it { is_expected.to include("<script") }
  end
end
