class RepositoriesController < ApplicationController
  before_filter :fetch_report, only: [:show, :refresh, :badge]
  has_scope :language

  rescue_from Octokit::ClientError, with: :not_found_badge

  def index
    @reports = apply_scopes(Report).ready.paginate(page: params[:page] || 1)
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
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    if variant
      redirect_to @report.badge_url(variant, style)
    else
      not_found_badge
    end
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

  def style
    _style = params[:style].to_s
    return nil unless ['flat'].include?(_style)
    _style
  end

  def variant
    _variant = params[:variant].to_s
    return nil unless ['pr','issue'].include?(_variant)
    _variant
  end

  def not_found_badge
    if params["action"] == "badge"
      url = "http://img.shields.io/badge/Issue_Stats-Not_Found-lightgrey.svg"
      url << "?style=#{style}" if style
      redirect_to url
    else
      render "not_found"
    end
  end

end
