class ChangeMovieTimeInMovieTimes < ActiveRecord::Migration
  def change
  	change_column :movie_times, :movie_time, :text, :limit => 400
  end
end
