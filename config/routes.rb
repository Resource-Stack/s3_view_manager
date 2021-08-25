Rails.application.routes.draw do
  
  devise_for :users, controllers: { sessions: 'users/sessions' }
  root 'dashboard#index'
  devise_scope :user do
    #root 'dashboard#index'
  end

  get '/bucket_list', to: 's3filemanager#index', as: 'bucket_list'
  get '/bucket_info/:bucket', to: 's3filemanager#bucket_info', as: 'get_bucket_info'
  get '/add_file', to: 's3filemanager#add_file', as: 'add_file'
  post '/post_add_file', to: 's3filemanager#post_add_file', as: 'post_add_file'
  get '/delete_obj/:bucket', to: 's3filemanager#delete_obj', as: 'delete_obj'

  get '/create_bulket', to: 's3filemanager#create_bulket', as: 'create_bulket'
  
  get '/download_obj_file/:bucket', to: 's3filemanager#download_obj_file', as: 'download_obj_file'
  
  namespace :api do
    get 'folders', to: 's3#folders', as: 'folders'
    get 'files', to: 's3#files', as: 'files'
    get 'info', to: 's3#info', as: 'info'

    post 'upload', to: 's3#upload', as: 'upload'
  end
end
