class RepositoriesController < ApplicationController
  def index
    @reports = apply_sort(Report, default: {
      sortable_direction: "ASC",
      sortable_attr: "median_close_time"
    })
  end

  def show
    @github_key = "#{params[:owner]}/#{params[:repository]}"
    @report = Report.from_key @github_key
  end

  private

  def apply_sort(relation, opts={})
    (default = opts[:default] || {}).stringify_keys
    params.reverse_merge! default
    relation.order("#{params[:sortable_attr]} #{params[:sortable_direction]}")
  end

end
