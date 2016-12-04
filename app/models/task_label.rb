# == Schema Information
#
# Table name: task_labels
#
#  id         :integer          not null, primary key
#  task_id    :integer
#  label_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TaskLabel < ActiveRecord::Base
  belongs_to :task
  belongs_to :label
end
