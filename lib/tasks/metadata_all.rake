task metadata_all: :environment do
  Report.all.each do |report|
    FetchMetadata.enqueue report.github_key
  end
end