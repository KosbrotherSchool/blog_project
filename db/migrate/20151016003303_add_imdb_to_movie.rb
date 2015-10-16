class AddImdbToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :imdb_point, :decimal, :precision => 3, :scale => 1
    add_column :movies, :imdb_link, :string
    add_column :movies, :potato_point, :decimal, :precision => 3, :scale => 1
    add_column :movies, :potato_link, :string
  end
end
