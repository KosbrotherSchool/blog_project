class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :author
      t.string :title
      t.string :message_tag
      t.text :content
      t.string :pub_date
      t.integer :view_count

      t.timestamps
    end
  end
end
