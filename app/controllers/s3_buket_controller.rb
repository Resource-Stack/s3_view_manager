class S3BuketController < ApplicationController

        def s3_bucket_list()
            @dbbuckets = S3Bucket.all
            render plain: @dbbuckets.inspect
        end
        def sync_s3_bucket()
            arrConfig= S3Config.find(current_user.s3_config_id)
            Aws.config.update({
                region: 'ap-south-1',
                credentials: Aws::Credentials.new(arrConfig.access_key, arrConfig.secret_key)
            })
            @S3_Client = Aws::S3::Client.new(region: arrConfig.region) 
            @buckets =  @S3_Client.list_buckets.buckets
            arrRes=S3Bucket.find_by(name: 'bucket-test-12oct1')
            render plain:arrRes.inspect
            @buckets.each do |bucket| 
                #arrRes=S3Bucket.find_by(name: bucket.name)
                
                #S3Bucket.find_or_create_by(name: bucket.name,  :url=>bucket.name,  :status=>1,:creation_date=>bucket.creation_date)
            end
            
            #render json: @buckets
        end
        #handle_asynchronously :sync_s3_bucket, :run_at => Proc.new { 1.minutes.from_now }
end
