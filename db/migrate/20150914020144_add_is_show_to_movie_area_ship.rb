class AddIsShowToMovieAreaShip < ActiveRecord::Migration
  def change
    add_column :movie_area_ships, :is_show, :boolean, default: false
  end
end
