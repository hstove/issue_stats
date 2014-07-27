class MoreReportStats < ActiveRecord::Migration
  def change
    add_column :reports, :last_enqueued_at, :datetime
    add_column :reports, :issues_disabled, :boolean
  end
end
