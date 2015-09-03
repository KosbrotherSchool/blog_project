class AddSizeNumToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :photo_size, :integer, default: 0
    add_column :movies, :trailer_size, :integer, default: 0
  end
end
