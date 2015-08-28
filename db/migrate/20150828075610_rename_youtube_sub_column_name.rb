class RenameYoutubeSubColumnName < ActiveRecord::Migration
  def change
  	rename_column :youtube_sub_columns, :title, :name
  end
end
