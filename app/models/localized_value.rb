# == Schema Information
#
# Table name: localized_values
#
#  id                :integer          not null, primary key
#  localized_page_id :integer
#  key               :string
#  value             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class LocalizedValue < ActiveRecord::Base
  belongs_to :localized_page

  def get_grouped_value_order_key(prefix)
    prefix_length = prefix.length + 1
    without_prefix = key[prefix_length, key.length - prefix_length]
    order_index = without_prefix.index('_')
    without_prefix[0, order_index]
  end

  def get_grouped_value_order(prefix)
    get_grouped_value_order_key(prefix).to_i
  end
end
