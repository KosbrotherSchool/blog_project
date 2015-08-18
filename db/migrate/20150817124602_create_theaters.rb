class CreateTheaters < ActiveRecord::Migration
  def change
    create_table :theaters do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :official_site_link
     	t.string :theater_open_eye_link
     	
      t.integer :area_id

      t.timestamps
    end
  end
end
