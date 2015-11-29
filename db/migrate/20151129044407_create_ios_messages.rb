class CreateIosMessages < ActiveRecord::Migration
  def change
    create_table :ios_messages do |t|
      t.integer :board_id
      t.string :author
      t.string :title
      t.string :tag
      t.text :content
      t.string :pub_date
      t.integer :view_count
      t.integer :like_count
      t.integer :reply_size
      t.boolean :is_head
      t.integer :head_index

      t.timestamps
    end
  end
end
