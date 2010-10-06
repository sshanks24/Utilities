
class LiebertXML

  attr_accessor :strings, :units, :data, :scales, :resolutions
  
  def initialize(gdd_file)
    File.open(gdd_file) do |config_file|
      @xml = REXML::Document.new(config_file)
    end
  end

  def version
    @xml.root.elements["//Version/LastDictionaryEntry"].text
  end

  def build_hashes
    puts "\nBuilding data hashes\n\n"
    @strings = build_string_id_hash("////String")
    @units = build_unit_id_hash("//UomDefn")
    @data = build_data_id_hash("//DataDictEntry")
    @scales = Hash.new
    @resolutions = Hash.new
    puts "Finished building hashes"
  end

  # This method builds the hash table that maps text IDs to strings.
  def build_string_id_hash(path_to_string)
    h = Hash.new
    @xml.root.elements.each(path_to_string) do |string|
      key = string.attribute('Id').to_s
      if string.text == nil then
        value = ""
      else
        value = string.text
      end
      h[key] = value
    end
    return h
  end

  # This method builds the hash that maps data identifiers to their text IDs.
  def build_unit_id_hash(path_to_unit)
    h = Hash.new
    @xml.root.elements.each(path_to_unit) do |unit|
      key = unit.attribute('Id').to_s
      value = unit.elements["TextId"].text
      h[key] = value
    end
    return h
  end

  def build_data_id_hash(path_to_data)
    h = Hash.new
    @xml.root.elements.each(path_to_data) do |data|
      key = data.elements["DataId"].text
      value = data.elements["LabelTextId"].text
      h[key] = value
    end
    return h
  end

  def build_scale_hash(path_to_data)
    h = Hash.new
    @xml.root.elements.each(path_to_data) do |data|
      key = data.attribute('id').to_s
      value = data.elements["*/DataScaling"]
      if value == nil
        value = ''
        h[key] = value
      else h[key] = value.text
      end
    end
    return h
  end

  def build_resolution_hash(path_to_data)
    h = Hash.new
    @xml.root.elements.each(path_to_data) do |data|
      key = data.attribute('id').to_s
      value = data.elements["*/Resolution"]
      if value == nil
        value = ''
        h[key] = value
      else h[key] = value.text
      end
    end
    return h
  end

  def build_hash(xpath_to_key,xpath_to_value)
    h = Hash.new
    keys = @xml.elements.to_a(xpath_to_key)
    values = @xml.elements.to_a(xpath_to_value)
    for i in 0..keys.size-1
      h[keys[i].text] = values[i].text
    end
    return h
  end

  def data_text_to_data_id(data_label)
    begin
      return @data.index(@strings.index(data_label))
    rescue
      return "#{data_label} is missing version #{version}"
    end
  end

  def data_id_to_data_text(data_id)
    begin
      return @strings.fetch(@data.fetch(data_id))
    rescue
      return "#{data_id} is missing from version #{version}"
    end
  end

  def unit_text_to_unit_id(unit_text)
    begin
      if unit_text =~ /°/ then unit_text.sub!('°',"deg "); end;
      return @units.index(@strings.index(unit_text))
    rescue
      return "#{unit_text} is missing from version #{version}"
    end
  end

  def unit_id_to_unit_text(unit_id)
    begin
      return @strings.fetch(@units.fetch(unit_id))
    rescue
      return "#{unit_id} is missing from version #{version}"
    end
  end

  def has_data_point?(data_point)
    if self.data[data_point] != nil
      return true
    else return false
    end
  end
  
  def scale(data_id)
    begin
      return @scales[data_id]
    rescue
      return "#{data_id} is missing from version #{version}"
    end
  end

  def resolution(data_id)
    begin
      return @resolutions[data_id]
    rescue
      return "#{data_id} is missing from version #{version}"
    end
  end

end
