class ApplicationController < ActionController::Base
  protect_from_forgery

  prepend_before_filter :disable_devise_trackable,
                        :cors_set_access_control_headers
  before_filter :miniprofiler
  after_filter :set_jsonp_format

  def default_format_json
    request.format = :json if request.format.html?
  end

  # from https://github.com/spree/spree/blob/master/api/app/controllers/spree/api/base_controller.rb
  def set_jsonp_format
    if params[:callback] && request.get?
      self.response_body = "#{params[:callback]}(#{response.body})"
      headers["Content-Type"] = 'application/javascript'
    end
  end

  # depreciated, used in v3 and v5 APIs
  # looking for URL parameter "&api_key=12345"
  def authenticate_user_from_api_key!
    api_key = params[:api_key].presence
    user = api_key && User.where(authentication_token: api_key.to_s).first

    if user && Devise.secure_compare(user.authentication_token, api_key)
      sign_in user, store: false
    else
      render json: { error: "Missing or wrong API key." }, status: 401
    end
  end

  # looking for header "Authorization: Token token=12345"
  def authenticate_user_from_token!
    authenticate_with_http_token do |token, options|
      user = token && User.where(authentication_token: token).first

      if user && Devise.secure_compare(user.authentication_token, token)
        sign_in user, store: false
      else
        current_user = false
      end
    end
  end

  def is_staff?
    current_user && current_user.is_staff?
  end

  def after_sign_in_path_for(resource)
    current_user_path
  end

  def create_notification(exception, options = {})
    Notification.create(exception: exception, status: options[:status])
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, X-CSRF-Token, Authorization'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def disable_devise_trackable
    request.env["devise.skip_trackable"] = true
  end

  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError do |exception|
    render json: { error: exception.message }, status: :not_found
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :forbidden
  end

  rescue_from ActionController::ParameterMissing, ActionController::UnpermittedParameters, NoMethodError do |exception|
    create_notification(exception, status: 422)
    render json: { error: exception.message }, status: 422
  end

  private

  def miniprofiler
    Rack::MiniProfiler.authorize_request if current_user && current_user.is_admin?
  end
end
