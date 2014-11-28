class Api::V6::NotificationsController < Api::V6::BaseController
  load_and_authorize_resource
  skip_authorize_resource :only => [:create, :routing_error]

  def index
    collection = Notification.unscoped.order("notifications.created_at DESC")
    collection = collection.where(unresolved: true) if params[:unresolved]
    if params[:hostname].present?
      @hostname = params[:hostname]
      collection = collection.where(:hostname => @hostname)
    end
    if params[:agent_id].present?
      @agent = Agent.where(name: params[:agent_id]).first
      collection = collection.where(agent_id: @agent.id)
    end
    if params[:source_id].present?
      @source = Source.where(name: params[:source_id]).first
      collection = collection.where(source_id: @source.id)
    end
    if params[:class_name].present?
      @class_name = params[:class_name]
      collection = collection.where(:class_name => @class_name)
    end
    if params[:level].present?
      level = Notification::LEVELS.index(params[:level].upcase) || 0
      collection = collection.where("level >= ?", level)
      @level = params[:level]
    end

    collection = collection.query(params[:q]) if params[:q].present?
    collection = collection.page(params[:page])
    per_page = params[:per_page] && (1..50).include?(params[:per_page].to_i) ? params[:per_page].to_i : 50
    collection = collection.per_page(per_page)
    @notifications = collection.decorate
  end

  def create
    exception = env["action_dispatch.exception"]
    @notification = Notification.new(:exception => exception, :request => request)

    # Filter for errors that should not be saved
    if ["ActiveRecord::RecordNotFound", "ActionController::RoutingError"].include?(exception.class.to_s)
      @notification.status = request.headers["PATH_INFO"][1..-1]
    else
      @notification.save
    end

    respond_with(@notification) do |format|
      format.json { render json: { error: @notification.public_message }, status: @notification.status }
      format.xml  { render xml: @notification.public_message, root: "error", status: @notification.status }
      format.html { render :show, status: @notification.status, layout: !request.xhr? }
      format.rss { render :show, status: @notification.status, layout: false }
    end
  end

  def destroy
    @servers = ENV['SERVERS'].split(",")
    @notification = Notification.find(params[:id])
    if params[:filter] == "class_name"
      Notification.where(:class_name => @notification.class_name).update_all(:unresolved => false)
    elsif params[:filter] == "source"
      Notification.where(:source_id => @notification.source_id).update_all(:unresolved => false)
    elsif params[:filter] == "article_id"
      Notification.where(:article_id => @notification.article_id).update_all(:unresolved => false)
    else
      Notification.where(:message => @notification.message).update_all(:unresolved => false)
    end

    collection = Notification
    if params[:source]
      collection = collection.includes(:source)
                   .where("sources.name = ?", params[:source])
                   .references(:source)
      @source = Source.where(name: params[:source]).first
    end
    if params[:class_name]
      collection = collection.where(:class_name => params[:class_name])
      @class_name = params[:class_name]
    end
    collection = collection.query(params[:q]) if params[:q]

    @notifications = collection.paginate(:page => params[:page])
    respond_with(@notifications) do |format|
      if params[:article_id]
        id_hash = Article.from_uri(params[:article_id])
        key, value = id_hash.first
        @article = Article.where(key => value).first
        format.js { render :notification }
      else
        format.js { render :index }
      end
    end
  end

  def routing_error
    render json: { error: "The page you are looking for doesn't exist." }, status: :not_found
  end
end
