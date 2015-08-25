class CreateYoutubeSubColumns < ActiveRecord::Migration
  def change
    create_table :youtube_sub_columns do |t|
      t.string :title
      t.integer :youtube_column_id

      t.timestamps
    end
  end
end
