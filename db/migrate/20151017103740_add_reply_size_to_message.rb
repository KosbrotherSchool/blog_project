class AddReplySizeToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :reply_size, :integer, default: 0
  end
end
