class Map::PageController < ParagraphController 

  editor_header 'Map Paragraphs'

  editor_for :map_view, :name => 'Map View', 
                          :features => ['map_view'],
                          :inputs => [ [ :data, 'Map Data', :map_data ],
                                       [ :callback, 'Map Callback', :map_callback ] ]                                       
  
  
  user_actions :map_details_view
  def map_view
    @options = MapViewOptions.new(params[:map_view] || paragraph.data || {})
    return if handle_module_paragraph_update(@options)
    
    @content_models = ContentModel.find_select_options(:all)
    
    if(@options.content_model_id.to_i > 0)
      @fields = ContentModelField.find_select_options(:all,:conditions => { :content_model_id => @options.content_model_id, :field_type => 'string' } )
      @text_fields = ContentModelField.find_select_options(:all,:conditions => { :content_model_id => @options.content_model_id, :field_type => 'text' } )
    end       
    
  end
  
  class MapViewOptions < HashModel
    default_options :width => 400, :height => 400, :display_type => 'connection', :show_map_types => 'yes',:show_zoom => 'full', :default_icon => nil, :default_zoom => nil, :content_model_id => nil,:content_model_field_id => nil, :content_model_response_field_id => nil
    
    integer_options :content_model_id,:content_model_field_id, :content_model_response_field_id
    
    def validate
      errors.add(:content_model_field_id,'is missing') if !content_model_id.blank? && content_model_field_id.blank?
      errors.add(:content_model_response_field_id,'is missing') if !content_model_id.blank? && content_model_response_field_id.blank?
    end
  end
  
  def map_details_view
    paragraph = PageParagraph.find_by_id_and_display_type(params[:path][0],'map_view')
    
    options = MapViewOptions.new(paragraph.data || {})

    mdl = ContentModel.find(options.content_model_id)
    fld = mdl.content_model_fields.find(options.content_model_field_id)
    @resp_field = mdl.content_model_fields.find(options.content_model_response_field_id)
    
    @page = (params[:page] || 0).to_i
    
    @count = mdl.content_model.count(:all,:conditions => [ "`#{fld.field}` = ? AND `#{@resp_field.field}` != ''",params[:identifier] ])

    if(@page >= @count) 
      @page = @count-1
    end
    
    @responses = mdl.content_model.find(:all,:conditions => [ "`#{fld.field}` = ? AND `#{@resp_field.field}` != ''",params[:identifier] ],:offset => @page,:limit => 1, :order => "`#{mdl.table_name}`.id DESC")
    @response = @responses[0] 
    
    
    render :partial => 'map_details_view'
  end  
end
  
  
