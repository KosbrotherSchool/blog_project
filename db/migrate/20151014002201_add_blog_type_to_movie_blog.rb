class AddBlogTypeToMovieBlog < ActiveRecord::Migration
  def change
    add_column :movie_blogs, :blog_type, :integer, default: 0
  end
end
