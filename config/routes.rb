Lagotto::Application.routes.draw do

  # authentication
  devise_for :users, path: 'api/v6/users',
             controllers: { registrations: "api/v6/users/registrations" },
             :skip => :sessions

  # we only receive /api requests from nginx
  namespace :api do

    # handle CORS options requests
    match "*path", to: "cors#index", via: [:options]

    get "heartbeat", to: "heartbeat#show", defaults: { format: "json" }
    get "oembed", to: "oembed#show"
    resources :sources, only: [:show], constraints: { :format=> "rss" }
    get "", to: "heartbeat#show", defaults: { format: "json" }

    get "/files/alm_report.zip", to: redirect("/files/alm_report.zip")

    namespace :v3, defaults: { format: "json" } do
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }
    end

    namespace :v5, defaults: { format: "json" } do
      resources :works, path: "articles", constraints: { :id => /.+?/, :format=> false }
    end

    namespace :v6, defaults: { format: "json" } do
      resources :agents
      resources :notifications
      resources :api_requests, only: [:index]
      resources :docs, only: [:index, :show]
      resources :filters
      resources :groups
      resources :publishers
      resources :deposits
      resources :sources
      resources :status, only: [:index]
      resources :users
      resources :works, :constraints => { :id => /.+?/ }
    end
  end

  # rescue routing errors
  match "*path", to: "api/v6/notifications#routing_error", via: [:get, :post]
end
