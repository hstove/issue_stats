namespace :scrape do
  task languages: :environment do
    languages = Report.select(:language).map(&:language).uniq.compact
    languages.each do |language|
      ScrapeJob.enqueue "language:#{language}"
    end
  end
end