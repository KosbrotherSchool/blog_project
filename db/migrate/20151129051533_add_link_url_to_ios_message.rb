class AddLinkUrlToIosMessage < ActiveRecord::Migration
  def change
    add_column :ios_messages, :link_url, :string, default:""
  end
end
