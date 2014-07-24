class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :github_key
      t.text :basic_distribution
      t.integer :github_stars

      t.timestamps
    end
  end
end
