class CreateTrailers < ActiveRecord::Migration
  def change
    create_table :trailers do |t|
      t.string :title
      t.string :youtube_id
      t.string :youtube_link
      t.integer :movie_id

      t.timestamps
    end
  end
end
