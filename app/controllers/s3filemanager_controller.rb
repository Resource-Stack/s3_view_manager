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
        @buckets = S3_BUCKET.list_buckets.buckets
       
    end


   

    def create_bulket()
        S3_BUCKET.create_bucket(bucket: 'ex-bucket-56564tttdyrt')
        render plain: S3_BUCKET.inspect 
    end

    def bucket_info()
        
        bucket_name =  params[:bucket];
        
        id= params[:id]
        @key=params[:id]
        bucketObj = Aws::S3::Resource.new.bucket(bucket_name)
        fileobjects = S3_BUCKET.list_objects_v2(
            bucket: bucket_name,
            max_keys: 90,
            
            
          ).contents
        @objFileFolder=getParentLevelFileFolder(fileobjects) 
        #render plain: id.empty?.inspect
        if !id.nil? && !id.empty? && id!="/"
            id=id.split('-lb-').first
            
            level=params[:id].split('-lb-').last
            @objFileFolder=getnLevelFileFolder(bucket_name,id,level.to_i+1)
            #render plain: @objFileFolder.inspect
            if @objFileFolder.empty?
                return redirect_to "#{download_obj_file_path(bucket_name)}?key=#{id}"
            end
        end
        @objFileFolder
        
        @bucket_name=bucket_name
       

    end

    def download_obj_file()

        bucket=params[:bucket]
        key=params[:key]
        filename= params[:key].split("/").last
        #render plain: key.inspect 
        localPath="/var/www/html/storage/download/#{filename}"
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
    end
    def post_add_file()
        if params[:s3][:doc].present?
            file_header = params[:s3][:doc]
            doc_anme  = file_header.original_filename
            #doc_anme  =  File.basename(params[:s3][:doc])
            #render plain: doc_anme.inspect
            path_to_file_header= "#{Rails.public_path}/uploads/#{doc_anme}"
            File.delete(path_to_file_header) if File.exist?(path_to_file_header) # delete old image
            File.open(Rails.root.join('public','uploads', doc_anme), 'wb') do |f|
                f.write(file_header.read)
            end
            bucket=params[:s3][:bucket]
            folder_name=params[:s3][:key]
            
            objSuccess=upload_file_to_folder(S3_BUCKET,bucket,folder_name,doc_anme)
            #render plain: objSuccess.inspect
            if objSuccess== true
                flash[:notice] = "Document uploaded successfully!"
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            else
                flash[:error] = objSuccess
                return redirect_to controller: 's3filemanager', action: 'bucket_info', bucket: bucket, id: params[:s3][:id]
            end
            
            #return redirect_to "#{get_bucket_info_path}/#{bucket}?id=#{params[:s3][:id]}"
        end
    end

    private

        def upload_file_to_folder(s3_client, bucket_name, folder_name, file_name)
            s3_client.put_object(
            body: file_name,
            bucket: bucket_name,
            key: folder_name + file_name
            )
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

end