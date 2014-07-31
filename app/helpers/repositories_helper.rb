module RepositoriesHelper
  def response_distribution_chart report
    categories = Issue.duration_tiers.map do |tier|
      distance_of_time_in_words(tier)
    end

    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Distribution of Time to Close an Issue")
      # f.series name: "All Issues", data: report.basic_distribution.values
      f.series name: "Issues", data: report.issues_distribution.values
      f.series name: "Pull Requests", data: report.pr_distribution.values
      f.xAxis categories: categories, labels: {rotation: -45, align: 'right'}

      f.legend(align: 'right', verticalAlign: 'top', floating: true)
      f.chart defaultSeriesType: "column"
      f.labels style: {"font-size" => "10px"}
      f.plotOptions column: { stacking: 'normal' }
    end

    high_chart "repository-issue-distribution", chart
  end

  def duration_with_style duration
    variant = "label" # "text"
    if duration < 1.day
      style = "pull-right #{variant} #{variant}-success"
    elsif duration < 5.days
      style = "pull-right #{variant} #{variant}-info"
    elsif duration < 15.days
      style = "pull-right #{variant} #{variant}-warning"
    elsif duration < 30.days
      style = "pull-right #{variant} #{variant}-danger"
    end
    content_tag :span, class: style do
      distance_of_time_in_words(duration).titleize + " to Close an Issue"
    end
  end

  def badge_color(report)
    index = report.duration_index
    colors = %w(#00bc8c #3498DB #AC6900 #E74C3C)
    colors[index / 2] || colors.last
  end

  def analysis_chart attrs
    keys = attrs.keys
    values = attrs.values

    data = Rails.cache.fetch ["analysis_chart", *attrs], expires_in: 1.hour do
      reports = Report.ready.with_issues
      reports.map do |report|
        {
          x: report.send(keys[0]),
          y: report.send(keys[1]),
          name: report.github_key
        }
      end
    end
    x = data.map { |d| d[:x] }
    y = data.map { |d| d[:y] }
    lineFit = LineFit.new
    lineFit.setData(x, y)

    id = values.join(" vs. ")
    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart type: "scatter", zoomType: "xy"
      f.title text: id
      f.series name: values[0], color: values[1], data: data
      f.xAxis title: {text: values[0]}, type: 'logarithmic'
      f.yAxis title: {text: values[1]}, type: "logarithmic"
      f.legend enabled: false
    end

    content_tag :div, class: "analysis-chart well col-md-6" do
      html = high_chart(id.parameterize, chart)
      html += content_tag :p, class: 'text-center' do
        "r<sup>2</sup>: #{lineFit.rSquared.round(4)}".html_safe
      end
    end
  end

  def language_chart
    Rails.cache.fetch "analysis_language_chart", expires_in: 1.hour do
      reports = Report.ready
      pr_languages, issues_languages = Hash.new, Hash.new
      reports.each do |report|
        key = report.language || "No Language"
        issues_languages[key] ||= []
        pr_languages[key] ||= []
        issues_languages[key] << report.issue_close_time
        pr_languages[key] << report.pr_close_time
      end

      pr_languages = pr_languages.sort_by { |k,v| v.median }
      pr_values = pr_languages.map { |pair| pair.last.median }
      issues_languages = issues_languages.sort_by { |k,v| v.median }
      issues_values = issues_languages.map { |pair| pair.last.median }

      chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "Responsiveness by Language")
        f.series name: "Pull Requests", data: pr_values
        f.series name: "Issues", data: issues_values
        f.series(
          name: "Number of Repositories Analyzed",
          data: pr_languages.map{|pair| pair.last.size},
          yAxis: 1,
          stack: 1,
          visible: false,
        )
        f.xAxis categories: pr_languages.map(&:first), labels: {rotation: -45, align: 'right'}
        f.yAxis([
          {
            type: 'logarithmic',
            title: {
              text: "Seconds to Close an Issue"
            }
          },{
            type: 'logarithmic',
            opposite: true,
            title: { text: "Number of Repositories Analyzed" }
          }
        ])
        f.legend(align: 'right', verticalAlign: 'top', floating: true)
        f.chart defaultSeriesType: "column"
        f.labels style: {"font-size" => "10px"}
        f.plotOptions column: { stacking: 'normal' }
      end

      high_chart "language-chart", chart
    end
  end
end
