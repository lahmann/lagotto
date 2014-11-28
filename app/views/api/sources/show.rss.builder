xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Lagotto: most-cited works in #{@source.title}"
    xml.link api_source_url(@source, format: "rss")

    @traces.each do |trace|
      xml.item do
        xml.title trace.work.title
        xml.description pluralize(trace.event_count, "#{@source.title} event")
        xml.pubDate trace.work.published_on.to_time.utc.to_s(:rfc822)
        xml.link "http://dx.doi.org/#{trace.work.doi}"
        xml.guid trace.work.uid
      end
    end
  end
end
