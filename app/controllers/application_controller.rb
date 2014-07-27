class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :report_path
  def report_path report, *args
    owner, repository = report.github_key.split("/")
    repository_path(owner: owner, repository: repository)
  end
end
