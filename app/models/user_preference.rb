# == Schema Information
#
# Table name: user_preferences
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  excluded_labels :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserPreference < ActiveRecord::Base
  belongs_to :user

  after_save :update_excluded_list

  def excluded_labels_list
    @excluded_labels_list ||= self.excluded_labels ? self.excluded_labels.split(',') : []
  end

  def excluded_labels_list=(list)
    self.excluded_labels = list.join(',')
  end

  protected
    def update_excluded_list
      @excluded_labels_list = nil
    end
end
