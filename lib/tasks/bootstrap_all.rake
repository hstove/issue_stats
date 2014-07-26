task bootstrap_all: :environment do
  Report.all.each do |report|
    puts "Queueing @#{report.github_key}"
    report.bootstrap_async
  end
end