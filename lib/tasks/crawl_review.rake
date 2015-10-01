require 'net/http'

namespace :crawl_review do

	 task :crawl_yahoo => :environment do

	 	yahoo_id = 5717
	 	url = "https://tw.movies.yahoo.com/movieinfo_review.html/id=" + yahoo_id.to_s
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)
    doc = Nokogiri::HTML(res.body)

    movie_point = doc.css("#ymvls .bd em")[0].children[0].text.to_d * 2
    puts movie_point.to_s

    total = doc.css(".statistic em").children[0].text.to_i
    page_num = (total / 10) + 1

    reviews = doc.css(".row-container")

    reviews.each do |review|

    	str = review.css(".rate")[0].children[1].attr("src")
	    viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d * 2
	    
	    review_title = review.css(".text h4").children[0].text.gsub("標題：","")

	    str = review.css(".date").children[0].text
	    str_auther = str[0..str.index("發表時間")-1]
	    review_auther = str_auther.gsub("發表人：","").gsub("   ","")

	    str_pub_date = str[str.index("發表時間")..str.length]
	    str_pub_date = str_pub_date.gsub("發表時間：","")
	    review_pub_date = str_pub_date.to_date

	    review_content = review.css(".text p")[0].children[0].text.gsub(" ","")

	    puts review_title
	    puts viwer_rating.to_s
	    puts review_auther
	    puts review_content
	    puts review_pub_date.to_s

    end

    if page_num > 1
    	(2..page_num).each do |page|

    			url = "https://tw.movies.yahoo.com/movieinfo_review.html/id=" + yahoo_id.to_s + "&p=" + page.to_s
			    uri = URI.parse(url)

			    puts url

			    http = Net::HTTP.new(uri.host, uri.port)
			    http.use_ssl = true
			    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
			    request = Net::HTTP::Get.new(uri.request_uri)
			    res = http.request(request)
			    doc = Nokogiri::HTML(res.body)

			    movie_point = doc.css("#ymvls .bd em")[0].children[0].text.to_d * 2
			    puts movie_point.to_s

			    total = doc.css(".statistic em").children[0].text.to_i
			    page_num = (total / 10) + 1

			    reviews = doc.css(".row-container")

			    reviews.each do |review|

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
				    puts viwer_rating.to_s
				    puts review_auther
				    puts review_content
				    puts review_pub_date.to_s

			    end


    	end
    end

	 end

end