task bootstrap_all: :environment do
  Report.all.each do |report|
    report.bootstrap_async
  end
end
