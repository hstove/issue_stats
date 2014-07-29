class ScrapeJob < ActiveJob::Base
  def perform(search_key, page = nil)
    puts "ScrapeJob - #{search_key} - page:#{page}"
    if page
      repos = GH.search_repositories search_key,
        sort: :stars,
        per_page: 100,
        page: page
      repos.items.each do |repo|
        Report.from_key repo.full_name
      end
    else
      (1...10).map { |n| self.class.enqueue search_key, n}
    end
  end
end