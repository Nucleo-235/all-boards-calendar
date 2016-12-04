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

class ProjectMemberSerializer < ActiveModel::Serializer
  attributes :id, :trello_member_id
  has_one :project
  has_one :user
end
