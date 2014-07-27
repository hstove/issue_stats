class FetchMetadata < ActiveJob::Base
  def perform(report_key)
    report = Report.from_key(report_key)
    report.fetch_metadata
    report.save!
  end
end