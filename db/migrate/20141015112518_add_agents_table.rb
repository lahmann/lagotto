class AddAgentsTable < ActiveRecord::Migration
  def up
    create_table "agents", :force => true do |t|
      t.string   "type",                                            :null => false
      t.string   "name",                                            :null => false
      t.string   "display_name",                                    :null => false
      t.boolean  "queueable",    :default => true
      t.integer  "state"
      t.string   "state_event"
      t.text     "config"
      t.integer  "group_id",                                        :null => false
      t.datetime "run_at",       :default => '1970-01-01 00:00:00', :null => false
      t.datetime "created_at",                                      :null => false
      t.datetime "updated_at",                                      :null => false
      t.datetime "cached_at",    :default => '1970-01-01 00:00:00', :null => false
    end
    remove_column :sources, :type
    remove_column :sources, :queueable
    remove_column :sources, :state_event
    remove_column :sources, :config
    remove_column :sources, :run_at
    rename_column :sources, :state, :active
    change_column :sources, :active, :boolean, default: false
  end

  def down
    #drop_table :agents
    add_column :sources, :type, :string, :null => false
    add_column :sources, :queueable, :boolean,    :default => true
    add_column :sources, :state_event, :string
    add_column :sources, :config, :text
    add_column :sources, :run_at, :datetime, :default => '1970-01-01 00:00:00', :null => false
    rename_column :sources, :active, :state
    change_column :sources, :state, :integer
  end
end
