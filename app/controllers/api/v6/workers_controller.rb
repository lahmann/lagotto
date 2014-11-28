class Api::V6::WorkersController < Api::V6::BaseController
  def index
    @workers = Worker.all
  end

  def show
    @worker = Worker.find(params[:id])
  end
end
