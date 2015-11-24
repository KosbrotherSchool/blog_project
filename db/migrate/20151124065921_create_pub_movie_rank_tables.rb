class CreatePubMovieRankTables < ActiveRecord::Migration
  def change
    create_table :pub_movie_rank_tables do |t|
      t.integer :movie_id
      t.integer :current_rank

      t.timestamps
    end
  end
end
