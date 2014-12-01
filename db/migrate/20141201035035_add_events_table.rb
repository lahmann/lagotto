class AddEventsTable < ActiveRecord::Migration
  def up
    create_table "events", :force => true do |t|
      t.integer  "work_id",                                           :null => false
      t.integer  "source_id",                                         :null => false
      t.text     "title"
      t.text     "container-title"
      t.text     "author"
      t.string   "doi"
      t.text     "url"
      t.date     "published_on"
      t.string   "type"
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    create_table "histories", :force => true do |t|
      t.integer  "work_id",                                          :null => false
      t.integer  "source_id",                                        :null => false
      t.integer  "trace_id",                                         :null => false
      t.integer  "year"
      t.integer  "month"
      t.integer  "total_count"
      t.integer  "html_count"
      t.integer  "pdf_count"
      t.integer  "comments_count"
      t.integer  "likes_count"
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    add_index "events", ["work_id", "source_id", "published_on"]
    add_index "histories", ["work_id", "source_id", "year", "month"]
  end

  def down
    drop_table :events
    drop_table :histories
  end
end
