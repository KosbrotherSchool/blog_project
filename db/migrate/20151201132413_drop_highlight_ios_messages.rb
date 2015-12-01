class DropHighlightIosMessages < ActiveRecord::Migration
  def change
  	drop_table :highlight_ios_messages
  end
end
