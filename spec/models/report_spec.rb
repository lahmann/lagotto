require 'rails_helper'

describe Report, :type => :model do
  subject { Report }

  context "available reports" do

    before(:each) do
      FactoryGirl.create(:error_report_with_admin_user)
    end

    it "admin users should see one report" do
      response = subject.available("admin")
      expect(response.length).to eq(1)
    end

    it "regular users should not see any report" do
      response = subject.available("user")
      expect(response.length).to eq(0)
    end
  end

  describe "date_range" do
    before(:each) do
      allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5))
    end

    it 'should return this month and this year without options' do
      result = subject.date_range
      expect(result).to eq([{ month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year' do
      result = subject.date_range(month: 7, year: 2013)
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return the last three months with options month and year as string' do
      result = subject.date_range(month: "7", year: "2013")
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }, { month: 9, year: 2013 }])
    end

    it 'should return this month and year on invalid month and year' do
      result = subject.date_range(month: "July", year: 2013)
      expect(result).to eq([{ month: 9, year: 2013 }])
    end
  end

  describe "date_range for pmc" do
    before(:each) do
      allow(Date).to receive(:today).and_return(Date.new(2013, 9, 5))
    end

    it 'should return last month and this year' do
      result = subject.date_range(source: "pmc")
      expect(result).to eq([{ month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year' do
      result = subject.date_range(source: "pmc", month: 7, year: 2013)
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return the last three months until last month with options month and year as string' do
      result = subject.date_range(source: "pmc", month: "7", year: "2013")
      expect(result).to eq([{ month: 7, year: 2013 }, { month: 8, year: 2013 }])
    end

    it 'should return last month and this year on invalid month and year' do
      result = subject.date_range(source: "pmc", month: "July", year: 2013)
      expect(result).to eq([{ month: 8, year: 2013 }])
    end
  end

  context "generate csv" do
    let!(:work) { FactoryGirl.create(:work_with_events) }

    it "should format the Lagotto data as csv" do
      response = CSV.parse(subject.to_csv)
      expect(response.length).to eq(2)
      expect(response.first).to eq(["doi", "publication_date", "title", "citeulike"])
      expect(response.last).to eq([work.doi, work.published_on.iso8601, work.title, "50"])
    end
  end

  context "PMC CSV report" do
    it "should provide a date range" do
      # array of hashes for the 10 last months, excluding the current month
      start_date = 10.months.ago.to_date
      end_date = 1.month.ago.to_date
      response = subject.date_range(source: "pmc", month: start_date.month, year: start_date.year)
      expect(response.count).to eq(10)
      expect(response.last).to eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_report.json'))
      response = CSV.parse(Report.usage_csv(source: "pmc"))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["doi", "html", "pdf", "total"])
      expect(response.last).to eq(["10.1371/journal.ppat.1000446", "9", "6", "15"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(source: "pmc", month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.ppat.1000446", "5", "4"]
      row.fill("0", 3..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_html_report.json'))
      response = CSV.parse(Report.usage_csv(source: "pmc", format: "html", month: 11, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["doi"] + dates)
      expect(response.last).to eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(source: "pmc", month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0030137", "0", "0"]
      row.fill("0", 3..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_pdf_report.json'))
      response = CSV.parse(Report.usage_csv(source: "pmc", format: "pdf", month: 11, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(source: "pmc", month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0040015", "9", "10"]
      row.fill("0", 3..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_combined_report.json'))
      response = CSV.parse(Report.usage_csv(source: "pmc", format: "combined", month: 11, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[3]).to eq(row)
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc"
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(Report.usage_csv(source: "pmc")).to be_nil
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Faraday::ResourceNotFound")
      expect(notification.message).to eq("CouchDB report for pmc could not be retrieved.")
      expect(notification.status).to eq(404)
    end
  end

  context "Counter CSV report" do
    it "should provide a date range" do
      # array of hashes for the 10 last months, including the current month
      start_date = 10.months.ago.to_date
      end_date = Date.today
      response = subject.date_range(month: start_date.month, year: start_date.year)
      expect(response.count).to eq(11)
      expect(response.last).to eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_report.json'))
      response = CSV.parse(Report.usage_csv(source: "counter"))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi", "html", "pdf", "total"])
      expect(response.last).to eq(["10.1371/journal.ppat.1000446", "7489", "1147", "8676"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.ppat.1000446", "112", "95", "45"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_html_report.json'))
      response = CSV.parse(Report.usage_csv(source: "counter", format: "html", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response.last).to eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "1"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_pdf_report.json'))
      response = CSV.parse(Report.usage_csv(source: "counter", format: "pdf", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB XML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "0"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_xml_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_xml_report.json'))
      response = CSV.parse(Report.usage_csv(source: "counter", format: "xml", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0030137", "165", "149", "61"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_combined_report.json'))
      response = CSV.parse(Report.usage_csv(source: "counter", format: "combined", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[3]).to eq(row)
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(Report.usage_csv(source: "counter")).to be_nil
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Faraday::ResourceNotFound")
      expect(notification.message).to eq("CouchDB report for counter could not be retrieved.")
      expect(notification.status).to eq(404)
    end
  end

  context "write csv to file" do
    before(:each) do
      FileUtils.rm_rf("#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}")
    end

    let!(:work) { FactoryGirl.create(:work_with_events, doi: "10.1371/journal.pcbi.1000204") }
    let(:csv) { subject.to_csv }
    let(:filename) { "alm_stats.csv" }
    let(:mendeley) { FactoryGirl.create(:mendeley) }

    it "should write report file" do
      filepath = "#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}/#{filename}"
      response = subject.write(filename, csv)
      expect(response).to eq (filepath)
    end

    describe "merge and compress csv file" do

      before(:each) do
        subject.write(filename, csv)
      end

      it "should read stats" do
        stat = { name: "alm_stats" }
        response = subject.read_stats(stat).to_s
        expect(response).to eq(csv)
      end

      it "should merge stats" do
        url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc"
        stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
        filename = "pmc_stats.csv"
        filepath = "#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}/#{filename}"
        csv = subject.usage_csv(source: "pmc")
        subject.write(filename, csv)

        response = CSV.parse(subject.merge_stats)
        expect(response.length).to eq(2)
        expect(response.first).to eq(["doi", "publication_date", "title", "citeulike", "pmc_html", "pmc_pdf"])
        expect(response.last).to eq([work.doi, work.published_on.iso8601, work.title, "50", "136", "19"])
        File.delete filepath
      end

      it "should merge stats from single report" do
        response = subject.merge_stats.to_s
        expect(response).to eq(csv)
      end

      it "should zip report file" do
        csv = subject.merge_stats
        filename = "alm_report.csv"
        zip_filepath = "#{Rails.root}/public/files/alm_report.zip"
        subject.write(filename, csv)

        response = subject.zip_file
        expect(response).to eq(zip_filepath)
        expect(File.exist?(zip_filepath)).to be true
        File.delete zip_filepath
      end

      it "should zip report folder" do
        zip_filepath = "#{Rails.root}/data/report_#{Time.zone.now.to_date.iso8601}.zip"
        response = subject.zip_folder
        expect(response).to eq(zip_filepath)
        expect(File.exist?(zip_filepath)).to be true
        File.delete zip_filepath
      end
    end
  end

  context "error report" do
    let(:report) { FactoryGirl.create(:error_report_with_admin_user) }

    it "send email" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Error Report")
    end

    it "generates a multipart message (plain text and html)" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body.parts.length).to eq(2)
      expect(mail.body.parts.map(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
    end

    it "generates proper links to the admin dashboard" do
      report.send_error_report
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to include("<a href=\"http://#{ENV['SERVERNAME']}/notifications\">Go to admin dashboard</a>")
    end
  end

  context "stale agent report" do
    let(:source) { FactoryGirl.create(:source) }
    let(:source_ids) { [source.id] }
    let(:report) { FactoryGirl.create(:stale_source_report_with_admin_user) }

    it "send email" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([report.users.map(&:email).join(",")])
      expect(mail.subject).to eq("[#{ENV['SITENAME']}] Stale Source Report")
    end

    it "generates a multipart message (plain text and html)" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body.parts.length).to eq(2)
      expect(mail.body.parts.map(&:content_type)).to eq(["text/plain; charset=UTF-8", "text/html; charset=UTF-8"])
    end

    it "generates proper links to the admin dashboard" do
      report.send_stale_source_report(source_ids)
      mail = ActionMailer::Base.deliveries.last
      body_html = mail.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source
      expect(body_html).to include("<a href=\"http://#{ENV['SERVERNAME']}/notifications?class=SourceNotUpdatedError\">Go to admin dashboard</a>")
    end
  end
end
