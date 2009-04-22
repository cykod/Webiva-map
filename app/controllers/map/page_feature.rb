
class Map::PageFeature < ParagraphFeature
  

  feature :map_display, :default_feature => <<-FEATURE
    <div align='center'>
      <cms:map/>
      <cms:location_view>
        <cms:search_form>
        Search by State: <cms:state/> or Zipcode: <cms:zip/><cms:within/> <cms:button>Go</cms:button>
        </cms:search_form>
        <cms:state_search>Showing all results in "<cms:value/>" - <cms:results/> Results</cms:state_search>
        <cms:searching>Searching within <cms:within/> Miles of "<cms:zip/>" - <cms:results/> Results</cms:searching>
        <cms:locations>
          <table width='100%'>
          <cms:location>
          <tr>  
            <td>
              <cms:name/><br/>
              <cms:address/><br/>
              <cms:city/> <cms:state/>, <cms:zip/><br/>          
            <td>
            <cms:searching>
              <td align='right'>
                <cms:distance/> Miles
              </td>
            </cms:searching>
          </tr>
          </cms:location>
          </table>
          <cms:pages/>
        </cms:locations>
        <cms:no_locations>
          <div>No Results</div>
        </cms:no_locations>
      </cms:location_view>
    </div>
  FEATURE
  
  
  def map_display_feature(data) 
    webiva_feature(:map_display) do |c|
       c.expansion_tag("location_view") {data[:options].display_type == 'locations'  }
       c.define_value_tag('map') do |tag| 
         if data[:options].display_type != 'locations' ||  data[:locations].length > 0
            "<div id='map_view_#{data[:paragraph].id}' style='width:#{data[:options].width}px; height:#{data[:options].height}px; overflow:hidden;'></div>"
         end
       end
       c.form_for_tag('search_form','search') { |t| data[:search] }
          c.field_tag('search_form:zip',:size => 10) 
          c.field_tag('search_form:state',:control => 'select', :options => ([['-State-',nil]] + ContentModel.state_select_options)) 
          c.field_tag('search_form:within',:control => 'select', :options => data[:distance_options])
          c.button_tag('search_form:button')
       c.loop_tag('location') { |t| data[:locations] }
          define_location_tags(c)
        c.pagelist_tag('locations:pages') { data[:pages] } 
        c.value_tag("state_search") { data[:state_search] }
          c.value_tag("state_search:results") { |t| data[:locations].length }
        c.expansion_tag("searching") { data[:searching] }
          c.value_tag("searching:results") { |t| data[:locations].length }
          c.value_tag("searching:within") { |t| data[:search].within }
          c.value_tag("searching:zip") {|t| data[:search].zip  }
          c.value_tag("searching:distance") { |t| t.locals.location.distance } 
     end
  end
  
  feature :map_page_location_detail, :default_feature => <<-FEATURE
    <cms:location>
      <cms:name><cms:value/><br/></cms:name>
      <cms:address/><br/>
      <cms:city/> <cms:state/>, <cms:zip/><br/>
    </cms:location>
    
  FEATURE
  
  def map_page_location_detail_feature(data)
    webiva_feature(:map_page_location_detail) do |c|
      c.expansion_tag("location") { |t| t.locals.location = data[:location] }
       define_location_tags(c)
    end  
  end
  
  def define_location_tags(c)
      c.attribute_tags("location", %w(name address address_2 city state zip phone fax identifier lon lat contact_name contact_email)) { |t| t.locals.location } 
      c.link_tag("location:website") { |t| t.locals.location.website }
      c.value_tag("location:description") { |t| h(t.locals.location.description.to_s).gsub("\n","<br/>")  }
      c.value_tag("location:description_html") { |t| t.locals.location.description_html }
      c.value_tag("location:overview_html") { |t| t.locals.location.description_html }
  end
  
end
