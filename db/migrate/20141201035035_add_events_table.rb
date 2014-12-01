class AddEventsTable < ActiveRecord::Migration
  def up
    create_table "events", :force => true do |t|
      t.integer  "work_id",                                          null: false
      t.integer  "source_id",                                        null: false
      t.text     "title",                                            null: false
      t.text     "container_title"
      t.text     "author"
      t.string   "doi"
      t.text     "url",                                              null: false
      t.date     "published_on",                                     null: false
      t.integer  "year",                     default: 1970
      t.integer  "month"
      t.integer  "day"
      t.string   "type"
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "histories", :force => true do |t|
      t.integer  "work_id",                                          null: false
      t.integer  "source_id",                                        null: false
      t.integer  "trace_id",                                         null: false
      t.integer  "year",                                             null: false
      t.integer  "month",                                            null: false
      t.integer  "total_count",              default: 0,             null: false
      t.integer  "html_count"
      t.integer  "pdf_count"
      t.integer  "comments_count"
      t.integer  "likes_count"
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    add_index "events", ["work_id", "source_id", "published_on"]
    add_index "histories", ["work_id", "source_id", "year", "month"]
  end

  def down
    drop_table :events
    drop_table :histories
  end
end
