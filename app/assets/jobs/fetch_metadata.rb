class FetchMetadata < ActiveJob::Base
  def perform(report_id)
    report = Report.find(report_id)
    report.fetch_metadata
    report.save!
  end
end