# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Load groups
viewed = Group.find_or_create_by_name(name: "viewed", display_name: "Viewed")
saved = Group.find_or_create_by_name(name: "saved", display_name: "Saved")
discussed = Group.find_or_create_by_name(name: "discussed", display_name: "Discussed")
cited = Group.find_or_create_by_name(name: "cited", display_name: "Cited")
recommended = Group.find_or_create_by_name(name: "recommended", display_name: "Recommended")
other = Group.find_or_create_by_name(name: "other", display_name: "Other")

# Load reports
error_report = Report.find_or_create_by_name(:name => "error_report",
  :display_name => "Error Report", :description => "Reports error summary",
  :interval => 1.day, :private => true)
status_report = Report.find_or_create_by_name(:name => "status_report",
  :display_name => "Status Report", :description => "Reports application status",
  :interval => 1.week, :private => true)
article_statistics_report = Report.find_or_create_by_name(:name => "article_statistics_report",
  :display_name => "Article Statistics Report",
  :description => "Generates CSV file with ALM for all articles", :interval => 1.month, :private => false)
disabled_source_report = Report.find_or_create_by_name(:name => "disabled_source_report",
  :display_name => "Disabled Source Report",
  :description => "Reports when a source has been disabled", :interval => 0, :private => true)

# Load filters
article_not_updated_error = ArticleNotUpdatedError.find_or_create_by_name(
  :name => "ArticleNotUpdatedError",
  :display_name => "article not updated error",
  :description => "Raises an error if articles have not been updated within the specified interval in days.")
event_count_decreasing_error = EventCountDecreasingError.find_or_create_by_name(
  :name => "EventCountDecreasingError",
  :display_name => "decreasing event count error",
  :description => "Raises an error if event count decreases.")
event_count_increasing_too_fast_error = EventCountIncreasingTooFastError.find_or_create_by_name(
  :name => "EventCountIncreasingTooFastError",
  :display_name => "increasing event count error",
  :description => "Raises an error if the event count increases faster than the specified value per day.")
api_response_too_slow_error = ApiResponseTooSlowError.find_or_create_by_name(
  :name => "ApiResponseTooSlowError",
  :display_name => "API too slow error",
  :description => "Raises an error if an API response takes longer than the specified interval in seconds.")
source_not_updated_error = SourceNotUpdatedError.find_or_create_by_name(
  :name => "SourceNotUpdatedError",
  :display_name => "source not updated error",
  :description => "Raises an error if a source has not been updated in 24 hours.")
citation_milestone_alert = CitationMilestoneAlert.find_or_create_by_name(
  :name => "CitationMilestoneAlert",
  :display_name => "citation milestone alert",
  :description => "Creates an alert if an article has been cited the specified number of times.")
html_ratio_too_high_error= HtmlRatioTooHighError.find_or_create_by_name(
  :name => "HtmlRatioTooHighError",
  :display_name => "HTML ratio too high error",
  :description => "Raises an error if HTML/PDF ratio is higher than 50.")

# Load default sources
citeulike = Citeulike.find_or_create_by_name(
	:name => "citeulike",
	:display_name => "CiteULike",
  :description => "CiteULike is a free social bookmarking service for scholarly content.",
	:state_event => "activate",
	:group_id => saved.id)
pubmed = PubMed.find_or_create_by_name(
  :name => "pubmed",
  :display_name => "PubMed",
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :state_event => "activate",
  :group_id => cited.id)
pmc_europe = PmcEurope.find_or_create_by_name(
  :name => "pmceurope",
  :display_name => "PMC Europe Citations",
  :description => "Europe PubMed Central (Europe PMC) is an archive of life sciences journal literature.",
  :group_id => cited.id)
pmc_europe_data = PmcEuropeData.find_or_create_by_name(
  :name => "pmceuropedata",
  :display_name => "PMC Europe Database Citations",
  :description => "Europe PubMed Central (Europe PMC) is an archive of life sciences journal literature.",
  :group_id => cited.id)
scienceseeker = ScienceSeeker.find_or_create_by_name(
	:name => "scienceseeker",
	:display_name => "ScienceSeeker",
  :description => "Research Blogging is a science blog aggregator.",
	:group_id => discussed.id)
nature = Nature.find_or_create_by_name(
  :name => "nature",
  :display_name => "Nature Blogs",
  :description => "Nature Blogs is a science blog aggregator.",
  :group_id => discussed.id)
openedition = Openedition.find_or_create_by_name(
  :name => "openedition",
  :display_name => "OpenEdition",
  :description => "OpenEdition is the umbrella portal for OpenEdition Books, Revues.org, Hypotheses and Calenda in the humanities and social sciences.",
  :group_id => discussed.id)
wordpress = Wordpress.find_or_create_by_name(
  :name => "wordpress",
  :display_name => "Wordpress.com",
  :description => "Wordpress.com is one of the largest blog hosting platforms.",
  :state_event => "activate",
  :group_id => discussed.id)
reddit = Reddit.find_or_create_by_name(
  :name => "reddit",
  :display_name => "Reddit",
  :description => "User-generated news links.",
  :state_event => "activate",
  :group_id => discussed.id)
wikipedia = Wikipedia.find_or_create_by_name(
  :name => "wikipedia",
  :display_name => "Wikipedia",
  :description => "Wikipedia is a free encyclopedia that everyone can edit.",
  :state_event => "activate",
  :group_id => discussed.id)
datacite = Datacite.find_or_create_by_name(
  :name => "datacite",
  :display_name => "DataCite",
  :description => "Helping you to find, access, and reuse research data.",
  :group_id => cited.id)
articleconverage = ArticleCoverage.find_or_create_by_name(
    :name => "articlecoverage",
    :display_name => "Article Coverage",
    :description => "Article Coverage",
    :group_id => discussed.id)
articlecoveragecurated = ArticleCoverageCurated.find_or_create_by_name(
    :name => "articlecoveragecurated",
    :display_name => "Article Coverage Curated",
    :description => "Article Coverage Curated",
    :workers => 1,
    :group_id => discussed.id)

# The following sources require passwords/API keys
pmc = Pmc.find_or_create_by_name(
  :name => "pmc",
  :display_name => "PubMed Central Usage Stats",
  :description => "PubMed Central is a free full-text archive of biomedical literature at the National Library of Medicine.",
  :queueable => false,
  :group_id => viewed.id,
  :url => nil,
  :journals => nil,
  :username => nil,
  :password => nil)
copernicus = Copernicus.find_or_create_by_name(
  :name => "copernicus",
  :display_name => "Copernicus",
  :description => "Usage stats for Copernicus articles.",
  :group_id => viewed.id,
  :url => nil,
  :username => nil,
  :password => nil)
crossref = CrossRef.find_or_create_by_name(
  :name => "crossref",
  :display_name => "CrossRef",
  :description => "CrossRef is a non-profit organization that enables cross-publisher citation linking.",
  :state_event => "activate",
  :group_id => cited.id,
  :username => nil,
  :password => nil)
facebook = Facebook.find_or_create_by_name(
  :name => "facebook",
  :display_name => "Facebook",
  :description => "Facebook is the largest social network.",
  :state_event => "activate",
  :group_id => discussed.id,
  :access_token => nil)
twitter = TwitterSearch.find_or_create_by_name(
  :name => "twitter_search",
  :display_name => "TwitterSearch",
  :description => "Social networking and microblogging service.",
  :state_event => "install",
  :group_id => discussed.id,
  :access_token => nil)
mendeley = Mendeley.find_or_create_by_name(
  :name => "mendeley",
  :display_name => "Mendeley",
  :description => "Mendeley is a reference manager and social bookmarking tool.",
  :state_event => "activate",
  :group_id => saved.id,
  :api_key => nil)
researchblogging = Researchblogging.find_or_create_by_name(
  :name => "researchblogging",
  :display_name => "Research Blogging",
  :description => "Research Blogging is a science blog aggregator.",
  :state_event => "activate",
  :group_id => discussed.id,
  :username => nil,
  :password => nil)

# PLOS-specific sources that require passwords, API keys and/or contracts
if Source.const_defined?('Counter')
  counter = Counter.find_or_create_by_name(
    :name => "counter",
    :display_name => "Counter",
    :description => "Usage stats from the PLOS website",
    :state_event => "activate",
    :queueable => false,
    :group_id => viewed.id)
end
if Source.const_defined?('Wos')
  wos = Wos.find_or_create_by_name(
    :name => "wos",
    :display_name => "Web of Science",
    :description => "Web of Science is an online academic citation index.",
    :private => 1,
    :workers => 1,
    :group_id => cited.id)
end
if Source.const_defined?('Scopus')
  scopus = Scopus.find_or_create_by_name(
    :name => "scopus",
    :display_name => "Scopus",
    :description => "The world's largest abstract and citation database of peer-reviewed literature.",
    :group_id => cited.id,
    :username => "<%= node[:alm][:scopus][:username] %>",
    :salt => "<%= node[:alm][:scopus][:salt] %>",
    :partner_id => "<%= node[:alm][:scopus][:partner_id] %>")
end
if Source.const_defined?('F1000')
  f1000 = F1000.find_or_create_by_name(
    :name => "f1000",
    :display_name => "F1000Prime",
    :description => "Post-publication peer review of the biomedical literature.",
    :state_event => "install",
    :group_id => recommended.id)
end
if Source.const_defined?('Figshare')
  figshare = Figshare.find_or_create_by_name(
    :name => "figshare",
    :display_name => "Figshare",
    :description => "Figures, tables and supplementary files hosted by figshare",
    :state_event => "install",
    :group_id => viewed.id)
end
if Source.const_defined?('ArticleCoverage')
  articleconverage = ArticleCoverage.find_or_create_by_name(
    :name => "articlecoverage",
    :display_name => "Article Coverage",
    :description => "Article Coverage",
    :group_id => discussed.id)
end
if Source.const_defined?('ArticleCoverageCurated')
  articlecoveragecurated = ArticleCoverageCurated.find_or_create_by_name(
    :name => "articlecoveragecurated",
    :display_name => "Article Coverage Curated",
    :description => "Article Coverage Curated",
    :state_event => "activate",
    :group_id => discussed.id)
end
  plos_comments = PlosComments.find_or_create_by_name(
    :name => "plos_comments",
    :display_name => "Journal Comments",
    :description => "Comments from the PLOS website.",
    :state_event => "activate",
    :group_id => discussed.id)

# These sources are retired, but we need to keep them around for the data we collected
connotea = Connotea.find_or_create_by_name(
  :name => "connotea",
  :display_name => "Connotea",
  :description => "A free online reference management service for scientists, researchers, and clinicians (discontinued March 2013)",
  :group_id => discussed.id)
postgenomic = Postgenomic.find_or_create_by_name(
  :name => "postgenomic",
  :display_name => "Postgenomic",
  :description => "A science blog aggregator (discontinued)",
  :group_id => discussed.id)

# Load sample articles
if ENV['ARTICLES']
  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0008776",
    :title => "The \"Island Rule\" and Deep-Sea Gastropods: Re-Examining the Evidence",
    :published_on => "2010-01-19")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pcbi.1000204",
    :title => "Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web",
    :published_on => "2008-10-31")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0018657",
    :title => "Who Shares? Who Doesn't? Factors Associated with Openly Archiving Raw Research Data",
    :published_on => "2011-07-13")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pcbi.0010057",
    :title => "Ten Simple Rules for Getting Published",
    :published_on => "2005-10-28")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0000443",
    :title => "Order in Spontaneous Behavior",
    :published_on => "2007-05-16")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.1000242",
    :title => "Article-Level Metrics and the Evolution of Scientific Impact",
    :published_on => "2009-11-17")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0035869",
    :title => "Research Blogs and the Discussion of Scholarly Information",
    :published_on => "2012-05-11")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pmed.0020124",
    :title => "Why Most Published Research Findings Are False",
    :published_on => "2005-08-30")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0036240",
    :title => "How Academic Biologists and Physicists View Science Outreach",
    :published_on => "2012-05-09")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0000000",
    :title => "PLoS Journals Sandbox: A Place to Learn and Play",
    :published_on => "2006-12-20")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pmed.0020146",
    :title => "How Prevalent Is Schizophrenia?",
    :published_on => "2005-05-31")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0030137",
    :title => "Perception Space-The Final Frontier",
    :published_on => "2005-04-12")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pcbi.1002445",
    :title => "Circular Permutation in Proteins",
    :published_on => "2012-03-29")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0036790",
    :title => "New Dromaeosaurids (Dinosauria: Theropoda) from the Lower Cretaceous of Utah, and the Evolution of the Dromaeosaurid Tail",
    :published_on => "2012-05-15")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0060188",
    :title => "Going, Going, Gone: Is Animal Migration Disappearing",
    :published_on => "2008-07-29")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0001636",
    :title => "Measuring the Meltdown: Drivers of Global Amphibian Extinction and Decline",
    :published_on => "2008-02-20")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0006872",
    :title => "Persistent Exposure to Mycoplasma Induces Malignant Transformation of Human Prostate Cells",
    :published_on => "2009-09-01")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pcbi.0020131",
    :title => "Sampling Realistic Protein Conformations Using Local Structural Bias",
    :published_on => "2006-09-22")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0040015",
    :title => "Thriving Community of Pathogenic Plant Viruses Found in the Human Gut",
    :published_on => "2005-12-20")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0020413",
    :title => "Taking Stock of Biodiversity to Stem Its Rapid Decline",
    :published_on => "2004-10-26")

  Article.find_or_create_by_doi(
    :doi => "10.5194/acp-5-1053-2005",
    :title => "Organic aerosol and global climate modelling: a review",
    :published_on => "2005-03-30")

  Article.find_or_create_by_doi(
    :doi => "10.5194/acp-11-9709-2011",
    :title => "Modelling atmospheric OH-reactivity in a boreal forest ecosystem",
    :published_on => "2011-09-20")

  Article.find_or_create_by_doi(
    :doi => "10.5194/acp-11-13325-2011",
    :title => "Comparison of chemical characteristics of 495 biomass burning plumes intercepted by the NASA DC-8 aircraft during the ARCTAS/CARB-2008 field campaign",
    :published_on => "2011-12-22")

  Article.find_or_create_by_doi(
    :doi => "10.5194/acp-12-1-2012",
    :title => "A review of operational, regional-scale, chemical weather forecasting models in Europe",
    :published_on => "2012-01-02")

  Article.find_or_create_by_doi(
    :doi => "10.5194/se-1-1-2010",
    :title => "The Eons of Chaos and Hades",
    :published_on => "2010-02-02")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.ppat.1000446",
    :title => "A New Malaria Agent in African Hominids",
    :published_on => "2009-05-29")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0020094",
    :title => "Meiofauna in the Gollum Channels and the Whittard Canyon, Celtic Margin—How Local Environmental Conditions Shape Nematode Structure and Function",
    :published_on => "2011-05-18")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0000045",
    :title => "The Genome Sequence of Caenorhabditis briggsae: A Platform for Comparative Genomics",
    :published_on => "2003-11-17")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pbio.0050254",
    :title => "The Diploid Genome Sequence of an Individual Human",
    :published_on => "2007-09-04")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0044271",
    :title => "Lesula: A New Species of <italic>Cercopithecus</italic> Monkey Endemic to the Democratic Republic of Congo and Implications for Conservation of Congo’s Central Basin",
    :published_on => "2012-09-12")

  Article.find_or_create_by_doi(
    :doi => "10.1371/journal.pone.0033288",
    :title => "Genome Features of 'Dark-Fly', a <italic>Drosophila</italic> Line Reared Long-Term in a Dark Environment",
    :published_on => "2012-03-14")

  Article.find_or_create_by_doi(
    :doi => "10.2307/1158830",
    :title => "Histoires de riz, histoires d'igname: le cas de la Moyenne Cote d'Ivoire",
    :published_on => "1981-01-01")

  Article.find_or_create_by_doi(
    :doi => "10.2307/683422",
    :title => "Review of: The Life and Times of Sara Baartman: The Hottentot Venus by Zola Maseko",
    :published_on => "2000-09-01")
end
