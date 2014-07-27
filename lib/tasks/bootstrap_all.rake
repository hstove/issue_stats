task bootstrap_all: :environment do
  Report.all.each do |report|
    puts "Queueing `#{report.github_key}`"
    report.bootstrap_async
  end
end

task metadata_all: :environment do
  Report.all.each do |report|
    puts "Fetching Metadata for `#{report.github_key}`"
    FetchMetadata.enqueue report.id
  end
end