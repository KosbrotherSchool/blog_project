require 'net/http'


namespace :crawl do

	task :crawl_theater_movie_time => :environment do

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
			
			movie_remark = ""
			begin
				movie_remark = movie.css(".version")[0].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
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
			puts movie_remark
			puts movie_times.to_s

			mMovietime = MovieTime.new
			mMovietime.remark = movie_remark
			mMovietime.movie_title = movie_title
			mMovietime.movie_time = movie_times.to_s
			mMovietime.movie_time_open_eye_link = movie_link

			begin
				mMovie = Movie.where('title LIKE ?', "#{movie_title}").first
				mMovietime.movie_id = mMovie.id
			rescue Exception => e
				
			end
			mMovietime.save

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

			mTheater = Theater.new
			mTheater.name = theater_title
			mTheater.theater_open_eye_link = theater_link
			mTheater.save
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
		
		doc.css(".area a").each do | area |
			area_link = area_host + area.attr("href")
			area_name = area.children[0].to_s.gsub(" ","")
			puts area_name
			puts area_link

			mArea = Area.new
			mArea.name = area_name
			mArea.open_eye_area_link = area_link
			mArea.save

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

		puts "Enter the Open Eye movie page"
		# movie_url = 'http://www.atmovies.com.tw/movie/film_fotw61770775_now.html'
		movie_url = STDIN.gets.chomp

		url = URI.parse(movie_url)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content= res.body
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')

		if doc.css(".at21b").children[2] == nil
			title = doc.css(".at21b").text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		else
			title = doc.css(".at21b").children[2].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
		end
		
		title_eng = ""
		begin
			title_eng = doc.css(".at12b_gray")[0].children[0].to_s
		rescue Exception => e
			
		end
		
		movie_class = ""
		begin
			if doc.css(".name img")[1] != nil
				if doc.css(".name img")[1].attr("src").index("cer_P.gif")
				movie_class = "保護級"
				elsif doc.css(".name img")[1].attr("src").index("cer_G.gif")
					movie_class = "普遍級"
				elsif doc.css(".name img")[1].attr("src").index("cer_R.gif")
					movie_class = "限制級"
			  elsif doc.css(".name img")[1].attr("src").index("cer_PG.gif")
			  	movie_class = "輔導級"
			  end
			else
			 	if doc.css(".name img")[0].attr("src").index("cer_P.gif")
				movie_class = "保護級"
				elsif doc.css(".name img")[0].attr("src").index("cer_G.gif")
					movie_class = "普遍級"
				elsif doc.css(".name img")[0].attr("src").index("cer_R.gif")
					movie_class = "限制級"
			  elsif doc.css(".name img")[0].attr("src").index("cer_PG.gif")
			  	movie_class = "輔導級"
			  end
			end
			
		rescue Exception => e
			
		end

		movie_length = ""
		begin
			str = doc.css(".row b")[0].children[0].to_s
	  	movie_length = str[str.index("片長：")+3..str.index("分")-1]
		rescue Exception => e
			
		end
	  
	  publish_date = ""
	  begin
	  	publish_date = str[str.index("上映日期：")+5..str.index("上映日期：")+14]
	  rescue Exception => e
	  	
	  end
		
		small_pic_link = ""
		begin
			small_pic_link = doc.css(".col-1 a")[0].children[1].attr("src")
		rescue Exception => e
			
		end

		# youtube trailer
		youtube_id = ""
		youtube_list_link = ""
		if doc.css("#treeid_y01 a")[0] != nil
			youtube_list_link = doc.css("#treeid_y01 a")[0].attr("href")
		elsif doc.css("#treeid_y01 iframe")[0] != nil
			str = doc.css("#treeid_y01 iframe")[0].attr("src")
			youtube_id = str[str.index("embed")+6..str.length]
		end
		

		director = ""
		director = doc.css(".crew_row").css("tr")[0].children[3].children[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		
		editors = ""
		actors = ""
		if doc.css(".crew_row").css("tr")[1].css("td").first.text.index("編劇")
			doc.css(".crew_row").css("tr")[1].css("td a").each do |ed|
				editors = editors + ed.text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","") + ","
			end
			editors = editors[0..editors.length-2]

			if doc.css(".crew_row").css("tr")[2].css("td").first.text.index("演員")
				doc.css(".crew_row").css("tr")[2].css("td a").each do |actor|
					actors = actors + actor.text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","") + ","
				end
				actors = actors[0..actors.length-2]
			end
		end

		if doc.css(".crew_row").css("tr")[1].css("td").first.text.index("演員")
			doc.css(".crew_row").css("tr")[1].css("td").first.remove
			doc.css(".crew_row").css("tr")[1].css("td a").each do |actor|
				actors = actors + actor.text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","") + ","
			end
			actors = actors[0..actors.length-2]
		end			

		movie_info = doc.css("div.sub_content").text.gsub("\r\n","").gsub("\t","").gsub(" ","")
		
		#  movie photo
		photos_link = ""
		if doc.css("div.row-2 a")[0] != nil
			photos_link = doc.css("div.row-2 a")[0].attr("href")
		end

		puts title + " " + title_eng + " " + movie_class
		puts movie_length + " " + publish_date
		puts small_pic_link
		puts youtube_list_link
		puts "導演 " + director
		puts "編劇" + editors
		puts "演員 " + actors
		puts movie_info
		puts photos_link

		if Movie.where('title LIKE ?', "#{title}").size != 0
			puts "Already has this movie"
		else
			mMovie = Movie.new
			mMovie.title = title
			mMovie.title_eng = title_eng
			mMovie.movie_class = movie_class
			mMovie.publish_date = publish_date
			mMovie.director = director
			mMovie.editors = editors
			mMovie.actors = actors
			mMovie.movie_info = movie_info
			mMovie.small_pic = small_pic_link

			mMovie.open_eye_link = movie_url
			mMovie.is_open_eye_crawled = true
			mMovie.save

			if photos_link != ""
				crawl_movie_photos(photos_link, mMovie.id)
			elsif doc.css(".stills_film li a") != nil
				links = doc.css(".stills_film li a")
				links.each do |photo_a|
					url = URI.parse(photo_a.attr("href"))
					req = Net::HTTP::Get.new(url.to_s)
					res = Net::HTTP.start(url.host, url.port) {|http|
						http.request(req)
					}
					doc = Nokogiri::HTML(res.body, nil, 'utf-8')
					the_photo_link = doc.css("td.shadow2 img")[0].attr("src")
					puts the_photo_link
					
					photo = Photo.new
					photo.photo_link = the_photo_link
					photo.movie_id = mMovie.id
					photo.save
				end
			end
			
			if youtube_list_link != ""
				crawl_movie_trailers(youtube_list_link, mMovie.id)
			elsif youtube_id != ""
				uri = URI.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+youtube_id+'&key=AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g')
				http = Net::HTTP.new(uri.host, uri.port)
	  		http.use_ssl = true
	  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
	  		request = Net::HTTP::Get.new(uri.request_uri)
	  		res = http.request(request)
	  		hash = JSON.parse(res.body.force_encoding("utf-8"))
	  		trailer_title = hash["items"][0]["snippet"]["title"] #Here will go wrong if no info
	  		
	  		mTrailer = Trailer.new
	  		mTrailer.title = trailer_title
	  		mTrailer.youtube_id = youtube_id
	  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
	  		mTrailer.movie_id = mMovie.id
	  		mTrailer.save

	  		puts trailer_title +  " " + mTrailer.youtube_link
			end

		end


	end

	def crawl_movie_photos(photos_link, movie_id)

		puts "Crawling Photos"

		url = URI.parse(photos_link)
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
			
			photo = Photo.new
			photo.photo_link = the_photo_link
			photo.movie_id = movie_id
			photo.save
		end

	end

	def crawl_movie_trailers(trailers_link, movie_id)

		api_key = "AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g"

		url = URI.parse(trailers_link)
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

	  		mTrailer = Trailer.new
	  		mTrailer.title = trailer_title
	  		mTrailer.youtube_id = trailer
	  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
	  		mTrailer.movie_id = movie_id
	  		mTrailer.save
  		rescue Exception => e
  			
  		end
		end

	end

end