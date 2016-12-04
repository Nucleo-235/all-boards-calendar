# == Schema Information
#
# Table name: tasks
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  type           :string
#  name           :string
#  description    :text
#  due_date       :datetime
#  completed      :boolean          default(FALSE)
#  assigned       :boolean          default(FALSE)
#  sort_order     :integer
#  trello_card_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  trello_list_id :string
#

class TrelloTask < Task
  validates_presence_of :trello_card_id

  def update_with_card(card)
    self.name = card.name
    self.description = card.desc
    self.due_date = card.due
    self.completed = card.closed
    self.assigned = card.member_ids.length > 0
    self.trello_list_id = card.list_id
    self.save!
    self
  end

  def self.create_with_card(project, card)
    task = TrelloTask.new
    task.project = project
    task.trello_card_id = card.id
    task.update_with_card(card)
  end
end
