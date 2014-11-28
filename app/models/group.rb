# encoding: UTF-8

class Group < ActiveRecord::Base
  has_many :sources, -> { order(:title) }, :dependent => :nullify
  has_many :agents, -> { order(:title) }, :dependent => :nullify

  validates :name, :presence => true, :uniqueness => true
  validates :title, :presence => true

  scope :active, -> { joins(:sources).where("sources.active = ?", 1).order("groups.id") }
  scope :visible, -> { joins(:agents).where("state > ?", 1).order("groups.id") }
  scope :with_sources, -> { joins(:sources).order("groups.id") }
  scope :with_agents, -> { joins(:agents).order("groups.id") }

  def to_param  # overridden, use name instead of id
    name
  end

  def update_date
    updated_at.utc.iso8601
  end
end
