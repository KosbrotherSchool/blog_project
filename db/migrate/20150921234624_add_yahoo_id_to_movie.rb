class AddYahooIdToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :yahoo_id, :integer
  end
end
