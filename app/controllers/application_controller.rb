class ApplicationController < ActionController::Base
    before_action :authenticate_user!, except: [:bucket_list]
     # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
        new_user_session_path
    end
    def after_sign_in_path_for(resource_or_scope)
        bucket_list_path
    end
    def checkPermission(buket_name, obj_key=nil,permission_acc=nil)
        #current_user
        if current_user.is_admin==false
            arrData=  UserPermission.where(user_id: current_user.id).first
            if arrData.nil?
                flash[:error] = "You are not authrised user!"
                return redirect_to bucket_list_path
            end
            arrPermissionHash=arrData.authorization_level
            
            if arrPermissionHash.keys.include?(buket_name)
                if !obj_key.nil?
                    if arrPermissionHash[buket_name].keys.include?(obj_key)
                        if !permission_acc.nil?
                            if !arrPermissionHash[buket_name][obj_key].include?(permission_acc)
                                flash[:error] = 'You are not authorize to access this object!'
                                redirect_to bucket_list_path
                            end
                        end
                    else
                        flash[:error] = "You don't have permission  to access this object!"
                        redirect_to bucket_list_path
                    end
                end
                #render plain: " hey #{arrPermissionHash.keys.inspect}"
            else
                flash[:error] = "You don't have  permission  to access this bucket !"
                redirect_to bucket_list_path
            end 
        end
      
    
    end

    def checkPermissionAjax(buket_name, obj_key=nil,permission_acc=nil)
        #current_user
        if current_user.is_admin==false
            arrData=  UserPermission.where(user_id: current_user.id).first
            if arrData.nil?
                flash[:error] = "You are not authrised user!"
                return redirect_to bucket_list_path
            end
            arrPermissionHash=arrData.authorization_level
            
            if arrPermissionHash.keys.include?(buket_name)
                if !obj_key.nil?
                    if arrPermissionHash[buket_name].keys.include?(obj_key)
                        if !permission_acc.nil?
                            if !arrPermissionHash[buket_name][obj_key].include?(permission_acc)
                                flash[:error] = 'You are not authorize to access this object!'
                                redirect_to bucket_list_path
                            end
                        end
                    else
                        flash[:error] = "You don't have permission  to access this object!"
                        redirect_to bucket_list_path
                    end
                end
                #render plain: " hey #{arrPermissionHash.keys.inspect}"
            else
                flash[:error] = "You don't have  permission  to access this bucket !"
                redirect_to bucket_list_path
            end 
        end
      
    
    end
end
