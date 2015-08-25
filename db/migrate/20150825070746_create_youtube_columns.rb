class CreateYoutubeColumns < ActiveRecord::Migration
  def change
    create_table :youtube_columns do |t|
      t.string :title
      t.string :image_link

      t.timestamps
    end
  end
end
