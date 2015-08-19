class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.string :title_eng
      t.string :movie_class
      t.string :movie_type
      t.string :movie_length
      t.string :publish_date
      t.string :director
      t.string :editors
      t.string :actors
      t.string :official
      t.text :movie_info
      t.string :small_pic
      t.string :large_pic
      t.date :publish_date_date

      t.string :open_eye_link
      t.string :yahoo_link

      t.boolean :is_this_week_new, default: false
      t.boolean :is_open_eye_crawled, default: false
      t.boolean :is_yahoo_crawled, default: false
      t.integer :movie_round, default: 0

      t.timestamps
    end
  end
end
