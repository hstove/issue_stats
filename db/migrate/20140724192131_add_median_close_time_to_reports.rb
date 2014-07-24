class AddMedianCloseTimeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :median_close_time, :integer
    add_column :reports, :issues_count, :integer
  end
end
