# == Schema Information
#
# Table name: identities
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider     :string
#  accesstoken  :string
#  refreshtoken :string
#  secret       :string
#  uid          :string
#  name         :string
#  email        :string
#  nickname     :string
#  image        :string
#  phone        :string
#  urls         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider, :user
  validates_uniqueness_of :uid, :scope => :provider
  validates_uniqueness_of :user, :scope => :provider

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth['provider'], uid: auth['uid'])
    identity = Identity.new({ provider: auth['provider'], uid: auth['uid'] }) if identity.nil?
    if auth['credentials']
      identity.accesstoken = auth['credentials']['token']
      identity.refreshtoken = auth['credentials']['refresh_token']
      identity.secret = auth['credentials']['secret']
    end
    identity.name = auth['info']['name']
    identity.email = auth['info']['email']
    identity.nickname = auth['info']['nickname']
    identity.image = auth['info']['image']
    identity.phone = auth['info']['phone']
    identity.urls = (auth['info']['urls'] || "").to_json
    identity
  end
end
