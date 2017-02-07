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

require 'icalendar'

class Task < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project, :name

  has_many :task_labels, dependent: :destroy

  def to_ics
    if self.start_date
      event = Icalendar::Event.new
      event.dtstart = Icalendar::Values::Date.new(self.start_date.strftime("%Y%m%dT%H%M%S"))
      event.dtend = Icalendar::Values::Date.new(self.end_date.strftime("%Y%m%dT%H%M%S"))
      event.summary = self.name
      event.description = self.description
      event.location = self.project.name
      event.ip_class = "PUBLIC"
      event.created = self.created_at
      event.last_modified = self.updated_at
      event.uid = "#{self.id}"
      event.url = self.external_url ? self.external_url : "#{ENV['HOST_URL']}/#{self.project.user.uid}/events/#{self.id}"
      # event.add_comment("AF83 - Shake your digital, we do WowWare")
      event
    end
  end

  def parse_date
    if due_date
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

      # puts matched.to_json
    end

    self
  end

  def delta_to_time(delta, detalType)
    case detalType
      when 'h'
        delta.hours
      when 'm'
        delta.minutes
      when 'd'
        delta.days
      when 's'
        delta.seconds
      else
        delta.hours
      end
  end
end
