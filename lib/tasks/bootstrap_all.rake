task bootstrap_all: :environment do
  Report.all.collect(&:bootstrap_async)
end