class AddPicLinkToHighlightIosMessage < ActiveRecord::Migration
  def change
    add_column :highlight_ios_messages, :pic_link, :string, default: ""
  end
end
