require 'spec_helper'

describe Wos do
  let(:wos) { FactoryGirl.create(:wos) }

  it "should report that there are no events if the doi is missing" do
    article_without_doi = FactoryGirl.build(:article, :doi => "")
    wos.get_data(article_without_doi).should eq({ :events => [], :event_count => nil })
  end

  it "should generate a proper XMl request" do
    article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007")
    request = File.read(fixture_path + 'wos_request.xml')
    wos.get_xml_request(article).should eq(request)
  end

  context "use the Wos API" do
    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0043007") }

    it "should report if there are no events and event_count returned by the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => File.read(fixture_path + 'wos_nil.xml'), :status => 200, :headers => { "Content-Type" => "application/xml" })
      wos.get_data(article).should eq({ :events => 0, :event_count => 0, :events_url => nil, :event_metrics => { :pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 }, :attachment => nil })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => File.read(fixture_path + 'wos.xml'), :status => 200, :headers => { "Content-Type" => "application/xml" })
      response = wos.get_data(article)
      response[:event_count].should eq(1005)
      response[:events_url].should include("http://gateway.webofknowledge.com/gateway/Gateway.cgi")
      response[:attachment][:data].should be_true
      stub.should have_been_requested
    end

    it "should catch IP address errors with the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:body => File.read(fixture_path + 'wos_unauthorized.xml'), :status => 200, :headers => { "Content-Type" => "application/xml" })
      wos.get_data(article).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.message.should include("Web of Science error Server.authentication")
      alert.status.should == 401
      alert.source_id.should == wos.id
    end

    it "should catch errors with the Wos API" do
      stub = stub_request(:post, wos.get_query_url(article)).with(:body => /.*/, :headers => { "Accept" => "application/xml" }).to_return(:status => [408])
      wos.get_data(article, options = { :source_id => wos.id }).should eq({ :events => [], :event_count => nil })
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == wos.id
    end
  end
end