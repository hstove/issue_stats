class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :report_path
  def report_path report, format="html", type="path"
    owner, repository = report.github_key.split("/")
    opts = {owner: owner, repository: repository}
    if format.to_s == "svg"
      send("badge_#{type}",  opts.merge(format: "svg"))
    else
      send("repository_#{type}", (opts))
    end
  end

  helper_method :report_url
  def report_url report, format="html"
    report_path(report, format, "url")
  end
end
