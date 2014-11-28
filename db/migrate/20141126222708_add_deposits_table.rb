class AddDepositsTable < ActiveRecord::Migration
  def up
    create_table "deposits", :force => true do |t|
      t.integer  "user_id"
      t.integer  "source_id"
      t.text     "uuid",                                             :null => false
      t.integer  "state"
      t.string   "state_event"
      t.text     "data",    limit: 16777215
      t.datetime "created_at",                                       :null => false
      t.datetime "updated_at",                                       :null => false
    end

    add_index "deposits", ["updated_at"]
  end

  def down
    drop_table :deposits
  end
end
