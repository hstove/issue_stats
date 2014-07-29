namespace :scrape do
  task all: :environment do
    Octokit.auto_paginate = true
    repos = GH.search_repositories "a", sort: "stars", per_page: 100
    ScrapeJob.enqueue "a"
    repos.items.each do |repo|
      puts "Scraping #{repo.full_name}"
      Report.from_key repo.full_name
    end
    Octokit.auto_paginate = false
  end
  task languages: :environment do
    Octokit.auto_paginate = true
    languages = Report.select(:language).map(&:language).uniq.compact
    languages[0..1].each do |language|
      ScrapeJob.enqueue "language:#{language}"
    end
    Octokit.auto_paginate = false
  end
end