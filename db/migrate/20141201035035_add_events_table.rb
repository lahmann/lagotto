class AddEventsTable < ActiveRecord::Migration
  def up
    add_column :works, :pid_type, :string, null: false
    add_column :works, :pid, :string, null: false
    add_column :works, :container_title, :text
    add_column :works, :author, :text
    add_column :works, :volume, :string
    add_column :works, :issue, :string
    add_column :works, :page, :string
    add_column :works, :work_type_id, :integer
    add_column :works, :response_id, :integer

    remove_index "works", name: "index_articles_doi_published_on_article_id"
    remove_index "works", name: "index_works_on_doi"
    add_index "works", ["pid_type", "pid", "published_on"], unique: true

    create_table "identifiers", :force => true do |t|
      t.integer  "work_id"
      t.string   "identifier_type",                                  null: false
      t.text     "identifier",                                       null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "responses", :force => true do |t|
      t.text     "data", limit: 16777215
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "events", :force => true do |t|
      t.integer  "work_id",                                          null: false
      t.integer  "citation_id",                                      null: false
      t.integer  "source_id",                                        null: false
      t.integer  "relation_type_id",                                 null: false
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

    create_table "work_types", :force => true do |t|
      t.string  "name",                                              null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    create_table "relation_types", :force => true do |t|
      t.string  "name",                                              null: false
      t.datetime "created_at",                                       null: false
      t.datetime "updated_at",                                       null: false
    end

    add_index "histories", ["work_id", "source_id", "year", "month"]
  end

  def down
    drop_table :events
    drop_table :responses
    drop_table :identifiers
    drop_table :histories
    drop_table :work_types
    drop_table :relation_types

    remove_column :works, :pid_type
    remove_column :works, :pid
    remove_column :works, :container_title
    remove_column :works, :author
    remove_column :works, :volume
    remove_column :works, :issue
    remove_column :works, :page
    remove_column :works, :work_type_id
    remove_column :works, :response_id

    add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id"
    add_index "works", ["doi"], name: "index_works_on_doi", unique: true
    remove_index "works", name: "index_works_on_pid_type_and_pid_and_published_on"
  end
end
