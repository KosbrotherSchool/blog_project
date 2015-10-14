class AddPicLinkToBlogPost < ActiveRecord::Migration
  def change
    add_column :blog_posts, :pic_link, :string
  end
end
