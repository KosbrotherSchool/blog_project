require 'net/http'


namespace :crawl do

	task :crawl_theater_content => :environment do

		url = URI.parse('http://www.atmovies.com.tw/showtime/theater_t02a01_a02.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		theater_name = doc.css(".at21b")[0].children[0].to_s
		address = doc.css(".at10_gray")[0].children[0].to_s.gsub(" ","")
		phone = doc.css(".at10_gray")[0].children[4].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		theater_link = "http://" + doc.css(".title_block a")[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")

		puts theater_name
		puts address
		puts phone
		puts theater_link

		movies = doc.css(".showtime_box")
		movies.each do |movie|
			
			movie_title = ""
			movie_link = ""
			begin
				movie_title	= movie.css(".film_title")[0].children[3].children[0].to_s
				movie_link = "http://www.atmovies.com.tw"+ movie.css(".film_title")[0].children[3].attr("href")	
			rescue Exception => e
				movie_title = movie.css(".film_title")[0].children[1].children[0].to_s
				movie_link = "http://www.atmovies.com.tw"+ movie.css(".film_title")[0].children[1].attr("href")
			end
			
			movie_version = ""
			begin
				movie_version = movie.css(".version")[0].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
			rescue Exception => e
				
			end

			movie_times = Array.new
			movie.css("ul li").each do | item |
				time = ""
				if item.children[0].to_s.index("訂票")
					time = item.children[0].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				else
					time = item.children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				end
				movie_times << time
			end

			puts movie_title
			puts movie_link
			puts movie_version
			puts movie_times

		end

	end

	task :crawl_area_theaters => :environment do

		url = URI.parse('http://www.atmovies.com.tw/showtime/area_a02.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		theaters = doc.css("span.at11 a")
		theaters.each do | theater |
			theater_title = theater.children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
			theater_link = "http://www.atmovies.com.tw/showtime/" + theater.attr("href")
			puts theater_title
			puts theater_link
		end

	end

	task :crawl_theater_area => :environment do
		
		url = URI.parse('http://www.atmovies.com.tw/showtime/showtimehome2.asp')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')

		area_host = "http://www.atmovies.com.tw/showtime/"
		area_links = Array.new
		doc.css(".area a").each do | area |
			area_link = area_host + area.attr("href")
			area_links << area_link
			area_name = area.children[0].to_s.gsub(" ","")
			puts area_name
			puts area_link
		end

	end

	task :crawl_second_movie_list => :environment do

		url = URI.parse('http://www.atmovies.com.tw/movie/movie_now2-0.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		movie_host = "http://www.atmovies.com.tw"
		doc.css("div.listall a").each do |movie|
			 title = movie.children[4].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
			 movie_link = movie_host + movie.attr("href")
			 puts title
			 puts movie_link
		end

	end

	task :crawl_movie_list => :environment do 

		url = URI.parse('http://www.atmovies.com.tw/movie/movie_now-0.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		movie_host = "http://www.atmovies.com.tw"
		doc.css("div.listall a").each do |movie|
			 title = movie.children[4].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
			 movie_link = movie_host + movie.attr("href")
			 puts title
			 puts movie_link
		end

	end

	task :crawl_movie_trailers => :environment do
		
		api_key = "AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g"

		url = URI.parse('http://app.atmovies.com.tw/movie/movie.cfm?action=trailer&film_id=fotw61770775&mt=1')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		trailer_ids = Array.new
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		doc.css("iframe").each do |trailer|
			str = trailer.attr("src")
			trailer_id = str[str.index("embed/")+6..str.length-1]
			trailer_ids << trailer_id
		end

		trailer_ids.each do |trailer|

			begin
				puts trailer

				uri = URI.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+trailer+'&key=AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g')
				http = Net::HTTP.new(uri.host, uri.port)
	  		http.use_ssl = true
	  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
	  		request = Net::HTTP::Get.new(uri.request_uri)
	  		res = http.request(request)
	  		hash = JSON.parse(res.body.force_encoding("utf-8"))
	  		trailer_title = hash["items"][0]["snippet"]["title"] #Here will go wrong if no info
	  		puts trailer_title
  		rescue Exception => e
  			
  		end
		end

	end

	task :crawl_moive_photos => :environment do

		url = URI.parse('http://gallery.photowant.com/b/gallery.cfm?action=still&filmid=fotw61770775')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')

		photo_links = Array.new

		photo_host = "http://gallery.photowant.com/b/"
		photos =  doc.css("center span span a")
		photos.each do |photo|
			photo_links << photo_host + photo.attr("href")
		end

		photo_links.each do |photo_link|
			url = URI.parse(photo_link)
			req = Net::HTTP::Get.new(url.to_s)
			res = Net::HTTP.start(url.host, url.port) {|http|
				http.request(req)
			}
			doc = Nokogiri::HTML(res.body, nil, 'utf-8')
			the_photo_link = doc.css("td.shadow2 img")[0].attr("src")
			puts the_photo_link
		end

	end

	task :crawl_single_movie => :environment do

		url = URI.parse('http://www.atmovies.com.tw/movie/film_fotw61770775_now.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content= res.body
		doc = Nokogiri::HTML(content)

		title = doc.css(".at21b").children[2].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
		title_eng = doc.css(".at12b_gray")[0].children[0].to_s
		movie_class = ""
		if doc.css(".name img")[1].attr("src").index("cer_P.gif")
			movie_class = "保護級"
		elsif doc.css(".name img")[1].attr("src").index("cer_G.gif")
			movie_class = "普遍級"
		elsif doc.css(".name img")[1].attr("src").index("cer_R.gif")
			movie_class = "限制級"
	  elsif doc.css(".name img")[1].attr("src").index("cer_PG.gif")
	  	movie_class = "輔導級"
	  end
	  str = doc.css(".row b")[0].children[0].to_s
	  movie_length = str[str.index("片長：")+3..str.index("分")-1]
		publish_date = str[str.index("上映日期：")+5..str.index("上映日期：")+14]
		small_pic_link = doc.css(".col-1 a")[0].children[1].attr("src")
		youtube_list_link = doc.css("#treeid_y01 a")[0].attr("href")

		director = ""

		if doc.css(".crew_row").css("tr").size == 3

			director = doc.css(".crew_row").css("tr")[0].children[3].children[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
			
			actors = ""
			doc.css(".crew_row").css("tr")[1].css("td").first.remove
			doc.css(".crew_row").css("tr")[1].css("td a").each do |actor|
				actors = actors + actor.children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","") + ","
			end
			actors = actors[0..actors.length-2]

		end

		movie_info = doc.css("div.sub_content").text.gsub("\r\n","").gsub("\t","").gsub(" ","")
		photos_link = doc.css("div.row-2 a")[0].attr("href")

		# Theater
		# theater_host = "http://www.atmovies.com.tw"
		# doc.css(".movie_theater select option").first.remove
		# theaters = doc.css(".movie_theater select option")
		# theaters.each do |theater|
		# 	theater_link = theater_host + theater.attr("value")
		# 	theater_area = theater.children[0].to_s.gsub("\r","").gsub("\n","").gsub(" ","")
		# 	puts theater_area
		# 	puts theater_link
		# end

		puts title + " " + title_eng + " " + movie_class
		puts movie_length + " " + publish_date
		puts small_pic_link
		puts youtube_list_link
		puts "導演 " + director
		puts "演員 " + actors
		puts movie_info
		puts photos_link

	end

end