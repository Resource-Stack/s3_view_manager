class UserGroupsController < ApplicationController
  before_action  :check_admin, :set_user_group, only: %i[ show edit update destroy index]

  # GET /user_groups or /user_groups.json
  def index
    @user_groups = UserGroup.all
  end

  # GET /user_groups/1 or /user_groups/1.json
  def show
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
  end

  # GET /user_groups/1/edit
  def edit
  end

  # POST /user_groups or /user_groups.json
  def create
    @user_group = UserGroup.new(user_group_params)

    respond_to do |format|
      if @user_group.save
        flash[:notice] = 'User group was successfully created.'
        format.html { redirect_to action: "index"}
        
        format.json { render :show, status: :created, location: @user_group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_groups/1 or /user_groups/1.json
  def update
    respond_to do |format|
      if @user_group.update(user_group_params)
        flash[:notice] ="User group was successfully updated." 
        format.html { redirect_to action: "index"}
        format.json { render :index, status: :ok, location: @user_group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1 or /user_groups/1.json
  def destroy
    @user_group.destroy
    respond_to do |format|
      format.html { redirect_to user_groups_url, notice: "User group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_group
      if !params[:id].nil?
         @user_group = UserGroup.find(params[:id])
      end
    end
    def check_admin
        
      if current_user.is_admin==false 
        flash[:error] = "You are not authrised user1!"
        #return redirect_to bucket_list_path
        return redirect_to bucket_list_path
      end
    end 


    # Only allow a list of trusted parameters through.
    def user_group_params
      params.require(:user_group).permit(:title, :status)
    end
end
