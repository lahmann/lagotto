class Api::V6::FiltersController < Api::V6::BaseController
  before_filter :load_filter, only: [:edit, :update]
  load_and_authorize_resource

  def index
    load_index
    @filters = @filters.decorate
  end

  def edit
    load_index
  end

  def update
    params[:filter] ||= {}
    params[:filter][:active] = params[:active] if params[:active]
    @filter.update_attributes(safe_params)
    load_index
  end

  protected

  def load_filter
    @filter = Filter.where(id: params[:id]).first
  end

  def load_index
    @filters = Filter.order(:name)
  end

  private

  def safe_params
    params.require(:filter).permit(:active, *@filter.config_fields, source_ids: [])
  end
end
