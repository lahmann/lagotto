class AddTasksTable < ActiveRecord::Migration
  def up
    rename_table :retrieval_statuses, :traces
    remove_column :traces, :queued_at
    remove_column :traces, :scheduled_at

    create_table "tasks", :force => true do |t|
      t.integer  "agent_id",                                         :null => false
      t.integer  "article_id"
      t.integer  "publisher_id"
      t.text     "config"
      t.datetime "queued_at",     :default => '1970-01-01 00:00:00', :null => false
      t.datetime "retrieved_at",  :default => '1970-01-01 00:00:00', :null => false
      t.datetime "scheduled_at",  :default => '1970-01-01 00:00:00', :null => false
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    add_index "tasks", ["agent_id", "article_id"], :unique => true
    add_index "tasks", ["agent_id"]
    add_index "tasks", ["article_id"]
  end

  def down
    rename_table :traces, :retrieval_statuses
    add_column :retrieval_statuses, :queued_at, :datetime
    add_column :retrieval_statuses, :scheduled_at, :datetime

    drop_table :tasks
  end
end
