class Api::V6::UsersController < Api::V6::BaseController
  before_filter :load_user, only: [:show, :edit, :destroy]
  load_and_authorize_resource

  def show
    @user = @user.decorate
  end

  def index
    load_index
    @users = @users.decorate
  end

  def edit
    if params[:id].to_i == current_user.id
      # user updates his account
      respond_with(@user) do |format|
        format.js { render :show }
      end
    else
      # admin updates user account
      @user = User.find(params[:id])
      @reports = Report.available(@user.role)
      doc = Doc.find("api")
      @doc = DocDecorator.decorate(doc)
      load_index
      respond_with(@users) do |format|
        format.js { render :index }
      end
    end
  end

  def update
    if params[:id].to_i == current_user.id
      # user updates his account

      load_user

      if params[:user][:subscribe]
        report = Report.find(params[:user][:subscribe])
        @user.reports << report
      elsif params[:user][:unsubscribe]
        report = Report.find(params[:user][:unsubscribe])
        @user.reports.delete(report)
      else
        sign_in @user, :bypass => true if @user.update_attributes(safe_params)
      end

      respond_with(@user) do |format|
        format.js { render :show }
      end
    else
      # admin updates user account
      @user = User.find(params[:id])
      @user.update_attributes(safe_params)

      load_index
      respond_with(@users) do |format|
        format.js { render :index }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    load_index
    respond_with(@users) do |format|
      format.js { render :index }
    end
  end

  def update_password
    load_user
    if @user.update_with_password(user_params)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end

  protected

  def load_user
    if user_signed_in?
      @user = current_user
      @reports = Report.available(@user.role)
      doc = Doc.find("api")
      @doc = DocDecorator.decorate(doc)
    else
      fail CanCan::AccessDenied.new("Please sign in first.", :read, User)
    end
  end

  def load_index
    collection = User
    if params[:role]
      collection = collection.where(:role => params[:role])
      @role = params[:role]
    end
    collection = collection.query(params[:query]) if params[:query]
    collection = collection.ordered

    @users = collection.paginate(:page => params[:page])
  end

  private

  def safe_params
    params.require(:user).permit(:name,
                                 :username,
                                 :email,
                                 :password,
                                 :password_confirmation,
                                 :subscribe,
                                 :unsubscribe,
                                 :role,
                                 :publisher_id,
                                 :authentication_token)
  end
end
