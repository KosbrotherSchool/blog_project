class CreateYoutubeVideos < ActiveRecord::Migration
  def change
    create_table :youtube_videos do |t|
      t.string :title
      t.string :youtube_id
      t.integer :youtube_column_id
      t.integer :youtube_sub_column_id

      t.timestamps
    end
  end
end
