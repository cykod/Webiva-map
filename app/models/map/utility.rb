
class Map::Utility

  def self.options(val = nil )
    Configuration.get_config_model(Options,val)
  end
  
  class Options < HashModel
    default_options :api_key => nil
    
    validates_presence_of :api_key  
  end  
  
  
end
