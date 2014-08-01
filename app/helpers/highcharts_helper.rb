module HighchartsHelper
  def analysis_highchart(data, labels)
    id = labels.join(" vs. ")
    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.chart type: "scatter", zoomType: "xy"
      f.title text: id
      f.series name: labels[0], color: labels[1], data: data
      f.xAxis title: {text: labels[0]}, type: 'logarithmic'
      f.yAxis title: {text: labels[1]}, type: "logarithmic"
      f.legend enabled: false
    end
    high_chart(id.parameterize, chart)
  end

  def analysis_chart_data(keys)
    Rails.cache.fetch ["analysis_chart", *keys], expires_in: 1.hour do
      reports = analysis_reports
      reports.map do |report|
        {
          x: report.send(keys[0]),
          y: report.send(keys[1]),
          name: report.github_key
        }
      end
    end
  end

  def analysis_reports
    Rails.cache.fetch "analysis_reports_v1" do
      Report.ready
        .with_issues
        .where("stargazers_count > 0")
        .where("forks_count > 0")
        .where("size > 0")
        .limit(1000)
        .order("RANDOM()")
    end
  end

  def language_highchart(pr_values, issues_values, languages)
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Responsiveness by Language")
      f.series name: "Pull Requests", data: pr_values
      f.series name: "Issues", data: issues_values
      f.series(
        name: "Number of Repositories Analyzed",
        data: languages.map{|pair| pair.last.size},
        yAxis: 1,
        stack: 1,
        visible: false,
      )
      f.xAxis categories: languages.map(&:first), labels: {rotation: -45, align: 'right'}
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
  end
end