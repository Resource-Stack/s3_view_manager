class s3ConfigController < ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy,:change_status]
	#layout 'admin_custom'
	# GET /users
  # GET /users.json
  def index
    @users = s3Config.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    #render plain: @user.inspect
  end

  # GET /users/1/edit
  def edit
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
  fhh=s3Config.find(params[:id])
    #render plain: @user.inspect
  end
  def update
    @s3Config = s3Config.find(params[:id])
    respond_to do |format|
      if @s3Config.update(params)
        flash[:notice] = 'Account has been successfully updated.'
        format.html { redirect_to action: "index"}
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
      @user = s3Config.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:user).permit(:access_key, :secret_key, :region, :account_id, :account_name)
    end
end
