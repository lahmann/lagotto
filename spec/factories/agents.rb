FactoryGirl.define do

  factory :group do
    name 'saved'
    title 'Saved'

    initialize_with { Group.where(name: name).first_or_initialize }
  end

  factory :source do
    name "citeulike"
    title "CiteULike"
    active true

    group

    factory :source_with_changes do
      after(:create) do |source|
        FactoryGirl.create_list(:change, 5, source: source)
      end
    end

    initialize_with { Source.where(name: name).first_or_initialize }
  end

  factory :citeulike, aliases: [:agent], class: Citeulike do
    type "Citeulike"
    name "citeulike"
    source "citeulike"
    title "CiteULike"
    state_event "activate"

    cached_at { Time.zone.now - 10.minutes }

    group

    factory :agent_with_tasks do
      after :create do |agent|
        FactoryGirl.create_list(:task, 10, agent: agent)
      end
    end

    factory :agent_with_api_responses do
      after :create do |agent|
        FactoryGirl.create_list(:api_response, 5, agent: agent)
      end
    end

    initialize_with { Citeulike.where(name: name).first_or_create }
  end

  factory :copernicus, class: Copernicus do
    type "Copernicus"
    name "copernicus"
    source "copernicus"
    title "Copernicus"
    state_event "activate"
    url "http://harvester.copernicus.org/api/v1/articleStatisticsDoi/doi:%{doi}"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Copernicus.where(name: name).first_or_initialize }
  end

  factory :crossref, class: CrossRef do
    type "CrossRef"
    name "crossref"
    source "crossref"
    title "CrossRef"
    state_event "activate"
    openurl_username "openurl_username"

    group

    after(:create) do |agent|
      FactoryGirl.create(:publisher_option, agent: agent)
    end

    factory :crossref_without_password do
      after(:create) do |agent|
        FactoryGirl.create(:publisher_option, agent: agent, password: nil)
      end
    end
  end

  factory :nature, class: Nature do
    type "Nature"
    name "nature"
    source "nature"
    title "Nature"
    state_event "activate"

    group

    initialize_with { Nature.where(name: name).first_or_initialize }
  end

  factory :openedition, class: Openedition do
    type "Openedition"
    name "openedition"
    source "openedition"
    title "OpenEdition"
    state_event "activate"

    group

    initialize_with { Openedition.where(name: name).first_or_initialize }
  end

  factory :pmc, class: Pmc do
    type "Pmc"
    name "pmc"
    source "pmc"
    title "PubMed Central Usage Stats"
    state_event "activate"
    db_url "http://127.0.0.1:5984/pmc_usage_stats_test/"

    group

    after(:create) do |agent|
      FactoryGirl.create(:publisher_option_for_pmc, agent: agent)
    end
  end

  factory :pub_med, class: PubMed do
    type "PubMed"
    name "pub_med"
    source "pub_med"
    title "PubMed"
    state_event "activate"

    group

    initialize_with { PubMed.where(name: name).first_or_initialize }
  end

  factory :pmc_europe, class: PmcEurope do
    type "PmcEurope"
    name "pmc_europe"
    source "pmc_europe"
    title "PMC Europe Citations"
    state_event "activate"

    group

    initialize_with { PmcEurope.where(name: name).first_or_initialize }
  end

  factory :pmc_europe_data, class: PmcEuropeData do
    type "PmcEuropeData"
    name "pmc_europe_data"
    source "pmc_europe_data"
    title "PMC Europe Database Citations"
    state_event "activate"

    group

    initialize_with { PmcEuropeData.where(name: name).first_or_initialize }
  end

  factory :researchblogging, class: Researchblogging do
    type "Researchblogging"
    name "researchblogging"
    source "researchblogging"
    title "Research Blogging"
    state_event "activate"
    username "EXAMPLE"
    password "EXAMPLE"

    group

    initialize_with { Researchblogging.where(name: name).first_or_initialize }
  end

  factory :science_seeker, class: ScienceSeeker do
    type "ScienceSeeker"
    name "scienceseeker"
    source "scienceseeker"
    title "ScienceSeeker"
    state_event "activate"

    group

    initialize_with { ScienceSeeker.where(name: name).first_or_initialize }
  end

  factory :datacite, class: Datacite do
    type "Datacite"
    name "datacite"
    source "datacite"
    title "DataCite"
    state_event "activate"

    group

    initialize_with { Datacite.where(name: name).first_or_initialize }
  end

  factory :wordpress, class: Wordpress do
    type "Wordpress"
    name "wordpress"
    source "wordpress"
    title "Wordpress.com"
    state_event "activate"

    group

    initialize_with { Wordpress.where(name: name).first_or_initialize }
  end

  factory :reddit, class: Reddit do
    type "Reddit"
    name "reddit"
    source "reddit"
    title "Reddit"
    state_event "activate"

    group

    initialize_with { Reddit.where(name: name).first_or_initialize }
  end

  factory :twitter_search, class: TwitterSearch do
    type "TwitterSearch"
    name "twitter_search"
    source "twitter_search"
    title "Twitter"
    state_event "activate"
    api_key "EXAMPLE"
    api_secret "EXAMPLE"
    access_token "EXAMPLE"

    group

    initialize_with { TwitterSearch.where(name: name).first_or_initialize }
  end

  factory :wikipedia, class: Wikipedia do
    type "Wikipedia"
    name "wikipedia"
    source "wikipedia"
    title "Wikipedia"
    state_event "activate"
    languages "en"

    group

    initialize_with { Wikipedia.where(name: name).first_or_initialize }
  end

  factory :mendeley, class: Mendeley do
    type "Mendeley"
    name "mendeley"
    source "mendeley"
    title "Mendeley"
    state_event "activate"
    client_id "EXAMPLE"
    client_secret "EXAMPLE"
    access_token "EXAMPLE"
    expires_at { Time.zone.now + 1.hour }

    group

    initialize_with { Mendeley.where(name: name).first_or_initialize }
  end

  factory :facebook, class: Facebook do
    type "Facebook"
    name "facebook"
    source "facebook"
    title "Facebook"
    client_id "EXAMPLE"
    client_secret "EXAMPLE"
    access_token "EXAMPLE"

    group

    initialize_with { Facebook.where(name: name).first_or_initialize }
  end

  factory :scopus, class: Scopus do
    type "Scopus"
    name "scopus"
    source "scopus"
    title "Scopus"
    api_key "EXAMPLE"
    insttoken "EXAMPLE"

    group

    initialize_with { Scopus.where(name: name).first_or_initialize }
  end

  factory :counter, class: Counter do
    type "Counter"
    name "counter"
    source "counter"
    title "Counter"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { Counter.where(name: name).first_or_initialize }
  end

  factory :f1000, class: F1000 do
    type "F1000"
    name "f1000"
    source "f1000"
    title "F1000Prime"
    state_event "activate"
    db_url "http://127.0.0.1:5984/f1000_test/"
    feed_url "http://example.org/example.xml"

    group

    initialize_with { F1000.where(name: name).first_or_initialize }
  end

  factory :figshare, class: Figshare do
    type "Figshare"
    name "figshare"
    source "figshare"
    title "Figshare"
    state_event "activate"
    url "http://api.figshare.com/v1/publishers/search_for?doi=%{doi}"

    group

    initialize_with { Figshare.where(name: name).first_or_initialize }
  end

  factory :plos_comments, class: PlosComments do
    type "PlosComments"
    name "plos_comments"
    source "plos_comments"
    title "PLOS Comments"
    state_event "activate"
    url "http://example.org?doi={doi}"

    group

    initialize_with { PlosComments.where(name: name).first_or_initialize }
  end

  factory :twitter, class: Twitter do
    type "Twitter"
    name "twitter"
    source "twitter"
    title "Twitter"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { Twitter.where(name: name).first_or_initialize }
  end

  factory :wos, class: Wos do
    type "Wos"
    name "wos"
    source "wos"
    title "Web of Science"
    state_event "activate"
    url "https://ws.isiknowledge.com:80/cps/xrpc"

    group

    initialize_with { Wos.where(name: name).first_or_initialize }
  end

  factory :relative_metric, class: RelativeMetric do
    type "RelativeMetric"
    name "relative_metric"
    source "relative_metric"
    title "Relative Metric"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { RelativeMetric.where(name: name).first_or_initialize }
  end

  factory :article_coverage, class: ArticleCoverage do
    type "ArticleCoverage"
    name "article_coverage"
    source "article_coverage"
    title "Article Coverage"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { ArticleCoverage.where(name: name).first_or_initialize }
  end

  factory :article_coverage_curated, class: ArticleCoverageCurated do
    type "ArticleCoverageCurated"
    name "article_coverage_curated"
    source "article_coverage_curated"
    title "Article Coverage Curated"
    state_event "activate"
    url "http://example.org?doi=%{doi}"

    group

    initialize_with { ArticleCoverageCurated.where(name: name).first_or_initialize }
  end
end
