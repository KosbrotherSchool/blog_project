class AddMovieBlogIdToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :movie_blog_id, :integer
  end
end
