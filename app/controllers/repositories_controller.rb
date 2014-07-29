class RepositoriesController < ApplicationController
  before_filter :fetch_report, only: [:show, :refresh, :badge]
  has_scope :language

  rescue_from Octokit::ClientError do
    if params["action"] == "badge"
      url = "http://img.shields.io/badge/Issue_Stats-Not_Found-lightgrey.svg"
      url << "?style=#{params[:style]}" if params[:style]
      redirect_to url
    else
      render "not_found"
    end
  end

  def index
    @reports = apply_scopes(Report).ready.paginate(page: params[:page])
    @reports = @reports.with_issues unless params[:language]
    @reports = apply_sort(@reports, default: {
      sortable_direction: "ASC",
      sortable_attr: "pr_close_time"
    })
  end

  def show
  end

  def analysis
  end

  def badge
    redirect_to @report.badge_url(params[:variant], params[:style])
  end

  def refresh
    @report.fetch_metadata
    @report.bootstrap_async
    render nothing: true
  end

  private

  def fetch_report
    @github_key = "#{params[:owner]}/#{params[:repository]}"
    @report = Report.from_key @github_key
  end

  def apply_sort(relation, opts={})
    (default = opts[:default] || {}).stringify_keys
    params.reverse_merge! default
    relation.order("#{params[:sortable_attr]} #{params[:sortable_direction]}")
  end

end
