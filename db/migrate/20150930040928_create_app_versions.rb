class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.string :version_name
      t.string :version_content
      t.integer :version_code

      t.timestamps
    end
  end
end
