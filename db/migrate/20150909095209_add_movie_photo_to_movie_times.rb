class AddMoviePhotoToMovieTimes < ActiveRecord::Migration
  def change
    add_column :movie_times, :movie_photo, :string
  end
end
