class AddIsShowToMovieTime < ActiveRecord::Migration
  def change
    add_column :movie_times, :is_show, :boolean, default: false
  end
end
