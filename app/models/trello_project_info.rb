# == Schema Information
#
# Table name: trello_project_infos
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  board_id     :string
#  todo_list_id :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TrelloProjectInfo < ActiveRecord::Base
  belongs_to :project, class_name: :TrelloProject, foreign_key: 'project_id'

  validates_uniqueness_of :board_id
  # validates_presence_of :board_id, :todo_list_id
end
