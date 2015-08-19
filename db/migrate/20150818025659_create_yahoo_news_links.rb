class CreateYahooNewsLinks < ActiveRecord::Migration
  def change
    create_table :yahoo_news_links do |t|
      t.string :link
      t.integer :news_type, default: 0

      t.timestamps
    end
  end
end
