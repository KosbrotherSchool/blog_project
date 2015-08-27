class AddAreaIdToMovieTime < ActiveRecord::Migration
  def change
    add_column :movie_times, :area_id, :integer
  end
end
