

class AdditionalLocationFields < ActiveRecord::Migration
  def self.up
    add_column :map_locations, :contact_name, :string
    add_column :map_locations, :contact_user_id,:integer
    add_column :map_locations, :icon_image_id, :integer
  end
  
  def self.down
    remove_column :map_locations, :contact_name
    remove_column :map_locations, :contact_user_id
    remove_column :map_locations, :icon_image_id
  end
end

