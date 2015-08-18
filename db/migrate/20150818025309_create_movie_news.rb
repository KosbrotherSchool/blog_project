class CreateMovieNews < ActiveRecord::Migration
  def change
    create_table :movie_news do |t|
      t.string :title
      t.string :info
      t.string :publish_day
      t.date :publish_date

      t.timestamps
    end
  end
end
