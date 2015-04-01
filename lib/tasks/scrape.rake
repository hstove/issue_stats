namespace :scrape do
  task languages: :environment do
    Report.languages.each do |language|
      ScrapeJob.perform_later "language:#{language}"
    end
  end
end