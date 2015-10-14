class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :link
      t.date :pub_date

      t.timestamps
    end
  end
end
