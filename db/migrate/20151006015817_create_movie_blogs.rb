class CreateMovieBlogs < ActiveRecord::Migration
  def change
    create_table :movie_blogs do |t|
      t.string :title
      t.string :link
      t.string :pic_link

      t.timestamps
    end
  end
end
