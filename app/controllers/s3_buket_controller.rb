class S3BuketController < ApplicationController

        def s3_bucket_list()
            @dbbuckets = S3Bucket.all
            render plain: @dbbuckets.inspect
        end
        def sync_s3_bucket()
            @buckets = S3_BUCKET.list_buckets.buckets
            #render plain:@buckets.inspect
            @buckets.each do |bucket| 
                S3Bucket.find_or_create_by(name: bucket.name, :url=>bucket.name,  :status=>1,:creation_date=>bucket.creation_date)
            end
            
            render json: @buckets
        end
        #handle_asynchronously :sync_s3_bucket, :run_at => Proc.new { 1.minutes.from_now }
end
