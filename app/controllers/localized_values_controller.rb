# == Schema Information
#
# Table name: localized_values
#
#  id                :integer          not null, primary key
#  localized_page_id :integer
#  key               :string
#  value             :string
#  created_at        :datetime
#  updated_at        :datetime
#

class LocalizedValuesController < ApplicationController
  respond_to :html, :json

  skip_before_action :verify_authenticity_token
  before_action :require_value

  def update
    @localized_value.update(localized_value_params)
    respond_with(@localized_value)
  end

  private
    def require_value
      @localized_value = LocalizedValue.find(params[:id])
    end

    def localized_value_params
      params.require(:localized_value).permit(:value)
    end
end
