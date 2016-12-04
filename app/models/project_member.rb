# == Schema Information
#
# Table name: project_members
#
#  id               :integer          not null, primary key
#  project_id       :integer
#  user_id          :integer
#  type             :string
#  trello_member_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ProjectMember < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_presence_of :project, :user
end
