module SortableHeadersHelper
  def sortable_header(attr, opts={})
    opts = default_sortable_opts(opts, attr)
    current_direction = params[:sortable_direction]
    if opts[:is_sorted]
      opts[:sort_symbol] = sort_symbols[current_direction]
      (opposite = sort_symbols.keys).delete(current_direction)
      opts[:path][:sortable_direction] = opposite[0]
    else
      opts[:path][:sortable_direction] = "ASC"
      opts[:sort_symbol] = sort_symbols["ASC"]
    end

    render partial: "sortable/header", locals: opts
  end

  private

  def default_sortable_opts(opts, attr)
    opts.symbolize_keys!
    opts[:attr] = attr
    opts[:title] ||= attr.to_s.titleize
    opts[:link_opts] ||= {}
    opts[:link_opts].merge class: "sortable-header"
    opts[:is_sorted] = params[:sortable_attr] == attr.to_s
    url = request.env['PATH_INFO']
    opts[:path] = Rails.application.routes.recognize_path(url)
    opts[:path].merge! params
    opts[:path].delete("page")
    opts[:path][:sortable_attr] = attr
    opts
  end

  def sort_symbols
    {
      "DESC" => "\u25B2",
      "ASC" => "\u25BC"
    }
  end
end