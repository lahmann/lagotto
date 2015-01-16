class Datacite < Source
  def get_events(result)
    Array(result.fetch("response", {}).fetch("docs", nil)).map do |item|
      doi = item.fetch("doi", nil)
      year = item.fetch("publicationYear", nil).to_i
      title = String(item.fetch("title", []).first).chomp(".")

      { "author" => get_authors(item.fetch('creator', []), sep: ", ", reversed: true),
        "title" => title,
        "container-title" => nil,
        "issued" => { "date-parts" => [[year]] },
        "DOI" => doi,
        "URL" => get_url_from_doi(doi),
        "publisher" => item.fetch("publisher", nil),
        "type" => get_csl_type(item.fetch("resourceTypeGeneral", nil)) }
    end
  end

  def get_csl_type(type)
    DATACITE_TYPE_TRANSLATIONS.fetch(type, nil)
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    config.url || "http://search.datacite.org/api?q=relatedIdentifier:%{doi}&fl=doi,creator,title,publisher,publicationYear,resourceTypeGeneral,datacentre,datacentre_symbol,prefix,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json"
  end

  def events_url
    config.events_url || "http://search.datacite.org/ui?q=relatedIdentifier:%{doi}"
  end
end
