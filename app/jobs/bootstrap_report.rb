class BootstrapReport < ActiveJob::Base
  def perform(report_key)
    Report.from_key(report_key).bootstrap
  end
end