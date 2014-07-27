task scrape: :environment do
  repos = GH.search_repositories "a", sort: "stars", per_page: 100, page: 1
  repos.items.each do |repo|
    puts "Scraping #{repo.full_name}"
    Report.from_key repo.full_name
  end
end