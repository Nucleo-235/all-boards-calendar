class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :set_locale
  before_action :persist_locale
  before_action :set_admin

  protected
    def redirect_to_locale_if_not_set
      if params[:locale]
        I18n.locale = params[:locale]
        # current_user_or_visitor.update(locale: I18n.locale.to_s)
      else
        locale = request_locale || I18n.default_locale
        redirect_to url_for(request.params.merge({ locale: locale }))
      end
    end

    def get_locale
      # params[:locale] || visitor_locale || request_locale || I18n.default_locale
      params[:locale] || request_locale || I18n.default_locale
    end
 
    def set_locale
      I18n.locale = get_locale
    end

    def persist_locale
      # current_user_or_visitor.update(locale: I18n.locale.to_s) if params[:locale]
    end

    def request_locale
      extra_locales = [:pt]
      locale = http_accept_language.preferred_language_from(I18n.available_locales + extra_locales)
      locale = 'pt-BR' if locale == :pt || locale == 'pt-pt' || locale == 'pt-PT'
      locale
    end

    def set_admin
      @is_admin = true && (!params[:view_as].present? || params[:view_as] != "user")
      @standard_inplace = @is_admin ? 'edit' : 'read'
    end
end
