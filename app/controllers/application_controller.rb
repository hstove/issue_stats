class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  include ActionController::ImplicitRender

  protect_from_forgery with: :exception

  helper_method :report_path
  def report_path(report, type = "path")
    opts = report.param_opts
    send("repository_#{type}", (opts))
  end

  helper_method :report_url
  def report_url(report)
    report_path(report, "url")
  end
end
