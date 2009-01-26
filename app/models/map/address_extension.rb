 

class Map::AddressExtension < DomainModelExtension


  def before_save(adr)
    if !adr.zip.blank? && (adr.city.blank?  && adr.state.blank?)
      zcode = MapZipcode.find_by_zip(adr.zip.strip)
      if zcode
        adr.city = zcode.city
        adr.state = zcode.state
      end
    end
    true
  end  


end
