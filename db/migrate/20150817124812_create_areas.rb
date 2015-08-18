class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.string :open_eye_area_link

      t.timestamps
    end
  end
end
