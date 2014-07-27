task bootstrap_all: :environment do
  Report.all.each do |report|
    report.bootstrap_async
  end
end

task metadata_all: :environment do
  Report.all.each do |report|
    FetchMetadata.enqueue report.github_key
  end
end