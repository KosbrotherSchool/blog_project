class AddReviewSizeToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :review_size, :integer
  end
end
