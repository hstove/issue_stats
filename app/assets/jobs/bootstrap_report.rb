class BootstrapReport < ActiveJob::Base
  def perform(report_id)
    Report.find(report_id).bootstrap
  end
end