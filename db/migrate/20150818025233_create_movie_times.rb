class CreateMovieTimes < ActiveRecord::Migration
  def change
    create_table :movie_times do |t|
      t.string :remark
      t.string :movie_title
      t.string :movie_time
      t.string :movie_time_open_eye_link
      t.integer :movie_id
      t.integer :theater_id

      t.timestamps
    end
  end
end
