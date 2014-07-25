require 'rails_helper'

RSpec.describe RepositoriesController, :type => :controller do

  describe "GET show" do
    it "returns http success", :vcr do
      get :show, owner: "hstove", repository: "rbtc_arbitrage"
      expect(response).to be_success
    end
  end

end
