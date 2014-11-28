# encoding: UTF-8

class Doc
  attr_reader :id, :title, :layout, :content, :content_list, :updated_at, :update_date, :cache_key

  DOCUMENTS = %w(Installation Deployment Setup Agents API Rake Alerts Releases Roadmap Contributors)

  def self.files
    Dir.entries(Rails.root.join("docs"))
  end

  def self.find(param)
    name = param.downcase
    match = files.find { |doc| doc.downcase == "#{name}.md" }
    if match.present?
      new(name)
    else
      fail ActiveRecord::RecordNotFound, "No record for #{param} found."
    end
  end

  def self.all
    DOCUMENTS.map { |name| self.find(name) }
  end

  def initialize(name)
    file = IO.read(Rails.root.join("docs/#{name}.md"))

    if (md = file.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$)/m))
      content = md.post_match
      metadata = YAML.load(md[:metadata])
      title = metadata["title"]
      layout = metadata["layout"]
    end

    @id = name
    @title = title || "No title"
    @layout = layout || "page"
    @content = content || ""
    @updated_at =  File.mtime(Rails.root.join("docs/#{name}.md"))
  end

  def update_date
    updated_at.utc.iso8601
  end

  def cache_key
    ActiveSupport::Cache.expand_cache_key [name, update_date]
  end
end
