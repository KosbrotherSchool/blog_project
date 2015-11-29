class CreateIosMessageReplies < ActiveRecord::Migration
  def change
    create_table :ios_message_replies do |t|
      t.integer :ios_message_id
      t.string :author
      t.text :content
      t.string :pub_date
      t.integer :head_index

      t.timestamps
    end
  end
end
