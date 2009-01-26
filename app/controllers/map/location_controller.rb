
class Map::LocationController < ModuleController

  component_info 'map'

  include ActiveTable::Controller
  
  active_table :location_table, MapLocation,
                [ ActiveTable::IconHeader.new('',:width => 10),
                  ActiveTable::StringHeader.new("locality_locations.name",:label => 'Name'),
                  ActiveTable::StringHeader.new("locality_locations.city",:label => 'City'),
                  ActiveTable::StringHeader.new("locality_locations.identifier",:label => 'URL'),
                  ActiveTable::BooleanHeader.new("locality_locations.active",:label => 'Act'),
                  ActiveTable::BooleanHeader.new("locality_locations.lon IS NOT NULL",:label => 'Loc')
                 ]
                 
  cms_admin_paths 'content',
                  'Content' => { :controller => '/content' },
                  'Map Locations' => { :action => 'index' }
                  
                  
  def display_location_table(display = true) 
    active_table_action 'location' do |action,location_ids|
      MapLocation.delete(location_ids) if action == 'delete'
    end
  
    @tbl = location_table_generate params, :order => 'city, name'
    
    render :partial => 'location_table' if display
  
  end

  def index
    cms_page_path ['Content'],'Locality Locations'
    display_location_table(false)
  end
  
  def edit
    @location = MapLocation.find_by_id(params[:path][0]) || MapLocation.new(:active => true)
    cms_page_path ['Content','Map Locations'], @location.id ? [ 'Edit %s',nil,@location.name ] : 'Create Location'
    
    if request.post? && @location.update_attributes(params[:location])
      redirect_to :action => 'index' 
    end
    
  end


end
