class CreateMovieReviews < ActiveRecord::Migration
  def change
    create_table :movie_reviews do |t|
      t.integer :movie_id
      t.string :author
      t.string :title
      t.text :content
      t.date :publish_date
      t.decimal :point, :precision => 3, :scale => 1

      t.timestamps
    end
  end
end
