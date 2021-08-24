Aws.config.update({
    region: 'ap-south-1',
    credentials: Aws::Credentials.new(ENV['AWSACCESSKEY'], ENV['AWSSECRETKEY'])
})


S3_BUCKET = Aws::S3::Client.new(region: ENV['AWSREGION'])

#byebug  