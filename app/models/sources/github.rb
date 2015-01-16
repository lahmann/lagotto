class Github < Source
  def get_query_url(work)
    return nil unless work.canonical_url =~ /github.com/

    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    full_name = URI.parse(work.canonical_url).path[1..-1]
    owner, repo = full_name.split('/')

    url % { owner: owner, repo: repo }
  end

  def request_options
    { bearer: personal_access_token }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    shares = result.fetch("forks_count", 0)
    likes = result.fetch("stargazers_count", 0)
    total = shares + likes

    extra = result.slice("stargazers_count", "stargazers_url", "forks_count", "forks_url")

    { events: [],
      events_by_day: [],
      events_by_month: [],
      events_url: nil,
      event_count: total,
      event_metrics: get_event_metrics(shares: shares, likes: likes, total: total),
      extra: extra }
  end

  def config_fields
    [:url, :personal_access_token]
  end

  def url
    config.url || "https://api.github.com/repos/%{owner}/%{repo}"
  end

  # More info at https://github.com/blog/1509-personal-api-tokens
  def personal_access_token
    config.personal_access_token
  end

  def personal_access_token=(value)
    config.personal_access_token = value
  end

  def rate_limiting
    config.rate_limiting || 5000
  end
end
