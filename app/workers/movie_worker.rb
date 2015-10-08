require 'net/http'

class MovieWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def perform(movie_id)
  	mMovie = Movie.find(movie_id)

    url = URI.parse(mMovie.open_eye_link)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content= res.body
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')

		if doc.css(".at21b").children[2] == nil
			title = doc.css(".at21b").text.gsub("\r","").gsub("\n","").gsub("\t","")
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
		begin
			director = doc.css(".crew_row").css("tr")[0].children[3].children[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		rescue Exception => e
			
		end
		
		editors = ""
		actors = ""
		begin
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
		rescue Exception => e
			
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

		if mMovie.title == nil || mMovie.title == ""
			mMovie.title = title
		end
		
		if mMovie.title_eng == nil || mMovie.title_eng == ""
			mMovie.title_eng = title_eng
		end
		
		if mMovie.movie_class == nil || mMovie.movie_class == ""
			mMovie.movie_class = movie_class
		end
		
		if mMovie.publish_date == nil || mMovie.publish_date == ""
			mMovie.publish_date = publish_date
		end
		
		if mMovie.director == nil || mMovie.director == ""
			mMovie.director = director
		end
		
		if mMovie.editors == nil || mMovie.editors == ""
			mMovie.editors = editors
		end
		
		if mMovie.actors == nil || mMovie.actors == ""
			mMovie.actors = actors
		end
		
		if mMovie.movie_info == nil || mMovie.movie_info == ""
			mMovie.movie_info = movie_info
		end
		
		if mMovie.small_pic == nil || mMovie.small_pic == ""
			mMovie.small_pic = small_pic_link
		end
		
		# mMovie.movie_round = movie_round

		if mMovie.movie_length == nil || mMovie.movie_length == ""
			mMovie.movie_length = movie_length
		end
		
		if mMovie.publish_date_date == nil
			begin
				mMovie.publish_date_date = publish_date.to_date
			rescue Exception => e
				
			end
		end
		
		mMovie.is_open_eye_crawled = true
		

		if photos_link != ""
			crawl_movie_photos(photos_link, mMovie.id, mMovie)
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
				mMovie.photo_size = mMovie.photo_size + 1
			end
		end
		
		if youtube_list_link != ""
			crawl_movie_trailers(youtube_list_link, mMovie.id, mMovie)
		elsif youtube_id != ""
			uri = URI.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+youtube_id+'&key=AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g')
			http = Net::HTTP.new(uri.host, uri.port)
  		http.use_ssl = true
  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
  		request = Net::HTTP::Get.new(uri.request_uri)
  		res = http.request(request)
  		hash = JSON.parse(res.body.force_encoding("utf-8"))

  		begin
  			trailer_title = hash["items"][0]["snippet"]["title"] #Here will go wrong if no info
  			mTrailer = Trailer.new
	  		mTrailer.title = trailer_title
	  		mTrailer.youtube_id = youtube_id
	  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
	  		mTrailer.movie_id = mMovie.id
	  		mTrailer.save

	  		mMovie.trailer_size = mMovie.trailer_size + 1
  		rescue Exception => e
  			
  		end
  		
		end
		
		mMovie.save

  end

  def crawl_movie_photos(photos_link, movie_id, mMovie)

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
			# puts the_photo_link
			
			photo = Photo.new
			photo.photo_link = the_photo_link
			photo.movie_id = movie_id
			photo.save
			mMovie.photo_size = mMovie.photo_size + 1
		end
	end

	def crawl_movie_trailers(trailers_link, movie_id, mMovie)
		puts "crawl_movie_trailers"

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
				# puts trailer
				uri = URI.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+trailer+'&key=AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g')
				http = Net::HTTP.new(uri.host, uri.port)
	  		http.use_ssl = true
	  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
	  		request = Net::HTTP::Get.new(uri.request_uri)
	  		res = http.request(request)
	  		hash = JSON.parse(res.body.force_encoding("utf-8"))
	  		trailer_title = hash["items"][0]["snippet"]["title"] #Here will go wrong if no info
	  		# puts trailer_title

	  		mTrailer = Trailer.new
	  		mTrailer.title = trailer_title
	  		mTrailer.youtube_id = trailer
	  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
	  		mTrailer.movie_id = movie_id
	  		mTrailer.save
	  		mMovie.trailer_size = mMovie.trailer_size + 1
  		rescue Exception => e
  			
  		end
		end
	end

end