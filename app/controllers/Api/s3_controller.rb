class  Api::S3Controller < ApplicationController
    
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

    def saveS3Bucketlist()
        @buckets = S3_BUCKET.list_buckets
       return render json: @buckets
    end

    def folders
        bucket_name =  params[:bucket];
        fileobjects = S3_BUCKET.list_objects_v2(
            bucket: bucket_name,
            max_keys: 90,
            
            
          ).contents
          parentFolder=getParentLevelFolder(fileobjects) 

        return render json: parentFolder
        #return render json: [{"value":"Code","id":"/Code","size":4096,"date":1628764192,"type":"folder","data":[{"value":"New folder","id":"/Code/New folder","size":4096,"date":1628764192,"type":"folder"}]},{"value":"d","id":"/d","size":4096,"date":1628744400,"type":"folder"},{"value":"Music","id":"/Music","size":4096,"date":1628744400,"type":"folder"},{"value":"ф","id":"/ф","size":4096,"date":1628744400,"type":"folder"}]
    end
    def files
        bucket_name =  params[:bucket];
        id= params[:id]
        bucketObj = Aws::S3::Resource.new.bucket(bucket_name)
        fileobjects = S3_BUCKET.list_objects_v2(
            bucket: bucket_name,
            max_keys: 90,
            
            
          ).contents
        objFileFolder=getParentLevelFileFolder(fileobjects) 
        if id!="/"
            id=id.split('-lb-').first
            level=params[:id].split('-lb-').last
            objFileFolder=getnLevelFileFolder(bucket_name,id,level.to_i+1)
            #render plain: level.inspect
        end
        
        

        return render json:  objFileFolder
        #return render json: [{"value":"Code","id":"/Code","size":4096,"date":1628764192,"type":"folder"},{"value":"d","id":"/d","size":4096,"date":1628744400,"type":"folder"},{"value":"Music","id":"/Music","size":4096,"date":1628744400,"type":"folder"},{"value":"ф","id":"/ф","size":4096,"date":1628744400,"type":"folder"},{"value":"Screenshot (1).png","id":"/Screenshot (1).png","size":130519,"date":1628744558,"type":"image"}]
    end
    def info
        return render json: {"stats":{"free":18971783168,"total":83204141056,"used":64232357888},"features":{"preview":{"code":true,"document":true,"image":true},"meta":{"audio":true,"image":true}}}
    end
    def upload
        render plain: params[:file].inspect
    end

    private

    
    
   

     def getnLevelFileFolder(bucket_name,id,level)
        bucketObj = Aws::S3::Resource.new.bucket(bucket_name)
        infoFileFoler=[]
        arrFileFolder=bucketObj.objects(prefix: id, delimiter: '')
        arrFileFolder.each do |objFileFolder|
            arrKey = objFileFolder.key.split('/')
            if arrKey.length < level+1
                leadChar = objFileFolder.key.chars.last
                if leadChar =="/"
                    infoFileFoler << {value: objFileFolder.key.split('/').last ,id:"#{objFileFolder.key}-lb-#{level}", size: objFileFolder.size, date:objFileFolder.last_modified.to_time.to_i,type:'folder',data:[]}
                else
                    infoFileFoler << {value: objFileFolder.key.split('/').last ,id:"#{objFileFolder.key}-lb-#{level}", size: objFileFolder.size, date:objFileFolder.last_modified.to_time.to_i,type:fileType[File.extname(objFileFolder.key.rpartition('/').last)],data:[]}
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
                    s3Objects <<  {value: item.key.gsub("/", "") ,id:"#{item.key}-lb-1",date:item.last_modified.to_time.to_i,type:"folder",data:[]}
                else
                    s3Objects <<  {value: item.key.gsub("/", "") ,size: item.size, id:"#{item.key}-lb-1",date:item.last_modified.to_time.to_i,type:fileType[File.extname(item.key.rpartition('/').last).to_str],data:[]}
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

