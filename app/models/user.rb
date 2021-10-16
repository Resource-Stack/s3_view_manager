class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :email, presence: true, uniqueness:true
  #validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  #validates :phone,   :presence => true,
              #:numericality => true,
              #:length => { :minimum => 10, :maximum => 15 }
  validates :user_group_id, presence: true
  
  #validates :password,  presence: true, on: :create
 

  #has_secure_password
  #belongs_to :user_groups
  belongs_to :user_groups, :class_name => "UserGroup", :foreign_key => :user_group_id

end
