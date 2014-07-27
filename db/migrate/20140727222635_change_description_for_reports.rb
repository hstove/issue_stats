class ChangeDescriptionForReports < ActiveRecord::Migration
  def change
    change_column :reports, :description, :text
  end
end
