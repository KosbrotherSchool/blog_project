class AddLikeCountToIosMessageReply < ActiveRecord::Migration
  def change
    add_column :ios_message_replies, :like_count, :integer, :default => 0
  end
end
