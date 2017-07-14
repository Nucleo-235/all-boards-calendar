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
#  start_date     :datetime
#  all_day        :boolean
#  end_date       :datetime
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

      self.parse_date

      self.save!
    ensure
      @trello_card = nil
    end
    self
  end

  def parse_date!
    @trello_card = self

    begin
      self.parse_date
      self.save!
    ensure
      @trello_card = nil
    end
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
        task.destroy if task
        # if task
        #   task.update_with_card(trello_card)
        #   TrelloTask.update_last_sync(task, lastSync)
        # end
      end
    else
      task = project.tasks.find_by(type: TrelloTask.name, trello_card_id: trello_card.id)
      task.destroy if task && trello_card.type == :deleted_card
    end

    task
  end

  def trello_card
    Trello::Card.from_response project.user.trello_client.get("/cards/#{trello_card_id}")
  end

  def check_to_update_card
    if !@trello_card
      begin
        @trello_card = self.trello_card

        if @trello_card
          if @trello_card.due != self.due_date || (self.start_date && self.start_date_changed?) || (self.end_date && self.end_date_changed?)
            @trello_card.due = self.due_date
            @trello_card.name = self.name
            @trello_card.desc = self.description
            @trello_card.client = project.user.trello_client
            process_dates(@trello_card)
            @trello_card.save

            TrelloTask.sync_task(@trello_card, self.project, self.project.user.trello_member.id)
          end
        end
      ensure
        @trello_card = nil
      end
    end
  end

  def process_dates(trello_card)
    duration = 1
    duration_type = "h"
    if self.all_day
      duration_type = "d"
      duration = ( (self.end_date - self.start_date)/1.day ).floor.to_i
    else
      duration_minutes = ( (self.end_date - self.start_date)/1.minute )
      only_minutes = duration_minutes.to_i % 60
      if only_minutes == 40 || only_minutes == 20
        duration = duration_minutes
        duration_type = "m"
      elsif only_minutes == 0 || only_minutes == 15 || only_minutes == 30 || only_minutes == 45
        duration = duration_minutes / 60.0
        duration_type = "h"
      else
        duration = duration_minutes
        duration_type = "m"
      end
    end

    if duration > 0 && (duration != 1 || duration_type != "h")
      duration_s = sprintf("$%.2f", duration)
      trello_card.desc = trello_card.desc + "\r\r[](ABCalendar=>Time:(#{duration}#{duration_type}))"
    end
  end

  def parse_date
    if due_date
      parsed = try_parse_from_standard_format
      parsed = try_parse_from_trellius_format if !parsed
      parsed = try_parse_from_old_standard_format if !parsed
    end
    self
  end

  def try_parse_from_trellius_format
    allDay = false
    startDate = due_date.to_time
    endDate = (due_date - 1.hour).to_time

    regexList = [
      { property: "description", regex: /!\[Trellius Data - DO NOT EDIT!\]\(\)\[\]\(\{"start":"(.*)","end":"(.*)"\}\)/ }
    ]

    matched = nil;
    currentRegex = nil;
    while regexList.length > 0 && (!matched || matched.nil? || matched.length == 0) do
      currentRegex = regexList[0];
      regexList.delete_at(0);

      value = self[currentRegex[:property]]
      matched = currentRegex[:regex].match(value)
    end

    if matched && matched.length == 3
      # puts matched[0].to_s
      # puts matched[1].to_s
      # puts matched[2].to_s

      startDate = matched[1].to_time
      endDate = matched[2].to_time


      self.start_date = startDate;
      if endDate == startDate && self.due_date == startDate
        self.all_day = true
        self.end_date = endDate + 1.day
      else
        self.all_day = (endDate - startDate) >= 1.day
        self.end_date = endDate
      end
      self.description = self.description.gsub(matched[0], "")

      return true
    else
      return false
    end

    return true
  end

  def try_parse_from_standard_format
    allDay = false
    startDate = (due_date - 1.hour).to_time
    endDate = due_date.to_time

    regexList = [
      { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)(.*)/ },
      { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)\)(.*)/ },
      { property: "description", regex: /\[?\]?\(?ABCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)\)?(.*)/ },
      { property: "description", regex: /\[?\]?\(?ABCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)\)\)?(.*)/ }
    ]

    matched = nil;
    currentRegex = nil;
    while regexList.length > 0 && (!matched || matched.nil? || matched.length == 0) do
      currentRegex = regexList[0];
      regexList.delete_at(0);

      value = self[currentRegex[:property]]
      matched = currentRegex[:regex].match(value)
    end

    if (matched && (matched.length == 4 || matched.length == 3))
      delta = matched[1].to_f

      deltaType = 'h';
      if (matched.length == 4)
        deltaType = matched[2]
        deltaType = 'h' if (!deltaType || deltaType.length == 0)
      end

      newName = self.name;
      if (currentRegex[:property] == "name")
        if (matched.length == 4)
          newName = matched[3]
        else
          newName = matched[2]
        end
      end
      self.name = newName

      if (delta > 0)
        startDate = due_date - delta_to_time(delta, deltaType)
      else
        startDate = due_date + delta_to_time(delta, deltaType)
      end

      self.description = self.description.gsub(matched[0], "").strip
      self.start_date = startDate;
      self.end_date = endDate;
      self.all_day = (endDate - startDate) >= 1.day;

      return true
    end

    return false
  end

  def try_parse_from_old_standard_format
    allDay = false
    startDate = due_date.to_time
    endDate = (due_date + 1.hour).to_time

    regexList = [
      { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)(.*)/ },
      { property: "name", regex: /\(([-+]?[0-9]*\.?[0-9]+)\)(.*)/ },
      { property: "description", regex: /AllBoardsCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)([hmd]?)\)(.*)/ },
      { property: "description", regex: /AllBoardsCalendar=>Time:\(([-+]?[0-9]*\.?[0-9]+)\)(.*)/ }
    ]

    matched = nil;
    currentRegex = nil;
    while regexList.length > 0 && (!matched || matched.nil? || matched.length == 0) do
      currentRegex = regexList[0];
      regexList.delete_at(0);

      value = self[currentRegex[:property]]
      matched = currentRegex[:regex].match(value)
    end

    if (matched && (matched.length == 4 || matched.length == 3))
      delta = matched[1].to_f

      deltaType = 'h';
      if (matched.length == 4)
        deltaType = matched[2]
        deltaType = 'h' if (!deltaType || deltaType.length == 0)
      end

      newName = self.name;
      if (currentRegex[:property] == "name")
        if (matched.length == 4)
          newName = matched[3]
        else
          newName = matched[2]
        end
      elsif currentRegex[:property] == "description"
        self.description = self.description.gsub(matched[0], "")
      end
      self.name = newName

      if (delta > 0)
        endDate = due_date + delta_to_time(delta, deltaType)
      else
        startDate = due_date + delta_to_time(delta, deltaType)
        endDate = due_date.to_time;
      end
    end

    self.start_date = startDate;
    self.end_date = endDate;
    self.all_day = (endDate - startDate) >= 1.day;

    return true
  end

  private

    def self.update_last_sync(task, lastSync)
      task.last_synced_at = lastSync
      task.save
    end
end
