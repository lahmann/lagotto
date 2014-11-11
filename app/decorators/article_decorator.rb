class ArticleDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def source_ids
    collection = Source
    collection = collection.where(name: context[:source]) \
      if context[:source]
    collection = collection.where("private = ?", false) \
      if context[:user] == "2"
    collection = collection.order("name").pluck(:id)
  end

  def filtered_traces
    model.traces.select { |t| source_ids.include?(t.source_id) }
  end

  def publication_date
    published_on.nil? ? nil : published_on.to_time.utc.iso8601
  end

  def url
    canonical_url
  end

  def mendeley
    mendeley_uuid
  end

  def cache_key
    { article_id: id,
      update_date: update_date,
      source_ids: source_ids,
      info: context[:info] }
  end

  def version
    "1.0"
  end

  def type
    "rich"
  end

  def width
    (context[:maxwidth] || 600).to_i
  end

  def height
    (context[:maxheight] || 100).to_i
  end

  def html
    <<-eos
#{css}
<blockquote class="alm">
<h4 class="alm">#{title}</h4>
<p class="alm" data-datetime="#{publication_date}">#{issued_date}. <a href="#{doi_as_url}">#{doi_as_url}</a></p>
<p class="alm">#{viewed_span} #{discussed_span} #{saved_span} #{cited_span} #{coins}</p>
</blockquote>
    eos
  end

  def css
    <<-eos
<style type="text/css">
  blockquote.alm {
    display: inline-block;
    background-color: #fff;
    padding: 16px;
    margin: 10px 0;
    max-width: 600px;

    border: #ddd 1px solid;
    border-top-color: #eee;
    border-bottom-color: #bbb;
    border-radius: 5px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.15);

    font-family: Helvetica, Arial, sans-serif;
    font-size: 14px;
    font-style: normal;
    font-weight: 400;
    line-height: 1.2;
    color: #000;
  }
  blockquote h4.alm, #content h4 { color: #34485e; font-family: Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 600; line-height: 1.2; margin: 0 0 5px; }
  blockquote span.alm.signpost {
    border-bottom-left-radius: 0.25em;
    border-bottom-right-radius: 0.25em;
    border-top-left-radius: 0.25em;
    border-top-right-radius: 0.25em;
    color: #FFFFFF;
    display: inline;
    font-size: 75%;
    padding: 0.2em 0.6em 0.3em;
    text-align: center;
    vertical-align: baseline;
    white-space: nowrap;
  }
  blockquote span.alm.viewed { background-color: #3498db; }
  blockquote span.alm.saved { background-color: #1dbc9c; }
  blockquote span.alm.discussed { background-color: #2ecc71; }
  blockquote span.alm.cited { background-color: #a368bd; }
  blockquote p.alm { font-size: 14px; font-weight: 400; line-height: 1.1; margin: 0 0 10px; }
  blockquote p.alm a { text-decoration: none; color: #3498DB; }
</style>
    eos
  end

  def coins
    "<span class=\"Z3988\" title=\"ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft_id=info:doi/#{doi_escaped}&amp;rft.genre=article&amp;rft.atitle=#{title_escaped}&amp;rft_date=#{published_on.to_s(:db)}\"></span>"
  end

  def viewed_span
    if model.viewed > 0
      "<span class=\"alm signpost viewed\" data-viewed=\"#{model.viewed}\">Viewed: #{model.viewed}</span>"
    else
      ""
    end
  end

  def discussed_span
    if model.discussed > 0
      "<span class=\"alm signpost discussed\" data-discussed=\"#{model.discussed}\">Discussed: #{model.discussed}</span>"
    else
      ""
    end
  end

  def saved_span
    if model.saved > 0
      "<span class=\"alm signpost saved\" data-saved=\"#{model.saved}\">Saved: #{model.saved}</span>"
    else
      ""
    end
  end

  def cited_span
    if model.cited > 0
      "<span class=\"alm signpost cited\" data-cited=\"#{model.cited}\">Cited: #{model.cited}</span>"
    else
      ""
    end
  end

  def provider_name
    CONFIG[:sitename]
  end

  def provider_url
    "http://#{CONFIG[:public_server]}"
  end
end
