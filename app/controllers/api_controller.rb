class ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!  

  def to_boolean(str)
    return true if str=="true" || str == true
    return false if str=="false" || str == false
    return nil
  end
end