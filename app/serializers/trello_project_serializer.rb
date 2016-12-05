# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  type                 :string
#  name                 :string           not null
#  slug                 :string
#  user_id              :integer
#  description          :text
#  documentation_url    :string
#  code_url             :string
#  assets_url           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public               :boolean          default(TRUE)
#  last_synced_at       :datetime
#  closed               :boolean          default(FALSE)
#  last_synced_tasks_at :datetime
#

class TrelloProjectSerializer < Project
  
  has_one :info
end
