require 'net/http'

class YahooReviewWorker
  include Sidekiq::Worker
  include Capybara::DSL
  sidekiq_options queue: "movie_review"

  def perform(movie_id)

  	movie = Movie.find(movie_id)

  	yahoo_id = movie.yahoo_id
	 	url = "https://tw.movies.yahoo.com/movieinfo_review.html/id=" + yahoo_id.to_s
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)
    doc = Nokogiri::HTML(res.body)

    begin
    	movie_point = doc.css("#ymvls .bd em")[0].children[0].text.to_d * 2
    
	    puts movie_point.to_s

	    total = doc.css(".statistic em").children[0].text.to_i

	    puts total.to_s
	    
	    if total > 50
	    	# total = 50
	    	page_num = 5
	    elsif (total % 10)==0 
	    	page_num = total / 10
	    else
	    	page_num = ((total / 10)).to_i + 1
	    end
	    	
	    # end
	    puts page_num.to_s

	    movie.point = movie_point
	    movie.review_size = total
	    movie.is_review_crawled = true
	    movie.save

	    reviews = doc.css(".row-container")

	    # if movie.movie_review.last != nil
	    	# last_review_date = movie.movie_review.last.publish_date.to_date
	    # else
	    	# last_review_date = Date.yesterday
	    # end
	    
	  	(1..page_num).each do |page|

	  			puts "here"

	  			page = page_num - page + 1

	  			url = "https://tw.movies.yahoo.com/movieinfo_review.html/id=" + yahoo_id.to_s + "&p=" + page.to_s
			    uri = URI.parse(url)

			    puts url

			    http = Net::HTTP.new(uri.host, uri.port)
			    http.use_ssl = true
			    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
			    request = Net::HTTP::Get.new(uri.request_uri)
			    res = http.request(request)
			    doc = Nokogiri::HTML(res.body)

			    # total = doc.css(".statistic em").children[0].text.to_i
			    # page_num = (total / 10) + 1

			    reviews = doc.css(".row-container")

			    reviews.reverse.each do |review|

			    	sleep(1)

			    	str = review.css(".rate")[0].children[1].attr("src")
				    viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d * 2
				    
				    review_title = review.css(".text h4").children[0].text.gsub("標題：","").gsub("Title:","")

				    str = review.css(".date").children[0].text
				    str_auther = str[0..str.index("發表時間")-1]
				    review_auther = str_auther.gsub("發表人：","").gsub("   ","")

				    str_pub_date = str[str.index("發表時間")..str.length]
				    str_pub_date = str_pub_date.gsub("發表時間：","")
				    review_pub_date = str_pub_date.to_date

				    review_content = review.css(".text p")[0].children[0].text.gsub(" ","")

				    puts review_title
				    # puts viwer_rating.to_s
				    # puts review_auther
				    # puts review_content
				    # puts review_pub_date.to_s

				    if review_pub_date >= Date.yesterday && MovieReview.where("movie_id = #{movie.id} and title LIKE ?","#{review_title}").size == 0
				    	
				    	review = MovieReview.new
					    review.movie_id = movie.id
					    review.title = review_title
					    review.author = review_auther
					    review.content = review_content
					    review.publish_date = review_pub_date
					    review.point = viwer_rating

					    rend = Random.rand(6) + 1

					    if rend > 6
					    	rend = 6
					    end
							review.head_index = rend

					    begin
					    	review.save
					    rescue Exception => e
					    	
					    end  	
				    	
				    end
					    

			    end


	    end

    rescue Exception => e
    	
    end

  end

end