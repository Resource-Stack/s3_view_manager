# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

UserPermission.create([{ user_id: 1,s3_url:'',authorization_level: 
    {
        "test-buket-naresh"=>{
            "test-doc/July_month_timesheet.xlsx"=>['read', 'write','delete']
        } 
    } 
    
  }])