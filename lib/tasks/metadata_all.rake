task metadata_all: :environment do
  Report.all.each do |report|
    FetchMetadata.perform_later report.github_key
  end
end