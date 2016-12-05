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
#  last_synced_at :datetime
#

class TaskSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :description, :due_date, :completed, :assigned, :project_name

  has_many :labels

  def labels
    object.task_labels.map { |task_label| task_label.label.name  }
  end

  def project_name
    object.project.name
  end
end
