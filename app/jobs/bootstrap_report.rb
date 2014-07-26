class BootstrapReport < ActiveJob::Base
  # queue_as :my_jobs

  def perform(report_id)
    Report.find(report_id).bootstrap
  end
end