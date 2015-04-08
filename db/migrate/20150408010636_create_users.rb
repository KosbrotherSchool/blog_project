class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :message
      t.boolean :is_learned_android

      t.timestamps
    end
  end
end
