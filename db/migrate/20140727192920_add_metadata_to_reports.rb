class AddMetadataToReports < ActiveRecord::Migration
  def change
    add_column :reports, :open_issues_count, :integer
    add_column :reports, :description, :string
    add_column :reports, :language, :string
    add_column :reports, :forks_count, :integer
    add_column :reports, :stargazers_count, :integer
    add_column :reports, :size, :integer
  end
end
