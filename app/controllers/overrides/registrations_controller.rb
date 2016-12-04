module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController

    before_filter :configure_sign_up_params, only: [:create]
    before_filter :configure_account_update_params, only: [:update]

    protected

      def update_resource(resource, params)
        resource.update_without_password(params)
      end

    private

      def configure_sign_up_params
        devise_parameter_sanitizer.for(:sign_up).push(:name, :email, :password, :password_confirmation, :image, :image_cache)
      end

      def configure_account_update_params
        devise_parameter_sanitizer.for(:account_update).push(:name, :email, :password, :password_confirmation, :image, :image_cache)
      end
  end
end
