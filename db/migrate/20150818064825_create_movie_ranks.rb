class CreateMovieRanks < ActiveRecord::Migration
  def change
    create_table :movie_ranks do |t|
      t.integer :rank_type
      t.integer :movie_id
      t.integer :current_rank
      t.integer :last_week_rank
      t.integer :publish_weeks
      t.integer :the_week
      t.string  :static_duration
      t.integer :expect_people
      t.integer :total_people
      t.string :satisfied_num

      t.timestamps
    end
  end
end
