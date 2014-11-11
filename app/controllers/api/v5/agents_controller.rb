class Api::V5::AgentsController < Api::V5::BaseController
  def index
    @agents = AgentDecorator.decorate_collection(Agent.visible)
  end

  def show
    @agent = Agent.find_by_name(params[:id])
    @agent = AgentDecorator.decorate(@agent)
  end
end
