json.github_key @report.github_key
json.github_stars @report.github_stars
json.created_at @report.created_at
json.updated_at @report.updated_at
json.median_close_time @report.median_close_time
json.issues_count @report.issues_count
json.basic_distribution @report.basic_distribution
json.pr_distribution @report.pr_distribution
json.issues_distribution @report.issues_distribution
json.last_enqueued_at @report.last_enqueued_at
json.issues_disabled @report.issues_disabled
json.open_issues_count @report.open_issues_count
json.description @report.description
json.language @report.language
json.forks_count @report.forks_count
json.stargazers_count @report.stargazers_count
json.size @report.size
json.pr_close_time @report.pr_close_time
json.issue_close_time @report.issue_close_time
json.pr_badge_preamble @report.badge_preamble('pr', params[:concise])
json.pr_badge_words @report.badge_words('pr', params[:concise])
json.pr_badge_color @report.badge_color('pr', params[:concise])
json.issue_badge_preamble @report.badge_preamble('issue', params[:concise])
json.issue_badge_words @report.badge_words('issue', params[:concise])
json.issue_badge_color @report.badge_color('issue', params[:concise])
