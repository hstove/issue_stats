namespace :scrape do
  task languages: :environment do
    Report.languages.each do |language|
      ScrapeJob.enqueue "language:#{language}"
    end
  end
end