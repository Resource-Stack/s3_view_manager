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
  validates :is_admin, inclusion: { in: [ true, false ] }
  
  #validates :password,  presence: true, on: :create
 

  #has_secure_password
  #belongs_to :s3_configs

end
