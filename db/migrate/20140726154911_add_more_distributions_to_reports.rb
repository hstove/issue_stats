class AddMoreDistributionsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :pr_distribution, :text
    add_column :reports, :issues_distribution, :text
  end
end
