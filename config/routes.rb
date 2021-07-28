Rails.application.routes.draw do
  
  devise_for :users, controllers: { sessions: 'users/sessions' }
  devise_scope :user do
    root 'dashboard#index'
  end
  
  
end
