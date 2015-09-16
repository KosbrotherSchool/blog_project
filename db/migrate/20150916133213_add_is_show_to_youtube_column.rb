class AddIsShowToYoutubeColumn < ActiveRecord::Migration
  def change
    add_column :youtube_columns, :is_show, :boolean, default: false
  end
end
