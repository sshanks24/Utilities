require 'nokogiri'

class LiebertXML

  attr_accessor :strings, :units, :data, :scales, :resolutions
  
  def initialize(fdm_file,gdd_file='enp2dd.xml')
    @fdm_file = fdm_file
    File.open(@fdm_file) do |config_file|
      @fdm = Nokogiri::XML(config_file)
    end
    @gdd_file = gdd_file
    File.open(@gdd_file) do |config_file|
      @gdd = Nokogiri::XML(config_file)
    end
  end

  def version
    @fdm.root.xpath["//Version/LastDictionaryEntry"].text.to_i
  end

  def build_gdd_hashes
    puts "\nBuilding data hashes\n\n"
    @strings = build_string_id_hash("////String")
    @units = build_unit_id_hash("//UomDefn")
    @data = build_data_id_hash("//DataDictEntry")
    @scales = Hash.new
    @resolutions = Hash.new
    puts "Finished building hashes"
  end

  def build_fdm_hashes
    puts "\nBuilding data hashes\n\n"
    @strings = build_string_id_hash("//String")
    @units = build_hash("//UomDefn","//UomDefn/TextId")
    @data = build_hash("//DataIdentifier","//DataLabel/TextID")
    @scales = build_scale_hash("//dataPoint")
    @resolutions = build_resolution_hash("//dataPoint")
    puts "Finished building hashes"
  end

  def merge_hashes_with_fdm(fdm)
    self.strings.merge!(fdm.strings)
    self.units.merge!(fdm.units)
    self.data.merge!(fdm.data)
    self.scales.merge!(fdm.scales)
    self.resolutions.merge!(fdm.resolutions)
  end
  # This method builds the hash table that maps text IDs to strings.
  def build_string_id_hash(path_to_string)
    h = Hash.new
    @fdm.root.xpath(path_to_string).each do |string|
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
    @fdm.root.xpath(path_to_unit).each do |unit|
      key = unit.attribute('Id').to_s
      value = unit.xpath("TextId").text
      h[key] = value
    end
    return h
  end

  def build_data_id_hash(path_to_data)
    h = Hash.new
    @fdm.root.xpath(path_to_data).each do |data|
      key = data.xpath("DataId").text
      value = data.xpath("LabelTextId").text
      h[key] = value
    end
    return h
  end

  def build_scale_hash(path_to_data)
    h = Hash.new
    @fdm.root.xpath(path_to_data).each do |data|
      key = data.attribute('id').to_s
      value = data.xpath("*/DataScaling")
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
    @fdm.root.xpath(path_to_data).each do |data|
      key = data.attribute('id').to_s
      value = data.xpath("*/Resolution")
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
    keys = @fdm.xpath(xpath_to_key)
    values = @fdm.xpath(xpath_to_value)
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
  
  def writable?(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/AccessDefn")
    if data_point.text =~ /W/i then
      return true
    else return false
    end
  end

  def max_value(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/ValueMax")
    return data_point.text
  end

  def min_value(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/ValueMin")
    return data_point.text
  end

  def scale(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/DataScaling")
    return data_point.text
  end

  def resolution(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/Resolution")
    return data_point.text
  end

  def type(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]")
    return data_point.attribute('type').text
  end

  def programmatic_name(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/ProgrammaticName")
    return data_point.text
  end

  def access(data_id)
    data_point = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/AccessDefn")
    return data_point.text
  end

  def id_to_text(data_id)
    text_id = @fdm.xpath("//dataPoint[@id=#{data_id}]/*/DataLabel/TextID")
    data_text = @fdm.xpath("//String[@Id=#{text_id.text}]")
    return data_text.text unless data_text.text == ''
    data_text = @gdd.xpath("//String[@Id=#{text_id.text}]")
    return data_text.text
  end

  def text_to_id(text)
    strings = @fdm.xpath("//String")
    text_id = ''
    strings.each do |string|
      if string.text == text then
        text_id = string.xpath("@Id").text
      end
    end
  end

end
