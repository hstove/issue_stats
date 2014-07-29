class ScrapeJob < ActiveJob::Base
  def perform(search_key)
    repos = GH.search_repositories search_key,
      sort: :stars,
      per_page: 100,
      page: 1
    repos.items.each do |repo|
      Report.from_key repo.full_name
    end
  end
end