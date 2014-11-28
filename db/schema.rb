# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141126222708) do

  create_table "agents", force: true do |t|
    t.string   "type",                                        null: false
    t.string   "name",                                        null: false
    t.string   "title",                                       null: false
    t.string   "kind",        default: "work"
    t.string   "source",                                      null: false
    t.integer  "state"
    t.string   "state_event"
    t.text     "config"
    t.integer  "group_id",                                    null: false
    t.datetime "run_at",      default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.datetime "cached_at",   default: '1970-01-01 00:00:00', null: false
  end

  create_table "api_requests", force: true do |t|
    t.string   "format"
    t.float    "db_duration",   limit: 24
    t.float    "view_duration", limit: 24
    t.datetime "created_at"
    t.string   "api_key"
    t.string   "info"
    t.string   "source"
    t.text     "ids"
  end

  add_index "api_requests", ["api_key", "created_at"], name: "index_api_requests_api_key_created_at", using: :btree
  add_index "api_requests", ["api_key"], name: "index_api_requests_on_api_key", using: :btree
  add_index "api_requests", ["created_at"], name: "index_api_requests_on_created_at", using: :btree

  create_table "api_responses", force: true do |t|
    t.integer  "work_id"
    t.integer  "agent_id"
    t.integer  "task_id"
    t.float    "duration",   limit: 24
    t.datetime "created_at"
    t.string   "status"
  end

  add_index "api_responses", ["created_at"], name: "index_api_responses_created_at", using: :btree

  create_table "changes", force: true do |t|
    t.integer  "work_id"
    t.integer  "source_id"
    t.integer  "trace_id"
    t.integer  "event_count"
    t.integer  "previous_count"
    t.datetime "created_at"
    t.integer  "update_interval"
    t.boolean  "unresolved",      default: true
    t.boolean  "skipped",         default: false
  end

  add_index "changes", ["created_at"], name: "index_changes_created_at", using: :btree
  add_index "changes", ["event_count"], name: "index_changes_on_event_count", using: :btree
  add_index "changes", ["unresolved", "id"], name: "index_changes_unresolved_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",                    default: 0
    t.integer  "attempts",                    default: 0
    t.text     "handler",    limit: 16777215
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_at", "locked_by", "failed_at"], name: "index_delayed_jobs_locked_at_locked_by_failed_at", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  add_index "delayed_jobs", ["queue"], name: "index_delayed_jobs_queue", using: :btree
  add_index "delayed_jobs", ["run_at", "locked_at", "locked_by", "failed_at", "priority"], name: "index_delayed_jobs_run_at_locked_at_failed_at_priority", using: :btree

  create_table "deposits", force: true do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.text     "uuid",                         null: false
    t.integer  "state"
    t.string   "state_event"
    t.text     "data",        limit: 16777215
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "deposits", ["updated_at"], name: "index_deposits_on_updated_at", using: :btree

  create_table "filters", force: true do |t|
    t.string   "type",                       null: false
    t.string   "name",                       null: false
    t.string   "title",                      null: false
    t.text     "description"
    t.boolean  "active",      default: true
    t.text     "config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "notifications", force: true do |t|
    t.integer  "source_id"
    t.string   "class_name"
    t.text     "message"
    t.text     "trace"
    t.string   "target_url",   limit: 1000
    t.string   "user_agent"
    t.integer  "status"
    t.string   "content_type"
    t.text     "details",      limit: 16777215
    t.boolean  "unresolved",                    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_ip"
    t.integer  "work_id"
    t.integer  "level",                         default: 3
    t.string   "hostname"
    t.integer  "agent_id"
  end

  add_index "notifications", ["class_name"], name: "index_notifications_on_class_name", using: :btree
  add_index "notifications", ["created_at"], name: "index_notifications_on_created_at", using: :btree
  add_index "notifications", ["level", "created_at"], name: "index_notifications_on_level_and_created_at", using: :btree
  add_index "notifications", ["source_id", "created_at"], name: "index_notifications_on_source_id_and_created_at", using: :btree
  add_index "notifications", ["source_id", "unresolved", "updated_at"], name: "index_notifications_on_source_id_and_unresolved_and_updated_at", using: :btree
  add_index "notifications", ["unresolved", "updated_at"], name: "index_notifications_on_unresolved_and_updated_at", using: :btree
  add_index "notifications", ["updated_at"], name: "index_notifications_on_updated_at", using: :btree
  add_index "notifications", ["work_id", "created_at"], name: "index_notifications_on_work_id_and_created_at", using: :btree

  create_table "publisher_options", force: true do |t|
    t.integer  "publisher_id"
    t.integer  "agent_id"
    t.string   "config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "publisher_options", ["publisher_id", "agent_id"], name: "index_publisher_options_on_publisher_id_and_agent_id", unique: true, using: :btree

  create_table "publishers", force: true do |t|
    t.string   "name"
    t.integer  "crossref_id"
    t.text     "prefixes"
    t.text     "other_names"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cached_at",   default: '1970-01-01 00:00:00', null: false
  end

  add_index "publishers", ["crossref_id"], name: "index_publishers_on_crossref_id", unique: true, using: :btree

  create_table "reports", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.text     "config"
    t.boolean  "private",     default: true
  end

  create_table "reports_users", id: false, force: true do |t|
    t.integer "report_id"
    t.integer "user_id"
  end

  add_index "reports_users", ["report_id", "user_id"], name: "index_reports_users_on_report_id_and_user_id", using: :btree
  add_index "reports_users", ["user_id"], name: "index_reports_users_on_user_id", using: :btree

  create_table "retrieval_histories", force: true do |t|
    t.integer  "trace_id",                 null: false
    t.integer  "work_id",                  null: false
    t.integer  "source_id",                null: false
    t.datetime "retrieved_at"
    t.string   "status"
    t.string   "msg"
    t.integer  "event_count",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "retrieval_histories", ["source_id", "status", "updated_at"], name: "index_retrieval_histories_on_source_id_and_status_and_updated", using: :btree
  add_index "retrieval_histories", ["trace_id", "retrieved_at"], name: "index_rh_on_id_and_retrieved_at", using: :btree

  create_table "reviews", force: true do |t|
    t.string   "name"
    t.integer  "state_id"
    t.text     "message"
    t.integer  "input"
    t.integer  "output"
    t.boolean  "unresolved", default: true
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
  end

  add_index "reviews", ["name"], name: "index_reviews_on_name", using: :btree
  add_index "reviews", ["state_id"], name: "index_reviews_on_state_id", using: :btree

  create_table "sources", force: true do |t|
    t.string   "name",                                        null: false
    t.string   "title",                                       null: false
    t.integer  "group_id",                                    null: false
    t.boolean  "private",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "active",      default: false
    t.datetime "cached_at",   default: '1970-01-01 00:00:00', null: false
  end

  add_index "sources", ["active"], name: "index_sources_on_active", using: :btree
  add_index "sources", ["name"], name: "index_sources_on_name", unique: true, using: :btree

  create_table "tasks", force: true do |t|
    t.integer  "agent_id",                                     null: false
    t.integer  "work_id"
    t.integer  "publisher_id"
    t.text     "config"
    t.datetime "queued_at",    default: '1970-01-01 00:00:00', null: false
    t.datetime "retrieved_at", default: '1970-01-01 00:00:00', null: false
    t.datetime "scheduled_at", default: '1970-01-01 00:00:00', null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "tasks", ["agent_id", "work_id"], name: "index_tasks_on_agent_id_and_work_id", unique: true, using: :btree
  add_index "tasks", ["agent_id"], name: "index_tasks_on_agent_id", using: :btree
  add_index "tasks", ["work_id"], name: "index_tasks_on_work_id", using: :btree

  create_table "traces", force: true do |t|
    t.integer  "work_id",                                       null: false
    t.integer  "source_id",                                     null: false
    t.datetime "retrieved_at",  default: '1970-01-01 00:00:00', null: false
    t.integer  "event_count",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "events_url"
    t.string   "event_metrics"
    t.text     "other"
  end

  add_index "traces", ["source_id", "event_count", "retrieved_at"], name: "index_retrieval_statuses_source_id_event_count_retr_at_desc", using: :btree
  add_index "traces", ["source_id", "event_count"], name: "index_retrieval_statuses_source_id_event_count_desc", using: :btree
  add_index "traces", ["source_id", "work_id", "event_count"], name: "index_retrieval_statuses_source_id_article_id_event_count_desc", using: :btree
  add_index "traces", ["source_id"], name: "index_rs_on_soure_id_queued_at_scheduled_at", using: :btree
  add_index "traces", ["source_id"], name: "index_traces_on_source_id", using: :btree
  add_index "traces", ["work_id", "event_count"], name: "index_traces_on_work_id_and_event_count", using: :btree
  add_index "traces", ["work_id", "source_id", "event_count"], name: "index_rs_on_article_id_soure_id_event_count", using: :btree
  add_index "traces", ["work_id", "source_id"], name: "index_traces_on_work_id_and_source_id", unique: true, using: :btree
  add_index "traces", ["work_id"], name: "index_traces_on_work_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "authentication_token"
    t.string   "role",                   default: "user"
    t.integer  "publisher_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_username", unique: true, using: :btree

  create_table "workers", force: true do |t|
    t.integer  "identifier", null: false
    t.string   "queue",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "works", force: true do |t|
    t.string   "doi"
    t.text     "title"
    t.date     "published_on"
    t.string   "pmid"
    t.string   "pmcid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "canonical_url"
    t.string   "mendeley_uuid"
    t.integer  "year",          default: 1970
    t.integer  "month"
    t.integer  "day"
    t.integer  "publisher_id"
  end

  add_index "works", ["doi", "published_on", "id"], name: "index_articles_doi_published_on_article_id", using: :btree
  add_index "works", ["doi"], name: "index_works_on_doi", unique: true, using: :btree
  add_index "works", ["published_on"], name: "index_works_on_published_on", using: :btree
  add_index "works", ["publisher_id", "published_on"], name: "index_works_on_publisher_id_and_published_on", using: :btree

end
