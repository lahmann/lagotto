class Api::V6::Users::SessionsController < Devise::SessionsController
  # include base controller methods
  include Authenticable

  before_filter :default_format_json,
                :cors_set_access_control_headers
  after_filter :set_jsonp_format

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    data = {
      user_token: self.resource.authentication_token,
      user_email: self.resource.email
    }
    render json: data, status: 201
  end
end
