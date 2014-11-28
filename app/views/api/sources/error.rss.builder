xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @error
    xml.link "http://#{ENV['SERVERNAME']}"
  end
end
