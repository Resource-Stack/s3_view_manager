class CreateS3Buckets < ActiveRecord::Migration[6.1]
  def change
    create_table :s3_buckets do |t|

      t.timestamps
    end
  end
end
