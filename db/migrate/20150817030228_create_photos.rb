class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :photo_link
      t.integer :movie_id

      t.timestamps
    end
  end
end
