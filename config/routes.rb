Rails.application.routes.draw do
  
  devise_for :users, controllers: { sessions: 'users/sessions' }
  root 'dashboard#index'
  devise_scope :user do
    #root 'dashboard#index'
    namespace :api do
      namespace :v2 do
        post 'user_reg', to: 'registrations#user_reg', as: 'user_reg'
      end
    end
  end

  get '/sync_s3_bucket', to: 's3_buket#sync_s3_bucket', as: 'sync_s3_bucket'
  get '/s3bucket/list', to: 's3_buket#s3_bucket_list', as: 's3bucket_create'
  get '/bucket_list', to: 's3filemanager#index', as: 'bucket_list'
  get '/bucket_info/:bucket', to: 's3filemanager#bucket_info', as: 'get_bucket_info'
  get '/add_file', to: 's3filemanager#add_file', as: 'add_file'
  post '/post_add_file', to: 's3filemanager#post_add_file', as: 'post_add_file'
  get '/delete_obj/:bucket', to: 's3filemanager#delete_obj', as: 'delete_obj'
  get '/create_bulket', to: 's3filemanager#create_bulket', as: 'create_bulket'
  get '/download_obj_file/:bucket', to: 's3filemanager#download_obj_file', as: 'download_obj_file'
  get '/deleteFolderContent', to: 's3filemanager#deleteFolderContent', as: 'deleteFolderContent'
  
  get '/bucket/edit/:bucket_id', to: 's3filemanager#edit', as: 'bucket_edit'
  post '/bucket/update/', to: 's3filemanager#update', as: 'bucket_update'
  namespace :api do
    get 'folders', to: 's3#folders', as: 'folders'
    get 'files', to: 's3#files', as: 'files'
    get 'info', to: 's3#info', as: 'info'
    post 'upload', to: 's3#upload', as: 'upload'
    get 'saveS3Bucketlist', to: 's3#saveS3Bucketlist', as: 'saveS3Bucketlist'
    #post 'user_reg', to: 'users#create', as: 'user_reg'
  end
end
