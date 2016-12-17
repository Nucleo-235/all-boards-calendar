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
#  external_url   :string
#

class TrelloTask < Task
  validates_presence_of :trello_card_id

  before_update :check_to_update_card

  def update_with_card(card)
    begin
      @trello_card = card
      self.name = card.name
      self.description = card.desc
      self.due_date = card.due
      self.completed = card.closed || (card.badges && card.badges["dueComplete"])
      self.assigned = card.member_ids.length > 0
      self.trello_list_id = card.list_id
      self.external_url = card.url
      self.save!
    ensure
      @trello_card = nil
    end
    self
  end

  def self.create_with_card(project, card)
    task = TrelloTask.new
    task.project = project
    task.trello_card_id = card.id
    task.update_with_card(card)
  end

  def self.is_valid?(trello_card, project, trello_member_id)
    if trello_card.member_ids.include? trello_member_id
      if !project.user.user_preference || ((trello_card.labels.map { |l| l.name  }) & project.user.user_preference.excluded_labels_list).empty?
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def self.sync_task(trello_card, project, trello_member_id)
    lastSync = Time.new
    
    # puts trello_card.inspect
    # logger.debug trello_card

    if trello_card.class.name == Trello::Card.name
      if TrelloTask.is_valid?(trello_card, project, trello_member_id)
        task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
        if task
          task.update_with_card(trello_card)
        else
          task = TrelloTask.create_with_card(project, trello_card)
        end

        labels = []
        trello_card.labels.each do |trello_label|
          labels.push Label.find_or_create_by(name: trello_label.name)
        end

        existing_labels = task.task_labels.map { |e| e.label.name }
        labels.each do |label|
          created_label = task.task_labels.find_or_create_by(label: label)
          existing_labels.delete(label.name) if existing_labels.include? label.name
        end

        # remove labels que nao foram mais encontradas
        existing_labels.each do |not_found_label_name|
          task.task_labels.where(label: Label.find_by(name: not_found_label_name)).destroy_all
        end
        TrelloTask.update_last_sync(task, lastSync)
      else
        task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
        if task
          task.update_with_card(trello_card) 
          TrelloTask.update_last_sync(task, lastSync)
        end
      end
    else
      task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
      task.destroy if task && trello_card.type == :deleted_card
    end

    task
  end
  
  def check_to_update_card
    if !@trello_card
      begin
        @trello_card = Trello::Card.from_response project.user.trello_client.get("/cards/#{trello_card_id}")
        
        if @trello_card
          if @trello_card.due != self.due_date
            @trello_card.due = self.due_date
            @trello_card.client = project.user.trello_client
            @trello_card.save
          end
        end
      ensure
        @trello_card = nil
      end
    end
  end

  private

    def self.update_last_sync(task, lastSync)
      task.last_synced_at = lastSync
      task.save
    end
end
