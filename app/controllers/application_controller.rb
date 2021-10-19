class ApplicationController < ActionController::Base
    before_action :authenticate_user!, :init_aws_config, except: [:bucket_list,:info,:sync_s3_bucket]
     # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
        new_user_session_path
    end
    def after_sign_in_path_for(resource_or_scope)
        bucket_list_path
    end
    def checkPermission(buket_name, obj_key=nil,permission_acc=nil)
        arrBucket=S3Bucket.where(name:buket_name ).first
        if current_user.is_admin==false && current_user.user_group_id!=2
            arrData=  UserPermission.where(user_id: current_user.id,s3_id:arrBucket.id).first
            if arrData.nil?
                flash[:error] = "You are not authrised user1!"
                #return redirect_to bucket_list_path
                return redirect_back(fallback_location: bucket_list_path)
            end
        end
    end 
    
    def checkPermissionAjax(buket_name, obj_key=nil,permission_acc=nil)
        #current_user
        arrBucket=S3Bucket.where(name:buket_name ).first

        dataRes={"message"=>"","status"=>true}
        if current_user.is_admin==false
            arrData=  UserPermission.where(user_id: current_user.id,s3_id:arrBucket.id).first
            if arrData.nil?
                
                dataRes ={"message"=>"You are not authrised user!","status"=>false}
            end
        end
        return dataRes
    
    end
    def checkPermissionB(buket_name, obj_key=nil,permission_acc=nil)
        #current_user
        if current_user.is_admin==false
            arrData=  UserPermission.where(user_id: current_user.id).first
            if arrData.nil?
                flash[:error] = "You are not authrised user!"
                #return redirect_to bucket_list_path
                return redirect_back(fallback_location: bucket_list_path)
            end
            arrPermissionHash=arrData.authorization_level
            #byebug
            if arrPermissionHash.keys.include?(buket_name)
                if !obj_key.nil?
                    if arrPermissionHash[buket_name].keys.include?(obj_key)
                        if !permission_acc.nil?
                            if !arrPermissionHash[buket_name][obj_key].include?(permission_acc)
                                flash[:error] = 'You are not authorize to access this object!'
                                #redirect_to bucket_list_path
                                return redirect_back(fallback_location: bucket_list_path)
                                
                            end
                        end
                    else
                        flash[:error] = "You don't have permission  to access this object!"
                        redirect_back(fallback_location: bucket_list_path)
                        
                    end
                end
                #render plain: " hey #{arrPermissionHash.keys.inspect}"
            else
                flash[:error] = "You don't have  permission  to access this bucket !"
                #redirect_to bucket_list_path
                return redirect_back(fallback_location: bucket_list_path)
            end 
        end
      
    
    end

    def checkPermissionAjaxB(buket_name, obj_key=nil,permission_acc=nil)
        #current_user
        dataRes={"message"=>"","status"=>true}
        if current_user.is_admin==false
            arrData=  UserPermission.where(user_id: current_user.id).first
            if arrData.nil?
                
                dataRes ={"message"=>"You are not authrised user!","status"=>false}
            end
            arrPermissionHash=arrData.authorization_level
            
            if arrPermissionHash.keys.include?(buket_name)
                if !obj_key.nil?
                    if arrPermissionHash[buket_name].keys.include?(obj_key)
                        if !permission_acc.nil?
                            if !arrPermissionHash[buket_name][obj_key].include?(permission_acc)
                                
                                dataRes= {"message"=>"You are not authorize to access this object!","status"=>false}
                                
                            end
                        end
                    else
                        
                        dataRes= {"message"=>"You don't have permission  to access this object!","status"=>false}
                        
                    end
                end
                #render plain: " hey #{arrPermissionHash.keys.inspect}"
            else
                dataRes ={"message"=>"You don't have  permission  to access this bucket!","status"=>false}
            end 
        end
        return dataRes
    
    end
    def syncS3Bucket()
        @buckets = @S3_Client.list_buckets.buckets
        @buckets.each do |bucket| 
            begin
                @resp = @S3_Client.get_bucket_tagging({
                    bucket: bucket.name 
                })
                
                if !@resp.nil?
                    arrtagset=@resp.tag_set[0]
                    if arrtagset.key=='is_developer'
                        arrRes=S3Bucket.find_by(name: bucket.name)
                        if arrRes.nil? 
                            S3Bucket.create(name: bucket.name, :s3_config_id=>current_user.s3_config_id ,:url=>bucket.name,  :status=>1,:creation_date=>bucket.creation_date)
                        end

                    end
                end
                
                rescue StandardError
                    next
            end

        end
        
    end
   

    
    
    private

    def init_aws_config
        if(!current_user.nil?)
            arrConfig= S3Config.find(current_user.s3_config_id)
            Aws.config.update({
                region: 'ap-south-1',
                credentials: Aws::Credentials.new(arrConfig.access_key, arrConfig.secret_key)
            })
            @S3_Client = Aws::S3::Client.new(region: arrConfig.region) 
            
            #logger.debug(" arrconfig #{arrConfig.inspect}")
        end
    end
     
    
    
end
