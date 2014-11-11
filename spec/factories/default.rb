# encoding: UTF-8

FactoryGirl.define do

  factory :article do
    sequence(:doi) { |n| "10.1371/journal.pone.00000#{n}" }
    sequence(:pmid) { |n| "1897483#{n}" }
    pmcid 2568856
    mendeley_uuid "46cb51a0-6d08-11df-afb8-0026b95d30b2"
    title 'Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web'
    year { Date.today.year - 1 }
    month { Date.today.month }
    day { Date.today.day }
    publisher_id 340

    trait(:cited) { doi '10.1371/journal.pone.0000001' }
    trait(:uncited) { doi '10.1371/journal.pone.0000002' }
    trait(:not_publisher) { doi '10.1007/s00248-010-9734-2' }
    trait(:missing_mendeley) { mendeley_uuid nil }

    factory :article_with_events do
      traces { |article| [article.association(:trace)] }
    end

    factory :article_with_events_and_alerts do
      traces { |article| [article.association(:trace)] }
      alerts { |article| [article.association(:alert)] }
    end

    factory :stale_articles do
      tasks { |article| [article.association(:task, :stale)] }
    end

    factory :queued_articles do
      tasks { |article| [article.association(:task, :queued)] }
    end

    factory :refreshed_articles do
      tasks { |article| [article.association(:task, :refreshed)] }
    end

    factory :article_for_feed do
      date = Date.today - 1.day
      year { date.year }
      month { date.month }
      day { date.day }
      tasks { |article| [article.association(:task, retrieved_at: date)] }
    end

    factory :article_published_today do
      year { Time.zone.now.year }
      tasks { |article| [article.association(:task, retrieved_at: Time.zone.today)] }
    end

    factory :article_with_errors do
      tasks { |article| [article.association(:task, :with_errors)] }
    end

    factory :article_with_private_citations do
      traces { |article| [article.association(:trace, :with_private)] }
    end

    factory :article_with_crossref_citations do
      tasks { |article| [article.association(:task, :with_crossref)] }
    end

    factory :article_with_pubmed_citations do
      tasks { |article| [article.association(:task, :with_pubmed)] }
    end

    factory :article_with_mendeley_events do
      tasks { |article| [article.association(:task, :with_mendeley)] }
    end

    factory :article_with_nature_citations do
      tasks { |article| [article.association(:task, :with_pubmed)] }
    end

    factory :article_with_researchblogging_citations do
      tasks { |article| [article.association(:task, :with_researchblogging)] }
    end

    factory :article_with_wos_citations do
      tasks { |article| [article.association(:task, :with_wos)] }
    end

    factory :article_with_counter_citations do
      traces { |article| [article.association(:trace, :with_counter)] }
    end

    factory :article_with_tweets do
      traces { |article| [article.association(:trace, :with_twitter_search)] }
    end
  end

  factory :trace do
    event_count 50
    event_metrics do
      { :pdf => nil,
        :html => nil,
        :shares => 50,
        :groups => nil,
        :comments => nil,
        :likes => nil,
        :citations => nil,
        :total => 50 }
    end
    retrieved_at { Date.today - 1.month }

    association :article
    association :source

    trait(:missing_mendeley) do
      association :article, :missing_mendeley, factory: :article
      association :agent, factory: :mendeley
    end
    trait(:stale) { scheduled_at 1.month.ago }
    trait(:queued) { queued_at 1.hour.ago }
    trait(:refreshed) { scheduled_at 1.month.from_now }
    trait(:staleness) { association :agent, factory: :citeulike }
    trait(:with_errors) { event_count 0 }
    trait(:with_private) { association :source, private: true }
    trait(:with_crossref) { association :agent, factory: :crossref }
    trait(:with_mendeley) { association :agent, factory: :mendeley }
    trait(:with_pubmed) { association :agent, factory: :pub_med }
    trait(:with_nature) { association :agent, factory: :nature }
    trait(:with_wos) { association :agent, factory: :wos }
    trait(:with_researchblogging) { association :agent, factory: :researchblogging }
    trait(:with_scienceseeker) { association :agent, factory: :scienceseeker }
    trait(:with_wikipedia) { association :agent, factory: :wikipedia }
    trait(:with_counter) { association :agent, factory: :counter }
    trait(:with_twitter_search) { association :agent, factory: :twitter_search }
    trait(:with_article_published_today) { association :article, factory: :article_published_today }
    trait(:with_counter_and_article_published_today) do
      association :article, factory: :article_published_today
      association :agent, factory: :counter
    end
    trait(:with_crossref_and_article_published_today) do
      association :article, factory: :article_published_today
      association :agent, factory: :crossref
    end

    trait(:with_crossref_histories) do
      before(:create) do |trace|
        FactoryGirl.create_list(:retrieval_history, 20, trace: trace,
                                                        article: trace.article,
                                                        agent: trace.agent)
      end
    end

    initialize_with { Trace.find_or_create_by_article_id_and_source_id(article.id, source.id) }
  end

  factory :task do
    retrieved_at { Date.today - 1.month }
    sequence(:scheduled_at) { |n| Time.zone.now - 1.day + n.minutes }

    association :article
    association :agent, factory: :citeulike

    trait(:missing_mendeley) do
      association :article, :missing_mendeley, factory: :article
      association :agent, factory: :mendeley
    end
    trait(:stale) { scheduled_at 1.month.ago }
    trait(:queued) { queued_at 1.hour.ago }
    trait(:refreshed) { scheduled_at 1.month.from_now }
    trait(:staleness) { association :agent, factory: :citeulike }
    trait(:with_errors) { event_count 0 }
    trait(:with_private) { association :source, private: true }
    trait(:with_crossref) { association :agent, factory: :crossref }
    trait(:with_mendeley) { association :agent, factory: :mendeley }
    trait(:with_pubmed) { association :agent, factory: :pub_med }
    trait(:with_nature) { association :agent, factory: :nature }
    trait(:with_wos) { association :agent, factory: :wos }
    trait(:with_researchblogging) { association :agent, factory: :researchblogging }
    trait(:with_scienceseeker) { association :agent, factory: :scienceseeker }
    trait(:with_wikipedia) { association :agent, factory: :wikipedia }
    trait(:with_counter) { association :agent, factory: :counter }
    trait(:with_twitter_search) { association :agent, factory: :twitter_search }
    trait(:with_article_published_today) { association :article, factory: :article_published_today }
    trait(:with_counter_and_article_published_today) do
      association :article, factory: :article_published_today
      association :agent, factory: :counter
    end
    trait(:with_crossref_and_article_published_today) do
      association :article, factory: :article_published_today
      association :agent, factory: :crossref
    end

    trait(:with_crossref_histories) do
      before(:create) do |trace|
        FactoryGirl.create_list(:retrieval_history, 20, trace: trace,
                                                        article: trace.article,
                                                        agent: trace.agent)
      end
    end

    initialize_with { Task.find_or_create_by_article_id_and_agent_id(article.id, agent.id) }
  end

  factory :source do
    name "citeulike"
    display_name "CiteULike"
    active true

    cached_at { Time.zone.now - 10.minutes }

    group

    initialize_with { Source.find_or_create_by_name(name) }
  end

  factory :delayed_job do
    queue 'citeulike-queue'

    initialize_with { DelayedJob.find_or_create_by_queue(queue) }
  end

  factory :report do
    name 'error_report'
    display_name 'Error Report'
    description 'Reports error summary'

    factory :error_report_with_admin_user do
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :status_report_with_admin_user do
      name 'status_report'
      display_name 'Status Report'
      description 'Reports application status'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :article_statistics_report_with_admin_user do
      name 'article_statistics_report'
      display_name 'Article Statistics Report'
      description 'Generates CSV file with ALM for all articles'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :fatal_error_report_with_admin_user do
      name 'fatal_error_report'
      display_name 'Fatal Error Report'
      description 'Reports when a fatal error has occured'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :stale_agent_report_with_admin_user do
      name 'stale_agent_report'
      display_name 'Stale Source Report'
      description 'Reports when a agent has not been updated'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end

    factory :missing_workers_report_with_admin_user do
      name 'missing_workers_report'
      display_name 'Missing Workers Report'
      description 'Reports when workers are not running'
      users { [FactoryGirl.create(:user, role: "admin")] }
    end
  end

  factory :retrieval_history do
    sequence(:retrieved_at) do |n|
      Date.today - n.weeks
    end
    sequence(:event_count) { |n| 1000 - 10 * n }
  end

  factory :alert do
    exception "An exception"
    class_name "Net::HTTPRequestTimeOut"
    message "The request timed out."
    level 2
    trace "backtrace"
    request "A request"
    user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"
    target_url "http://127.0.0.1/agents/x"
    remote_ip "127.0.0.1"
    status 408
    content_type "text/html"

    factory :alert_with_agent do
      agent
    end
  end

  factory :api_request do
    db_duration 100
    view_duration 700
    api_key "67890"
    info "history"
    agent nil
    ids "10.1371%2Fjournal.pone.000001"

    trait(:local) { api_key "12345" }
  end

  factory :api_response do
    duration 200
    event_count 10
    previous_count 5
    update_interval 7
    unresolved 1
    agent_id 1
  end

  factory :review do
    name "ArticleNotUpdatedError"
    message "Found 0 article not updated errors in 29,899 API responses, taking 29.899 ms"
    input 10
    created_at { Time.zone.now }
  end

  factory :user do
    sequence(:username) { |n| "joe#{n}@example.com" }
    sequence(:email) { |n| "joe#{n}@example.com" }
    sequence(:name) { |n| "Joe Smith#{n}" }
    password "joesmith"
    sequence(:authentication_token) { |n| "q9pWP8QxzkR24Mvs9BEy#{n}" }
    provider "persona"
    sequence(:uid) { |n| "joe#{n}@example.com" }
    publisher_id 340

    factory :admin_user do
      role "admin"
      authentication_token "12345"
    end
  end

  factory :publisher do
    crossref_id 340
    name 'Public Library of Science (PLoS)'
    other_names ["Public Library of Science", "Public Library of Science (PLoS)"]
    prefixes ["10.1371"]

    initialize_with { Publisher.find_or_create_by_crossref_id(crossref_id) }
  end

  factory :publisher_option do
    id 1
    agent_id 1
    publisher_id 340
    username "username"
    password "password"

    publisher

    initialize_with { PublisherOption.find_or_create_by_id(id) }

    factory :publisher_option_for_pmc do
      journals "ajrccm"
    end
  end

  factory :html_ratio_too_high_error, class: HtmlRatioTooHighError do
    type "HtmlRatioTooHighError"
    name "HtmlRatioTooHighError"
    display_name "html ratio too high error"
    active true

    initialize_with { HtmlRatioTooHighError.find_or_create_by_name(name) }
  end

  factory :article_not_updated_error, aliases: [:filter], class: ArticleNotUpdatedError do
    type "ArticleNotUpdatedError"
    name "ArticleNotUpdatedError"
    display_name "article not updated error"
    active true

    initialize_with { ArticleNotUpdatedError.find_or_create_by_name(name) }
  end

  factory :decreasing_event_count_error, class: EventCountDecreasingError do
    type "EventCountDecreasingError"
    name "EventCountDecreasingError"
    display_name "decreasing event count error"
    agent_ids [1]
    active true

    initialize_with { EventCountDecreasingError.find_or_create_by_name(name) }
  end

  factory :increasing_event_count_error, class: EventCountIncreasingTooFastError do
    type "EventCountIncreasingTooFastError"
    name "EventCountIncreasingTooFastError"
    display_name "increasing event count error"
    agent_ids [1]
    active true

    initialize_with { EventCountIncreasingTooFastError.find_or_create_by_name(name) }
  end

  factory :api_too_slow_error, class: ApiResponseTooSlowError do
    type "ApiResponseTooSlowError"
    name "ApiResponseTooSlowError"
    display_name "API too slow error"
    active true

    initialize_with { ApiResponseTooSlowError.find_or_create_by_name(name) }
  end

  factory :agent_not_updated_error, class: SourceNotUpdatedError do
    type "SourceNotUpdatedError"
    name "SourceNotUpdatedError"
    display_name "agent not updated error"
    active true

    initialize_with { SourceNotUpdatedError.find_or_create_by_name(name) }
  end
end
