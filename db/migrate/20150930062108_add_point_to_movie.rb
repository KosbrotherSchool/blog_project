class AddPointToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :point, :decimal, default: 0
    add_column :movies, :is_review_crawled, :boolean, default: false
  end
end
