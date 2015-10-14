require 'net/http'

namespace :blog_task do

    task :update_post_pic => :environment do
        BlogPost.all.each do |post|
            puts post.title
            post.pic_link = post.movie_blog.pic_link
            post.save
        end
    end

	task :run_post_worker => :environment do
		MovieBlog.all.each do |blog|
			BlogWorker.perform_async(blog.id)
		end
	end

	task :get_pixnet_post => :environment do

		include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    page.visit 'http://gogosnow.pixnet.net/blog'
    doc = Nokogiri::HTML(page.html)

    article_heads = doc.css(".article-head")
    article_heads.each do |head|

    	title = head.css(".title h2 a")[0].text
    	link = head.css(".title h2 a")[0].attr("href")
    	pub_date = head.css(".publish").text.to_date

    	puts title
    	puts link
    	puts pub_date

    end

	end

	task :get_blogspot_post => :environment do

		include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    page.visit 'http://firewalker-movie.blogspot.tw/'
    doc = Nokogiri::HTML(page.html)

    date_outers = doc.css(".date-outer")
    date_outers.each do |outer|

    	title = outer.css(".post-title a")[0].text
    	link = outer.css(".post-title a")[0].attr("href")
    	
    	str = outer.css(".date-header span")[0].text
    	year = str[0..str.index("年")-1]
			str = str[str.index("年")+1..str.length]

    	month = str[0..str.index("月")-1]
    	if month.to_i < 10
    		month = "0" + month
    	end
    	str = str[str.index("月")+1..str.length]

    	day = str[0..str.index("日")-1]
    	if day.to_i < 10
    		day = "0" + day
    	end

    	pub_date = (year + month + day).to_date

    	puts title
    	puts link
    	puts pub_date

    end

	end

end