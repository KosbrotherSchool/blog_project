class BlogWorker
  include Sidekiq::Worker
  include Capybara::DSL
  sidekiq_options queue: "blog_post"

  def perform(blog_id)

  	blog = MovieBlog.find(blog_id)

    # for pixnet
    if blog.blog_type == 1
	  	
	    Capybara.current_driver = :selenium_chrome
	    page.visit blog.link
	    doc = Nokogiri::HTML(page.html)

    	article_heads = doc.css(".article-head")
    	article_heads.each do |head|

	    	title = head.css(".title h2 a")[0].text
	    	link = head.css(".title h2 a")[0].attr("href")
	    	pub_date = head.css(".publish").text.to_date

	    	puts title
	    	puts link
	    	puts pub_date

	    	if BlogPost.where('title LIKE ?', "#{title}").size == 0
		    	post = BlogPost.new
		    	post.title = title
		    	post.link = link
		    	post.pub_date = pub_date
		    	post.movie_blog_id = blog.id
		    	post.pic_link = blog.pic_link
		    	post.save
		    end
    	end
    end
    
    #  for blogspot
    if blog.blog_type == 2

	    Capybara.current_driver = :selenium_chrome
	    page.visit blog.link
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

	    	if BlogPost.where('title LIKE ?', "#{title}").size == 0
		    	post = BlogPost.new
		    	post.title = title
		    	post.link = link
		    	post.pub_date = pub_date
		    	post.movie_blog_id = blog.id
		    	post.pic_link = blog.pic_link
		    	post.save
		    end

	    end
    end

  end
end