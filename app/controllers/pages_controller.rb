class PagesController < ApplicationController
  respond_to :html
  
  skip_before_action :authenticate_user!
  skip_before_action :set_locale, only: [:home]
  skip_before_action :persist_locale, only: [:home]
  before_action :redirect_to_locale_if_not_set, only: [:home]

  def home
    @localized_page = LocalizedPage.get_by_current_locale
    @general_contact = GeneralContact.new
  end
end
