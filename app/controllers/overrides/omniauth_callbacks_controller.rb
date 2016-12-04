module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController   
    def omniauth_success
      super

      if @identity
        @identity.user = @resource
        @identity.save!
      end
    end
    def assign_provider_attrs(user, auth_hash)
      user.assign_attributes({
        name: auth_hash['info']['name'], 
        nickname: auth_hash['info']['nickname'],
        social_image: auth_hash['info']['image'], 
        phone: auth_hash['info']['phone']
      })
    end

    def get_resource_from_auth_hash
      @identity = Identity.find_for_oauth auth_hash

      @resource = @identity.user || current_user || OrganizedPerson.new({
        email: (@identity.email || ""),
        provider: @identity.provider,
        uid: (@identity.uid || @identity.email)
      })
      
      if @resource.new_record?
        @oauth_registration = true
        set_random_password
      end

      # sync user info with provider, update/generate auth token
      assign_provider_attrs(@resource, auth_hash)

      # assign any additional (whitelisted) attributes
      extra_params = whitelisted_params
      @resource.assign_attributes(extra_params) if extra_params

      @resource
    end

  end
end