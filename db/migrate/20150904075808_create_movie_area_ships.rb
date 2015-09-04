class CreateMovieAreaShips < ActiveRecord::Migration
  def change
    create_table :movie_area_ships do |t|
      t.integer :movie_id
      t.integer :area_id

      t.timestamps
    end
  end
end
