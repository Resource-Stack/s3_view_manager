class SyncS3bucketWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    #p 'Hello World!'
    @buckets = S3_BUCKET.list_buckets.buckets
    @buckets.each do |bucket| 
        #S3Bucket.find_or_create_by(name: bucket.name, :url=>bucket.name,  :status=>1)
        S3Bucket.find_or_create_by(name: bucket.name, :url=>bucket.name,  :status=>1,:creation_date=>bucket.creation_date)
    end
    p "its done!"
  end
end
