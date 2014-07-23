class CreateAfterpartyJobs < ActiveRecord::Migration
  def self.up
    create_table :afterparty_jobs do |t|
      t.text :job_dump
      t.string :queue
      t.datetime :execute_at
      t.boolean :completed
      t.boolean :has_error
      t.text :error_message
      t.text :error_backtrace
      t.datetime :completed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :afterparty_jobs
  end

end
