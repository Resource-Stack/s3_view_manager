# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

  #User.create([{ s3_config_id: 2},{user_group_id:0},{name: "Samir Hassan"},{email:"msamir@msamir.net"},{phone:"5712223333"},{encrypted_password:"$2a$12$s1h3z0u/WVWKdb0LEjRK9uumH.STgF04JPIICExSIaSHi5JhHlqQG"},{is_admin:1},{status:1 }])
  usergroups=UserGroup.create!([{title: "Developer", status:1},{title: "Admin",status:1},{title: "User", status:1}])
  users=User.create!([{ user_group_id: 1 , name:"Samir Hassan",email:"msamir@msamir.net",is_admin:1,status:1,password:"123456",phone:"5712223333"}])
 