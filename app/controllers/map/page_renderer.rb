
class Map::PageRenderer < ParagraphRenderer
  module_renderer
  
  paragraph :map_view
  
  feature :map_display, :default_feature => <<-FEATURE
    <div align='center'>
      <cms:map/>
    </div>
  FEATURE
  
  
  def map_display_feature(feature,data) 
     parser_context = FeatureContext.new do |c|
       c.define_value_tag('map') do |tag| 
          "<div id='map_view_#{data[:paragraph].id}' style='width:#{data[:options].width}px; height:#{data[:options].height}px; overflow:hidden;'></div>"
       end
     end
    parse_feature(feature,parser_context)
  end
  
  
  def map_view
  
    if editor?
     render_paragraph :text => 'Map not shown in Editor'
     return
    end
    module_options = Map::Utility.options
    options = Map::PageController::MapViewOptions.new(paragraph.data || {})
  
    connection_type,connection_data = page_connection

    if options.display_type == 'connection'

      if !connection_data
        render_paragraph :nothing => true
        return
      end
      if connection_type == :map_data
        obj = connection_data[0].find_by_id(connection_data[1])
        
        if !obj
          render_paragraph :nothing => true
          return
        end
        data = obj.map_data
        
        if !data[:markers] || data[:markers].length == 0
          render_paragraph :nothing => true
          return
        end
      else connection_type == :callback
        callback,data_func = connection_data
        data = data_func.call
        data[:callback] = callback
      end
    elsif options.display_type == 'content_model'
      data = get_content_model_data(paragraph.id,options.content_model_id,options.content_model_field_id,options.content_model_response_field_id)
    else
      render_paragraph :text => 'Unsupported'
      return
    end
  
    
    require_js('prototype')
    header_html("<script src=\"http://maps.google.com/maps?file=api&v=2&key=#{module_options.api_key}\" type=\"text/javascript\"></script>")
    
    feature_data = { :paragraph => paragraph, :options =>  options }
    feature_output = map_display_feature(get_feature('map_display'), feature_data)
    render_paragraph :partial => '/map/page/map_view', :locals => {:paragraph => paragraph, :options =>  options, :in_editor => editor?, :data => data, :feature_output => feature_output }
  end
  
  protected
  
  def get_content_model_data(paragraph_id,content_model_id,field_id,response_field_id)
    mdl = ContentModel.find(content_model_id)
    fld = mdl.content_model_fields.find(field_id)
    resp_field = mdl.content_model_fields.find(response_field_id)

    bounds = { :lat_min => 1000, :lat_max => -1000, :lon_min => 1000, :lon_max => -1000 }

    map_responses = MapZipcode.find(:all,:joins => "LEFT JOIN `#{mdl.table_name}` ON (`#{mdl.table_name}`.`#{fld.field}` = map_zipcodes.zip)",:conditions => "`#{mdl.table_name}`.id IS NOT NULL AND `#{mdl.table_name}`.`#{resp_field.field}`!=''",:limit => 1000,:group => 'zipcode',:order => "MAX(`#{mdl.table_name}`.id) DESC").collect do |resp|
                      bounds[:lat_min] = resp.latitude if resp.latitude < bounds[:lat_min]
                      bounds[:lat_max] = resp.latitude if resp.latitude > bounds[:lat_max]
                      bounds[:lon_min] = resp.longitude if resp.longitude < bounds[:lon_min]
                      bounds[:lon_max] = resp.longitude if resp.longitude > bounds[:lon_max]
                      
                      { :lat => resp.latitude,
                        :lon => resp.longitude,  
                        :title => resp.zip,
                        :ident => resp.zip
                      }
                    end
    center = map_responses.length > 0 ? [  map_responses[0][:lat], map_responses[0][:lon] ] : nil
    { :zoom => 11,  :click => true, :center => center,  :markers => map_responses, :callback => { :controller => '/map/page', :action => "map_details_view", :path => [ paragraph_id ] } }
  end
  
end
