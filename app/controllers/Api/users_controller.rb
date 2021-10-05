class  Api::UsersController < Devise::RegistrationsController
    protect_from_forgery with: :null_session
    before_action :configure_sign_up_params
    def user_reg

        return render json:{:message=>"hii the", :data => sign_up_params}
    end
    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
        devise_parameter_sanitizer.permit(:sign_up, keys: [:oim_id])
    end
end

