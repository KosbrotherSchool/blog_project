class TheaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def perform(theater_link, theater_id)
  	mTheater = Theater.find(theater_id)
    url = URI.parse(theater_link)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		theater_name = doc.css(".at21b")[0].children[0].to_s
		address = doc.css(".at10_gray")[0].children[0].to_s.gsub(" ","")
		phone = doc.css(".at10_gray")[0].children[4].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		
		theater_link = ""
		if doc.css(".title_block a")[1].children[0] != nil && doc.css(".title_block a")[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","") != ""
			theater_link = "http://" + doc.css(".title_block a")[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
		end
		
		# puts theater_name
		# puts address
		# puts phone
		# puts theater_link
		if mTheater.address == nil
			mTheater.update(:address => address)
		end
		
		if mTheater.phone == nil
			mTheater.update(:phone => phone)
		end

		if mTheater.official_site_link == nil
			mTheater.update(:official_site_link => theater_link)
		end

		movies = doc.css(".showtime_box")
		movies.each do |movie|
			
			movie_title = ""
			movie_link = ""
			begin
				movie_title	= movie.css(".film_title")[0].children[3].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
				movie_link = "http://www.atmovies.com.tw"+ movie.css(".film_title")[0].children[3].attr("href")	
			rescue Exception => e
				movie_title = movie.css(".film_title")[0].children[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
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
			mMovietime.theater_id = theater_id
			mMovietime.area_id = mMovietime.theater.area_id
			mMovietime.movie_photo = mMovietime.movie.small_pic

			begin
				mMovie = Movie.where('title LIKE ?', "#{movie_title}").first
				mMovietime.movie_id = mMovie.id
			rescue Exception => e
				
			end
			mMovietime.save

			if MovieAreaShip.where("movie_id = #{mMovietime.movie_id} AND area_id = #{mMovietime.area_id} AND is_show = false").size == 0
				mMovieAreaShip = MovieAreaShip.new
				mMovieAreaShip.movie_id = mMovietime.movie_id
				mMovieAreaShip.area_id = mMovietime.area_id
				mMovieAreaShip.save
			end

		end
  end
end