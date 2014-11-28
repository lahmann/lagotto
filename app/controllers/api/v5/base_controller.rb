class Api::V5::BaseController < ApplicationController
  before_filter :authenticate_user_from_api_key!
end
