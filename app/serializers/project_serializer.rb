# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  type              :string
#  name              :string           not null
#  slug              :string
#  user_id           :integer
#  description       :text
#  documentation_url :string
#  code_url          :string
#  assets_url        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  public            :boolean          default(TRUE)
#  last_synced_at    :datetime
#  closed            :boolean          default(FALSE)
#

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :slug, :description, :documentation_url, :code_url, :assets_url, :tasks_count
  has_one :user
  # has_one :info
  
  has_many :valid_tasks, key: "tasks", serializer: TaskSerializer
  has_many :members

  def info
    object.info if object.respond_to? :info
  end

  def valid_tasks
    object.valid_tasks.limit(10)
  end

  def tasks_count
    object.valid_tasks.count
  end

  def members
    object.members.limit(10)
  end
end
