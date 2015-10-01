class ChangePointFormatInMovies < ActiveRecord::Migration
  def change
  	change_column :movies, :point, :decimal, :precision => 3, :scale => 1
  end
end
