class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.integer :message_id
      t.string :author
      t.text :content
      t.string :pub_date

      t.timestamps
    end
  end
end
