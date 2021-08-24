class DashboardController < ApplicationController
  
  def list_accessible_buckets_in_region(region)
    buckets = S3_BUCKET.list_buckets.buckets
    buckets_in_region = []
    buckets.each do |bucket|
      bucket_region = s3_client.get_bucket_location(
        bucket: bucket.name
      ).location_constraint
      if bucket_region == region
        buckets_in_region << bucket.name
      end
    end
    if buckets_in_region.count.zero?
      puts "No buckets accessible to you and also set to region '#{region}' " \
        'when initially created.'
      exit 1
    else
      puts "Buckets accessible to you and also set to region '#{region}' " \
        'when initially created:'
      buckets_in_region.each do |bucket_name|
        puts bucket_name
      end
    end
  rescue StandardError => e
    puts "Error getting information about buckets: #{e.message}"
    exit 1
  end
  
  # Full example call:
  def run_me
    region = 'ap-south-1'
    #s3_client = Aws::S3::Client.new(region: region)
  
    list_accessible_buckets_in_region(region)
  end
end
