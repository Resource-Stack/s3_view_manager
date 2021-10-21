class S3ConfigsController < ApplicationController
	before_action :check_admin, :set_s3config, only: [:show, :edit, :update, :destroy,:change_status]
	#layout 'admin_custom'
	# GET /s3Configs
  # GET /s3Configs.json
  def index
    @s3Configs = S3Config.all
  end

  # GET /s3Configs/1
  # GET /s3Configs/1.json
  def show
  end

  # GET /s3Configs/new
  def new
    @s3config = S3Config.new
    #render plain: @s3config.inspect
  end

  # GET /s3Configs/1/edit
  def edit
  end

  # POST /s3Configs
  # POST /s3Configs.json

  def create
    @s3config = S3Config.new(profile_params)

    respond_to do |format|
      if @s3config.save
        flash[:notice] = 's3 config was successfully created.'
        format.html { redirect_to action: "index"}
        
        format.json { render :show, status: :created, location: @s3config }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @s3config.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /s3Configs/1
  # PATCH/PUT /s3Configs/1.json
  def update
    respond_to do |format|
      if @s3config.update(s3config_params)
        flash[:notice] = 's3config has been successfully updated.'
        format.html { redirect_to action: "index"}
        format.json { render :show, status: :ok, location: @s3config }
      else
        format.html { render :edit }
        format.json { render json: @s3config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /s3Configs/1
  # DELETE /s3Configs/1.json
  def destroy
     
    respond_to do |format|
        @s3config.destroy
        flash[:notice] = 's3config has been successfully deleted.'
        format.html { redirect_to action: "index" }
        format.json { head :no_content }
        
    end
  end

  def change_status
        respond_to do |format|
            if @s3config.status?
                @s3config.update_attribute(:status, false)
                flash[:notice] = 's3config has been successfully deactivated.'
                format.html { redirect_to action: "index" }
                format.json { head :no_content }
            else
                @s3config.update_attribute(:status, true)
                flash[:notice] = 's3config has been successfully activated.'
                format.html { redirect_to action: "index" }
                format.json { head :no_content }
            end 
        end 
  end
  
  def update
    #render plain: profile_params.inspect
    respond_to do |format|
      if @s3config.update(profile_params)
        flash[:notice] ="Account has been successfully updated." 
        format.html { redirect_to action: "index"}
        format.json { render :index, status: :ok, location: @s3config }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @s3config.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_s3config
      @s3config = S3Config.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:s3_config).permit(:access_key, :secret_key, :region, :account_id, :account_name, :status, :filter_tag)
    end
    def check_admin
        
      if current_user.is_admin==false &&  current_user.user_group_id!=2
        flash[:error] = "You are not authrised user1!"
        #return redirect_to bucket_list_path
        return redirect_to bucket_list_path
      end
    end 
end
