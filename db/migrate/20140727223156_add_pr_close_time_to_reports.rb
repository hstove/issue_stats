class AddPrCloseTimeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :pr_close_time, :integer
    add_column :reports, :issue_close_time, :integer
  end
end
