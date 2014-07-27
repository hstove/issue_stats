module SortableHeadersHelper
  def sortable_header(attr, opts={})
    opts.symbolize_keys!
    opts[:attr] = attr
    opts[:title] ||= attr.titleize
    opts[:link_opts] ||= {}
    opts[:is_sorted] = params[:sortable_attr] == attr.to_s
    url = request.env['PATH_INFO']
    opts[:path] = Rails.application.routes.recognize_path(url)
    opts[:path][:sortable_attr] = attr
    current_direction = params[:sortable_direction]
    if opts[:is_sorted]
      opts[:sort_symbol] = sort_symbols[current_direction]
      (opposite = sort_symbols.keys).delete(current_direction)
      opts[:path][:sortable_direction] = opposite[0]
    else
      opts[:path][:sortable_direction] = "DESC"
      opts[:sort_symbol] = sort_symbols["DESC"]
    end

    render partial: "sortable/header", locals: opts
  end

  private

  def sort_symbols
    {
      "DESC" => "\u25B2",
      "ASC" => "\u25BC"
    }
  end
end