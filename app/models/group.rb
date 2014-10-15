# encoding: UTF-8

class Group < ActiveRecord::Base
  has_many :sources, :order => "display_name", :dependent => :nullify
  has_many :agents, :order => "display_name", :dependent => :nullify

  validates :name, :presence => true, :uniqueness => true
  validates :display_name, :presence => true

  scope :active, joins(:sources).where("sources.active = ?", 1).order("groups.id")
  scope :visible, joins(:agents).where("agents.state > ?", 1).order("groups.id")
  scope :with_sources, joins(:sources).order("groups.id")
  scope :with_agents, joins(:agents).order("groups.id")
end
