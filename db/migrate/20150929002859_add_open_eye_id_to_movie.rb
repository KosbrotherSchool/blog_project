class AddOpenEyeIdToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :open_eye_id, :string
  end
end
