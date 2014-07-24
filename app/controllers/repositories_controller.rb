class RepositoriesController < ApplicationController
  def show
    @github_key = "#{params[:owner]}/#{params[:repository]}"
    @report = Report.from_key @github_key
  end
end
