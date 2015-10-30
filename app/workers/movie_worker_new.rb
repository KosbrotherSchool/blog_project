require 'net/http'

class MovieWorkerNew
  include Sidekiq::Worker
  include Capybara::DSL
  sidekiq_options queue: "movie"

  def perform(movie_id)
		Capybara.current_driver = :selenium_chrome

    mMovie = Movie.find(movie_id)
    page.visit mMovie.open_eye_link
    if first(:xpath, "//a[@onclick]") != nil
    	first(:xpath, "//a[@onclick]").click
    	sleep 1
    end
    doc = Nokogiri::HTML(page.html, nil, 'utf-8')

		# photos
		photos_link = ""
		if doc.css("a.button")[0] != nil
			photos_link = doc.css("a.button")[0].attr("href")
		end

		# trailers
		youtube_list_link = ""
		youtube_ids = Array.new
		if doc.css("#moreTrailer a")[0] != nil
			youtube_list_link = doc.css("#moreTrailer a")[0].attr("href")
		elsif doc.css(".video_view iframe") != nil
			youtubes = doc.css(".video_view iframe")
			youtubes.each do |youtube|
				str = youtube.attr("src")
				id = str[str.index("embed")+6..str.length]
				youtube_ids << id
			end
		end

		if photos_link != ""
			crawl_movie_photos(photos_link, mMovie.id, mMovie)
		elsif doc.css("div.content-left div div a") != nil
			links = doc.css("div.content-left div div a")
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
				if Photo.where('photo_link LIKE ?', "#{the_photo_link}").size == 0
		  		photo.save
		  		mMovie.photo_size = mMovie.photo_size + 1
		  	end	
			end
		end

		if youtube_list_link != ""
			crawl_movie_trailers(youtube_list_link, mMovie.id, mMovie)
		elsif youtube_ids.size > 0

			youtube_ids.each do |youtube_id|

				uri = URI.parse('https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+youtube_id+'&key=AIzaSyBtwxlVqWkXv0D6kMklsF1Qd0oIhpVdr6g')
				http = Net::HTTP.new(uri.host, uri.port)
	  		http.use_ssl = true
	  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
	  		request = Net::HTTP::Get.new(uri.request_uri)
	  		res = http.request(request)
	  		hash = JSON.parse(res.body.force_encoding("utf-8"))

	  		begin
	  			trailer_title = hash["items"][0]["snippet"]["title"] #Here will go wrong if no info
	  			puts trailer_title
	  			mTrailer = Trailer.new
		  		mTrailer.title = trailer_title
		  		mTrailer.youtube_id = youtube_id
		  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
		  		mTrailer.movie_id = mMovie.id
		  		if Trailer.where('title LIKE ?', "#{trailer_title}").size == 0
		  			mTrailer.save
		  			mMovie.trailer_size = mMovie.trailer_size + 1
		  		end

	  		rescue Exception => e
	  			
	  		end

	  	end
	  	puts mMovie.trailer_size
  		
		end

		mMovie.is_open_eye_crawled = true
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
			puts the_photo_link
			
			photo = Photo.new
			photo.photo_link = the_photo_link
			photo.movie_id = movie_id
			if Photo.where('photo_link LIKE ?', "#{the_photo_link}").size == 0
	  		photo.save
	  		mMovie.photo_size = mMovie.photo_size + 1
	  	end
			
		end
		puts mMovie.photo_size
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
	  		puts trailer_title

	  		mTrailer = Trailer.new
	  		mTrailer.title = trailer_title
	  		mTrailer.youtube_id = trailer
	  		mTrailer.youtube_link = 'https://www.youtube.com/watch?v='+ mTrailer.youtube_id
	  		mTrailer.movie_id = movie_id
	  		if Trailer.where('youtube_id LIKE ?', "#{trailer}").size == 0
	  			mTrailer.save
	  			mMovie.trailer_size = mMovie.trailer_size + 1
	  		end
	  		
  		rescue Exception => e
  			
  		end
		end

		puts mMovie.trailer_size
	end

end