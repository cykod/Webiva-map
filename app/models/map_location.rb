require 'maruku'
require 'open-uri'
require 'rexml/document'

class MapLocation < DomainModel
  validates_presence_of :name,:address,:city,:state
  
  belongs_to :image, :class_name => 'DomainFile'
  
  def images
    return @images if @images
    
    @images = self.image_list.to_s.split(",").find_all { |elm| !elm.blank? }.collect { |elm|
      DomainFile.find_by_id(elm)
    }.find_all { |elm| !elm.blank? }
  end
  
  def before_save
   if identifier.blank?
      identifier_try_partial = name.downcase.gsub(/[ _]+/,"-").gsub(/[^a-z+0-9\-]/,"")
      idx = 2
      identifier_try = identifier_try_partial 
      
      while(MapLocation.find_by_identifier(identifier_try,:conditions => ['id != ?',self.id || 0] ))
        identifier_try = identifier_try_partial + '-' + idx.to_s
        idx += 1
      end
      
      self.identifier = identifier_try
    end
    
    if self.lon.blank? || self.lat.blank? || self.zip.blank?
      calculate_location
    end
  end
  
  def full_address
    "#{self.address}, #{self.city}, #{self.state} #{self.zip}"
  end
  
  def calculate_location
    api_key=Map::Utility.options.api_key
    
    return if api_key.blank?
    
    xml=open("http://maps.google.com/maps/geo?q=#{CGI.escape(self.full_address)}&output=xml&key=#{api_key}").read
    doc=REXML::Document.new(xml)

    if doc.elements['//kml/Response/Status/code'].text != '200'
      return false
    else
      doc.root.each_element('//Response') do |response|
	      response.each_element('//Placemark') do |place|      
	        calc_lng,calc_lat=place.elements['//coordinates'].text.split(',')
	        
	        self.lat = calc_lat if self.lat.blank?
	        self.lon = calc_lng if self.lon.blank?
	        
	        self.zip = place.elements['//PostalCodeNumber'].text if self.zip.blank?
	        
	        return true
	      end # end each place
      end # end each response
    end # end if result == 200
    return false
  end  

end
