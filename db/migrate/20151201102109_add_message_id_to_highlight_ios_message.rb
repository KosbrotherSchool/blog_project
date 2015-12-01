class AddMessageIdToHighlightIosMessage < ActiveRecord::Migration
  def change
    add_column :highlight_ios_messages, :message_id, :integer
  end
end
