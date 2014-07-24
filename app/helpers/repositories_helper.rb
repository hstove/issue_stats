module RepositoriesHelper
  def response_distribution_chart report
    distro = report.basic_distribution
    categories = distro.keys.map do |tier|
      distance_of_time_in_words(tier)
    end

    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Distribution of Time to Close an Issue")
      f.series name: "Issues", data: distro.values
      f.xAxis categories: categories, labels: {rotation: -45, align: 'right'}

      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
      f.chart defaultSeriesType: "column"
      f.legend enabled: false
      f.labels style: {"font-size" => "10px"}
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
end
