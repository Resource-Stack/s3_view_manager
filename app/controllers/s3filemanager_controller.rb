class S3filemanagerController < ApplicationController
    def fileType
        @fileType={
            ".docx"=> "document",
            ".doc"=> "document",
            ".odt"=> "document",
            ".xls" => "document",
            ".xlsx"=> "document",
            ".pdf"=> "document",
            ".djvu"=> "document",
            ".djv"=> "document",
            ".pptx"=> "document",
            ".ppt"=> "document",
            ".html"=> "code",
            ".htm"=> "code",
            ".js"=> "code",
            ".json"=> "code",
            ".css"=> "code",
            ".scss"=> "code",
            ".sass"=> "code",
            ".less"=> "code",
            ".php"=> "code",
            ".sh"=> "code",
            ".coffee"=> "code",
            ".txt"=> "code",
            ".md"=> "code",
            ".go"=> "code",
            ".yml"=> "code",
            ".mpg"=> "video",
            ".mp4"=> "video",
            ".avi"=> "video",
            ".mkv"=> "video",
            ".ogv"=> "video",
            ".png"=> "image",
            ".jpg"=> "image",
            ".jpeg"=> "image",
            ".webp"=> "image",
            ".gif"=> "image",
            ".tiff"=> "image",
            ".tif"=> "image",
            ".svg"=> "image",
            ".mp3"=> "audio",
            ".ogg"=> "audio",
            ".flac"=> "audio",
            ".wav"=> "audio",
            ".zip"=> "archive",
            ".rar"=> "archive",
            ".7z"=> "archive",
            ".tar"=> "archive",
            ".gz"=> "archive"
        }
    end
    layout :resolve_layout
    # List of all buckets
    def index
        syncS3Bucket()
        @buckets = S3Bucket.where(:s3_config_id=>current_user.s3_config_id)
        arrBucketids= UserPermission.where(user_id: current_user.id).pluck(:s3_id)
        
        if(current_user.is_admin!=true && current_user.user_group_id!=2)
            @buckets= S3Bucket.where(id: arrBucketids) 
        end
        
        #render plain: current_user.user_group_id.inspect
    end
    def edit
        @bucket_id=params[:bucket_id]
        @bucket = S3Bucket.find(@bucket_id)
        @userall= User.find_by_sql("SELECT * FROM `users` WHERE user_group_id!=2 and is_admin=0")
        @users=[]
        @userall.each do |user|
            @users<< [user.name, user.id]
        end
        @selected_user= UserPermission.where(s3_id: @bucket_id,user_group_id:0).pluck(:user_id)
        @userallGroups= UserGroup.find_by_sql("SELECT * FROM `user_groups` WHERE id!=2 and status=1")
        @user_groups=[]
        @userallGroups.each do |user|
            @user_groups<< [user.title, user.id]
        end
        @selected_user_groups= UserPermission.where(s3_id: @bucket_id).pluck(:user_group_id)
        #render plain: @user_groups.inspect
    end
    def update
        if params[:s3][:users].present? || params[:s3][:user_groups].present? 
            #render plain:  params.inspect  
            objUser=[]
            group_user_ids=[]
            UserPermission.where(:s3_id => params[:s3][:bucket_id]).destroy_all
            if params[:s3][:user_groups].present? 
                
                params[:s3][:user_groups].each do | user_group_id |
                    group_user_ids = User.where(user_group_id: user_group_id).pluck(:id)
                    group_user_ids.each do | user |
                        objUser << UserPermission.create(user_id:user, :s3_id=>params[:s3][:bucket_id],:authorization_level=>"",:user_group_id=>user_group_id)
                    end
                end
            end
           
            if params[:s3][:users].present?
                userandUsergroup=(params[:s3][:users]+group_user_ids).uniq
                params[:s3][:users].each do | user |
                    objUser << UserPermission.create(user_id:user, :s3_id=>params[:s3][:bucket_id],:authorization_level=>"",:user_group_id=>0)
=begin                    
                    resUserpermission=UserPermission.where(:user_id=>user,:s3_id=>params[:s3][:bucket_id]).first
                    logger.debug("resUserpermission #{resUserpermission.inspect}")
                    logger.debug("check nil value: #{resUserpermission.nil?}")
                    if resUserpermission.nil?
                        objUser << UserPermission.create(user_id:user, :s3_id=>params[:s3][:bucket_id],:authorization_level=>"",:user_group_id=>0)
                    end
=end                    
                end
            end
            #render plain:objUser.inspect
            
                flash[:notice] = "Bucket updated successfully!"
                return redirect_to bucket_list_path
          
         
            
        end
    end

   
    def create()
        
        if params[:s3][:bucket].present?
            
            respond_to do |format|
                response = @S3_Client.create_bucket(bucket: params[:s3][:bucket])
                @S3_Client.put_bucket_tagging({
                    bucket: params[:s3][:bucket],
                    tagging: {
                        tag_set: [
                          {
                            key: @filter_tag, 
                            value: "true", 
                          }, 
                          
                        ], 
                      },
                })
                if response.location.include? params[:s3][:bucket]
                    #syncS3Bucket()
                    flash[:notice] = 'Bucket has been successfully created.'
                    format.html { redirect_to action: "index" }
                else
                    flash[:error] = 'Something went wrong!'
                    format.html { redirect_to action: "index" }
                end
                rescue StandardError => e
                    flash[:error] = e.message
                    format.html { redirect_to action: "index" }
            end
        end
    end
    



    def new()
        
    end

    def bucket_info()
        bucket_name =  params[:bucket];
        obj_key=""
        id= params[:id]
        @key=params[:id]
        
        fileobjects = @S3_Client.list_objects_v2(
            bucket: bucket_name,
            max_keys: 90,
            
            
          ).contents
        @objFileFolder=getParentLevelFileFolder(fileobjects) 
        #render plain: id.empty?.inspect
        if !id.nil? && !id.empty? && id!="/"
            id=id.split('-lb-').first
            
            level=params[:id].split('-lb-').last
            @objFileFolder=getnLevelFileFolder(bucket_name,id,level.to_i+1)
            #render plain: id.inspect
            if @objFileFolder.empty? && id.last!="/"
                permission=checkPermissionAjax(bucket_name, id,'read')
                #render plain:permission['status'].inspect
                if permission['status']!=false
                    download_file(bucket_name,id)
                else
                    flash[:error]= permission['message']
                    return redirect_back(fallback_location: bucket_list_path)
                end
                #redirect_to "#{download_obj_file_path(bucket_name)}?key=#{id}"
            end
        end
        @objFileFolder
        @folder_key=id
        @bucket_name=bucket_name
        #checkPermission(bucket_name)

    end

    def download_obj_file()
        
        bucket=params[:bucket]
        key=params[:key]
        filename= params[:key].split("/").last
        
        localPath="#{Rails.public_path}/downloads/#{filename}"
        
        bucketObj = Aws::S3::Resource.new.bucket(bucket)
        sourceObj = bucketObj.object(key)
        sourceObj.get(response_target: localPath)
        send_file localPath


    end
    
    def add_file()
        
        @bucket=params[:bucket]
        @id=params[:key]
        @key=''
        if !@id.nil? && @id!="/"
            @key=@id.split('-lb-').first
        end
        #render plain: @key.inspect
        checkPermission(@bucket, @key,'write')
        
    end
    def post_add_file()

        if params[:s3][:folder].present?
            bucket=params[:s3][:bucket]
            folder_name=params[:s3][:key]
            doc_anme= "#{params[:s3][:folder]}/"
            objSuccess=create_folder(@S3_Client,bucket,folder_name,doc_anme)
            #render plain: objSuccess.inspect
            if objSuccess== true
                flash[:notice] = "Folder created successfully!"
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            else
                flash[:error] = objSuccess
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            end
        end
        if params[:s3][:doc].present?
            file_header = params[:s3][:doc]
            doc_anme  = file_header.original_filename
            FileUtils.mkdir_p "#{Rails.public_path}/uploads/"
            path_to_file_header= "#{Rails.public_path}/uploads/#{doc_anme}"
            File.delete(path_to_file_header) if File.exist?(path_to_file_header) # delete old image
            File.open(Rails.root.join('public','uploads', doc_anme), 'wb') do |f|
                f.write(file_header.read)
            end
            
            bucket=params[:s3][:bucket]
            folder_name=params[:s3][:key]
            
            objSuccess=upload_file_to_folder(@S3_Client,bucket,file_header)
           
            if objSuccess== true
                flash[:notice] = "Document uploaded successfully!"
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            else
                flash[:error] = objSuccess
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            end
            
            
        end
    end
    def delete_obj()
        bucket=params[:bucket]
        key=params[:key]
        if !key.nil? && key!="/"
            key=key.split('-lb-').first
        end
        permission=checkPermissionAjax(bucket, key,'delete')

        if permission['status']==true
            @S3_Client.delete_object({
                bucket: bucket, 
                key: key, 
            })
            
            flash[:notice] = "Document deleted successfully!"
            return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:id]
        else
            flash[:error]= permission['message']
            return redirect_back(fallback_location: bucket_list_path)
        end
        
        rescue StandardError => e
                    flash[:error] = e.message
                    return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:id]
    end        
    def deleteFolderContent 
        folder_name= params[:folder]
        if !folder_name.empty?
            folder_path= "#{Rails.public_path}/#{folder_name}/"
            FileUtils.remove_entry(folder_path,:secure=>true)
        end 
        render plain: folder_name.inspect

    end

    private
        
        def download_file(bucket,key)
             
            filename= key.split("/").last
            FileUtils.mkdir_p "#{Rails.public_path}/downloads/"
            localPath="#{Rails.public_path}/downloads/#{filename}"
            bucketObj = Aws::S3::Resource.new.bucket(bucket)
            sourceObj = bucketObj.object(key)
            sourceObj.get(response_target: localPath)
            send_file localPath
           

        end
        def create_folder(s3_client, bucket_name, folder_name, file_name)
            s3_client.put_object(
            body: file_name,
            bucket: bucket_name,
            key: folder_name + file_name
            )
            
            return true
            rescue StandardError => e
                return  e.message
        end
        def upload_file_to_folder(s3_client, bucket_name, file_header)
            
            bucketObj = Aws::S3::Resource.new.bucket(bucket_name)
            obj = bucketObj.object(file_header.original_filename)
            # Upload the file
            obj.put(body: file_header.to_io)
            return true
            rescue StandardError => e
                return  e.message
        end
        def resolve_layout
            case action_name
           
            when "index"
            "application"
            else
            "application"
            end
        end
        def getnLevelFileFolder(bucket_name,id,level)
            bucketObj = Aws::S3::Resource.new.bucket(bucket_name)
            infoFileFoler=[]
            arrFileFolder=bucketObj.objects(prefix: id, delimiter: '')
            arrFileFolder.each do |objFileFolder|
                arrKey = objFileFolder.key.split('/')
                if arrKey.length < level+1
                    leadChar = objFileFolder.key.chars.last
                    if leadChar =="/"
                        infoFileFoler << {name: "#{objFileFolder.key.split('/').last}/" ,id:"#{objFileFolder.key}-lb-#{level}",  date:objFileFolder.last_modified,type:'folder',data:[]}
                    else
                        infoFileFoler << {name: objFileFolder.key.split('/').last  ,id:"#{objFileFolder.key}-lb-#{level}", size: objFileFolder.size, date:objFileFolder.last_modified,type:"#{File.extname(objFileFolder.key.rpartition('/').last).to_str.gsub('.','')} #{fileType[File.extname(objFileFolder.key.rpartition('/').last).to_str]}",data:[]}
                    end
                end
            end    
            return infoFileFoler.drop(1)
        end
    
        def getParentLevelFileFolder(fileObjects)
            s3Objects=[]
            
            fileObjects.each do  | item |
                arrKey = item.key.split('/')
                objFileName=item.key
                if arrKey.length < 2
                    if objFileName.include? "/"  
                        s3Objects <<  {name: "#{item.key.gsub("/", "")}/" ,id:"#{item.key}-lb-1",date:item.last_modified,type:"folder",data:[]}
                    else
                        s3Objects <<  {name: "#{item.key.gsub("/", "")}"  ,size: item.size, id:"#{item.key}-lb-1",date:item.last_modified,type:"#{File.extname(item.key.rpartition('/').last).to_str.gsub('.','')} #{fileType[File.extname(item.key.rpartition('/').last).to_str]} ",data:[]}
                    end
                end
            end
             return s3Objects
        end
    
        def getParentLevelFolder(fileObjects)
            s3Objects=[]
            
            fileObjects.each do  | item |
                arrKey = item.key.split('/')
                objFileName=item.key
                if arrKey.length < 2
                    if objFileName.include? "/"  
                        s3Objects <<  {value: item.key.gsub("/", "") ,id:"#{item.key}-lb-1",date:item.last_modified.to_time.to_i,type:"folder",data:[]}
                    end
                end
            end
             return s3Objects
        end

        def initializeS3Config()
            
        end
        

end