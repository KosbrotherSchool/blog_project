class CreateMovieNews < ActiveRecord::Migration
  def change
    create_table :movie_news do |t|
      t.string :title
      t.string :info
      t.string :news_link
      t.string :publish_day
      t.string :pic_link
      t.date :publish_date
      t.integer :news_type

      t.timestamps
    end
  end
end
