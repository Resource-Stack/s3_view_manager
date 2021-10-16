class UsersController < ApplicationController
	before_action :check_admin, :set_user, only: [:show, :edit, :index, :update, :destroy,:change_status]
	#layout 'admin_custom'
	# GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @configall= S3Config.where(:status=>1)
    @config=[]
    @configall.each do |config|
        @config<< [config.account_name, config.id]
    end
    @selected_config= User.where(id: current_user.id).pluck(:s3_config_id)
    #render plain: @user.inspect
  end

  # GET /users/1/edit
  def edit
    @configall= S3Config.where(:status=>1)
    @config=[]
    @configall.each do |config|
        @config<< [config.account_name, config.id]
    end
    @selected_config= User.where(id: current_user.id).pluck(:s3_config_id)
  end

  # POST /users
  # POST /users.json
  def create
 
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User has been successfully created.'
        format.html { redirect_to action: "index" }
        format.json { render :index, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        flash[:notice] = 'User has been successfully updated.'
        format.html { redirect_to action: "index"}
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
     
    respond_to do |format|

        if(@user.is_admin==false)
          @user.destroy
          flash[:notice] = 'User has been successfully deleted.'
          format.html { redirect_to action: "index" }
          format.json { head :no_content }
        else
          flash[:error] = 'Super admin can not be deleted.'
          format.html { redirect_to action: "index" }
         
        end
    end
  end

  def change_status
        respond_to do |format|
            if @user.status?
                @user.update_attribute(:status, false)
                flash[:notice] = 'User has been successfully deactivated.'
                format.html { redirect_to action: "index" }
                format.json { head :no_content }
            else
                @user.update_attribute(:status, true)
                flash[:notice] = 'User has been successfully activated.'
                format.html { redirect_to action: "index" }
                format.json { head :no_content }
            end 
        end 
  end
  def profile
    @S3Config =S3Config.find(current_user.s3_config_id)
    if current_user.is_admin==false
      flash[:error] = "You are not authrised user!"
      #return redirect_to bucket_list_path
      return redirect_back(fallback_location: bucket_list_path)
    end
  end
  def profile_post
    @S3Config = S3Config.find(params[:id])
    respond_to do |format|
      if @S3Config.update(profile_params)
        flash[:notice] = 'Account has been successfully updated.'
        format.html { redirect_to action: "profile", id: @S3Config.id}
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if !params[:id].nil?
        @user = User.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation, :user_group_id,:s3_config_id)
    end
    def profile_params
      params.require(:S3Config).permit(:access_key, :secret_key, :region, :account_id, :account_name)
    end
    def check_admin
        
      if current_user.is_admin==false &&  current_user.user_group_id!=2
        flash[:error] = "You are not authrised user1!"
        #return redirect_to bucket_list_path
        return redirect_to bucket_list_path
      end
    end 
end
