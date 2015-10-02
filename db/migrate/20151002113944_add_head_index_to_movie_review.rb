class AddHeadIndexToMovieReview < ActiveRecord::Migration
  def change
    add_column :movie_reviews, :head_index, :integer, default: 1
  end
end
