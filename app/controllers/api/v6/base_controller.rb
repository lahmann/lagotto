class Api::V6::BaseController < ApplicationController
  before_filter :authenticate_user_from_token!
end
