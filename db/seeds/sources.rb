# encoding: UTF-8
# Load groups
viewed = Group.where(name: 'viewed').first_or_create(title: 'Viewed')
saved = Group.where(name: 'saved').first_or_create(title: 'Saved')
discussed = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
cited = Group.where(name: 'cited').first_or_create(title: 'Cited')
recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')
other = Group.where(name: 'other').first_or_create(title: 'Other')

# These sources are installed and activated by default
citeulike = Source.where(name: 'citeulike').first_or_create(
  :title => 'CiteULike',
  :description => 'CiteULike is a free social bookmarking service for scholarly content.',
  :group_id => saved.id)
pubmed = Source.where(name: 'pubmed').first_or_create(
  :title => 'PubMed Central',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :group_id => cited.id)
wordpress = Source.where(name: 'wordpress').first_or_create(
  :title => 'Wordpress.com',
  :description => 'Wordpress.com is one of the largest blog hosting platforms.',
  :group_id => discussed.id)
reddit = Source.where(name: 'reddit').first_or_create(
  :title => 'Reddit',
  :description => 'User-generated news links.',
  :group_id => discussed.id)
wikipedia = Source.where(name: 'wikipedia').first_or_create(
  :title => 'Wikipedia',
  :description => 'Wikipedia is a free encyclopedia that everyone can edit.',
  :group_id => discussed.id)
datacite = Source.where(name: 'datacite').first_or_create(
  :title => 'DataCite',
  :description => 'Helping you to find, access, and reuse research data.',
  :group_id => cited.id)

# These sources are not installed by default
pmc_europe = Source.where(name: 'pmceurope').first_or_create(
  :title => 'Europe PubMed Central',
  :description => 'Europe PubMed Central (Europe PMC) is an archive of life ' \
                  'sciences journal literature.',
  :group_id => cited.id)
pmc_europe_data = Source.where(name: 'pmceuropedata').first_or_create(
  :title => 'Europe PubMed Central Database Citations',
  :description => 'Europe PubMed Central (Europe PMC) Database is an archive of ' \
                  'life sciences journal data.',
  :group_id => cited.id)
scienceseeker = Source.where(name: 'scienceseeker').first_or_create(
  :title => 'ScienceSeeker',
  :description => 'Research Blogging is a science blog aggregator.',
  :group_id => discussed.id)
nature = Source.where(name: 'nature').first_or_create(
  :title => 'Nature Blogs',
  :description => 'Nature Blogs is a science blog aggregator.',
  :group_id => discussed.id)
openedition = Source.where(name: 'openedition').first_or_create(
  :title => 'OpenEdition',
  :description => 'OpenEdition is the umbrella portal for OpenEdition Books, ' \
                  'Revues.org, Hypotheses and Calenda in the humanities and ' \
                  'social sciences.',
  :group_id => discussed.id)

# The following sources require passwords/API keys and are installed by default
crossref = Source.where(name: 'crossref').first_or_create(
  :title => 'CrossRef',
  :description => 'CrossRef is a non-profit organization that enables ' \
                  'cross-publisher citation linking.',
  :group_id => cited.id)
scopus = Source.where(name: 'scopus').first_or_create(
  :title => 'Scopus',
  :description => 'Scopus is an abstract and citation database of peer-' \
                  'reviewed literature.',
  :group_id => cited.id)
mendeley = Source.where(name: 'mendeley').first_or_create(
  :title => 'Mendeley',
  :description => 'Mendeley is a reference manager and social bookmarking tool.',
  :group_id => saved.id)
facebook = Source.where(name: 'facebook').first_or_create(
  :title => 'Facebook',
  :description => 'Facebook is the largest social network.',
  :group_id => discussed.id)
researchblogging = Source.where(name: 'researchblogging').first_or_create(
  :title => 'Research Blogging',
  :description => 'Research Blogging is a science blog aggregator.',
  :group_id => discussed.id)

# The following sources require passwords/API keys and are not installed by default
pmc = Source.where(name: 'pmc').first_or_create(
  :title => 'PubMed Central Usage Stats',
  :description => 'PubMed Central is a free full-text archive of biomedical ' \
                  'literature at the National Library of Medicine.',
  :group_id => viewed.id)
copernicus = Source.where(name: 'copernicus').first_or_create(
  :title => 'Copernicus',
  :description => 'Usage stats for Copernicus articles.',
  :group_id => viewed.id)
twitter_search = Source.where(name: 'twitter_search').first_or_create(
  :title => 'Twitter (Search API)',
  :description => 'Twitter is a social networking and microblogging service.',
  :group_id => discussed.id)
counter = Source.where(name: 'counter').first_or_create(
  :title => "Counter",
  :description => "Usage stats from the PLOS website",
  :group_id => viewed.id)
wos = Source.where(name: 'wos').first_or_create(
  :title => "Web of Science",
  :description => "Web of Science is an online academic citation index.",
  :private => true,
  :group_id => cited.id)
f1000 = Source.where(name: 'f1000').first_or_create(
  :title => "F1000Prime",
  :description => "Post-publication peer review of the biomedical literature.",
  :group_id => recommended.id)
figshare = Source.where(name: 'figshare').first_or_create(
  :title => "Figshare",
  :description => "Figures, tables and supplementary files hosted by figshare",
  :group_id => viewed.id)
articleconverage = Source.where(name: 'articlecoverage').first_or_create(
  :title => "Article Coverage",
  :description => "Article Coverage",
  :group_id => other.id)
articlecoveragecurated = Source.where(name: 'articlecoveragecurated').first_or_create(
  :title => "Article Coverage Curated",
  :description => "Article Coverage Curated",
  :group_id => other.id)
plos_comments = Source.where(name: 'plos_comments').first_or_create(
  :title => "Journal Comments",
  :description => "Comments from the PLOS website.",
  :group_id => discussed.id)

# These sources are installed and activated by default
citeulike = Citeulike.where(name: 'citeulike').first_or_create(
  :title => 'CiteULike',
  :source => "citeulike",
  :state_event => 'activate',
  :group_id => saved.id)
pubmed = PubMed.where(name: 'pubmed').first_or_create(
  :title => 'PubMed Central',
  :source => "pubmed",
  :state_event => 'activate',
  :group_id => cited.id)
wordpress = Wordpress.where(name: 'wordpress').first_or_create(
  :title => 'Wordpress.com',
  :source => "wordpress",
  :state_event => 'activate',
  :group_id => discussed.id)
reddit = Reddit.where(name: 'reddit').first_or_create(
  :title => 'Reddit',
  :source => "reddit",
  :state_event => 'activate',
  :group_id => discussed.id)
wikipedia = Wikipedia.where(name: 'wikipedia').first_or_create(
  :title => 'Wikipedia',
  :source => "wikipedia",
  :state_event => 'activate',
  :group_id => discussed.id)
datacite = Datacite.where(name: 'datacite').first_or_create(
  :title => 'DataCite',
  :source => "datacite",
  :group_id => cited.id)

# These sources are not installed by default
pmc_europe = PmcEurope.where(name: 'pmceurope').first_or_create(
  :title => 'Europe PubMed Central',
  :source => "pmceurope",
  :group_id => cited.id)
pmc_europe_data = PmcEuropeData.where(name: 'pmceuropedata').first_or_create(
  :title => 'Europe PubMed Central Database Citations',
  :source => "pmceuropedata",
  :group_id => cited.id)
scienceseeker = ScienceSeeker.where(name: 'scienceseeker').first_or_create(
  :title => 'ScienceSeeker',
  :source => "scienceseeker",
  :group_id => discussed.id)
nature = Nature.where(name: 'nature').first_or_create(
  :title => 'Nature Blogs',
  :source => "nature",
  :group_id => discussed.id)
openedition = Openedition.where(name: 'openedition').first_or_create(
  :title => 'OpenEdition',
  :source => "openedition",
  :group_id => discussed.id)

# The following sources require passwords/API keys and are installed by default
crossref = CrossRef.where(name: 'crossref').first_or_create(
  :title => 'CrossRef',
  :source => "crossref",
  :group_id => cited.id,
  :state_event => 'install',
  :username => nil,
  :password => nil)
scopus = Scopus.where(name: 'scopus').first_or_create(
  :title => 'Scopus',
  :source => "scopus",
  :group_id => cited.id,
  :api_key => nil,
  :insttoken => nil)
mendeley = Mendeley.where(name: 'mendeley').first_or_create(
  :title => 'Mendeley',
  :source => "mendeley",
  :group_id => saved.id,
  :state_event => 'install',
  :api_key => nil)
facebook = Facebook.where(name: 'facebook').first_or_create(
  :title => 'Facebook',
  :source => "facebook",
  :group_id => discussed.id,
  :state_event => 'install',
  :access_token => nil)
researchblogging = Researchblogging.where(name: 'researchblogging').first_or_create(
  :title => 'Research Blogging',
  :source => "researchblogging",
  :group_id => discussed.id,
  :username => nil,
  :password => nil)

# The following sources require passwords/API keys and are not installed by default
pmc = Pmc.where(name: 'pmc').first_or_create(
  :title => 'PubMed Central Usage Stats',
  :source => "pmc",
  :group_id => viewed.id)
copernicus = Copernicus.where(name: 'copernicus').first_or_create(
  :title => 'Copernicus',
  :source => "copernicus",
  :group_id => viewed.id)
twitter_search = TwitterSearch.where(name: 'twitter_search').first_or_create(
  :title => 'Twitter (Search API)',
  :source => "twitter_search",
  :group_id => discussed.id)
counter = Counter.where(name: 'counter').first_or_create(
  :title => "Counter",
  :source => "counter",
  :group_id => viewed.id)
wos = Wos.where(name: 'wos').first_or_create(
  :title => "Web of Science",
  :source => "wos",
  :group_id => cited.id)
f1000 = F1000.where(name: 'f1000').first_or_create(
  :title => "F1000Prime",
  :source => "f1000",
  :group_id => recommended.id)
figshare = Figshare.where(name: 'figshare').first_or_create(
  :title => "Figshare",
  :source => "figshare",
  :group_id => viewed.id)
articleconverage = ArticleCoverage.where(name: 'articlecoverage').first_or_create(
  :title => "Article Coverage",
  :source => "articlecoverage",
  :group_id => other.id)
articlecoveragecurated = ArticleCoverageCurated.where(name: 'articlecoveragecurated').first_or_create(
  :title => "Article Coverage Curated",
  :source => "articlecoveragecurated",
  :group_id => other.id)
plos_comments = PlosComments.where(name: 'plos_comments').first_or_create(
  :title => "Journal Comments",
  :source => "plos_comments",
  :group_id => discussed.id)
