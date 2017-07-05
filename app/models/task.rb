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

  def to_ics(tzid = 'America/Sao_Paulo')
    if self.start_date && self.end_date
      event = Icalendar::Event.new
      # event.dtstart = Icalendar::Values::Date.new(self.start_date.strftime("%Y%m%dT%H%M%S"))
      # event.dtend = Icalendar::Values::Date.new(self.end_date.strftime("%Y%m%dT%H%M%S"))
      if self.all_day
        event.dtstart = Icalendar::Values::Date.new(self.start_date.strftime("%Y%m%dT%H%M%S"), 'tzid' => tzid)
        event.dtend = Icalendar::Values::Date.new(self.end_date.strftime("%Y%m%dT%H%M%S"), 'tzid' => tzid)
      else
        event.dtstart = Icalendar::Values::DateTime.new(self.start_date.strftime("%Y%m%dT%H%M%S"), 'tzid' => tzid)
        event.dtend = Icalendar::Values::DateTime.new(self.end_date.strftime("%Y%m%dT%H%M%S"), 'tzid' => tzid)
      end
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

  def delta_to_time(delta, detalType)
    case detalType
      when 'h'
        return delta.hours
      when 'm'
        return delta.minutes
      when 'd'
        return delta.days
      when 's'
        return delta.seconds
      else
        return delta.hours
      end
  end
end
