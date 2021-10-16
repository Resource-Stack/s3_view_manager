class UserGroup < ApplicationRecord
    validates :title, presence: true
    validates :status, inclusion: { in: [ 1, 0] }
    #has_many :users
    has_many :users, :class_name => "User", :foreign_key => :user_group_id
end
