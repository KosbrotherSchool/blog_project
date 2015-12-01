class AddIsHighlightToIosMessages < ActiveRecord::Migration
  def change
    add_column :ios_messages, :is_highlight, :boolean, default:false
    add_column :ios_messages, :pic_link, :string
  end
end
