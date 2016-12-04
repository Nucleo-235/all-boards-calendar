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

class TrelloProjectMember < ProjectMember
  validates_presence_of :trello_member_id
end
