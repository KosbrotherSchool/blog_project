class AddIsShowToMovieRank < ActiveRecord::Migration
  def change
    add_column :movie_ranks, :is_show, :boolean, default: false
  end
end
