class LocalizedGroup
  attr_accessor :prefix_key
  attr_accessor :page

  def values
    if !@values
      @values = page.localized_values.where('key like ?', self.prefix_key + '_%')
    end
    @values
  end

  def get_value(property)
    self.values.find_by(key: self.prefix_key + '_' + property)
  end
end