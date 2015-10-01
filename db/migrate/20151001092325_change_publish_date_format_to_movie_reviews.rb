class ChangePublishDateFormatToMovieReviews < ActiveRecord::Migration
  def change
  	change_column :movie_reviews, :publish_date, :string
  end
end
