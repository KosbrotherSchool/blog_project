class AddMovieRoundToTheaters < ActiveRecord::Migration
  def change
    add_column :theaters, :movie_round, :integer, :default => 1
  end
end
