require 'net/http'

class OpenEyeTheaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie_time"

  def perform(theater_id)

  	mTheater = Theater.find(theater_id)
		url = URI.parse(mTheater.theater_open_eye_link)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')

		theater_name = doc.css(".content-left h2")[0].text
		puts theater_name

		movies = doc.css("#theaterShowtimeTable")
		movies.each do |movie|
			
			movie_title = movie.css(".filmTitle a").text
			movie_link = "http://www.atmovies.com.tw"+ movie.css(".filmTitle a")[0].attr("href")
			
			movie_remark = movie.css(".filmVersion").text
			movie.css(".filmVersion").remove

			link = movie_link
			if link.index("film_id=")
				open_eye_id = link[link.index("film_id=")+8..link.length]
			else
				open_eye_id = link[link.index("/movie/")+7..link.length-2]
			end

			movie_length = movie.css("li ul li")[1].text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","").gsub("片長：","")

			# movie_times = Array.new
			movie_time = ""
			li_size = movie.css("li ul li").size
			(2..li_size-2).each do |num|
				time = ""
				if movie.css("li ul li")[num].css("a").text != ""
					time = movie.css("li ul li")[num].css("a").text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				else
					time = movie.css("li ul li")[num].text.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				end
				movie_time = movie_time + time + ","   
			end

		 	if movie_time != ""
        movie_time = movie_time[0..movie_time.length - 2]
      end

      puts movie_title
      puts movie_length
      puts movie_time
      puts movie_remark
			# puts movie_link
			
			
			if Movie.where("open_eye_id = '#{open_eye_id}'").size != 0

				mMovietime = MovieTime.new
				mMovietime.remark = movie_remark
				mMovietime.movie_title = movie_title
				mMovietime.movie_time = movie_time
				mMovietime.movie_time_open_eye_link = movie_link
				mMovietime.theater_id = mTheater.id
				mMovietime.area_id = mMovietime.theater.area_id

				mMovie = Movie.where("open_eye_id = '#{open_eye_id}'").first
				mMovie.movie_round = mTheater.movie_round

				if mMovie.movie_length == "未提供"
					mMovie.movie_length = movie_length
				end
				mMovie.save

				mMovietime.movie_id = mMovie.id
				mMovietime.movie_photo = mMovie.small_pic
				
				mMovietime.save

				if MovieAreaShip.where("movie_id = #{mMovietime.movie_id} AND area_id = #{mMovietime.area_id} AND is_show = false").size == 0
					mMovieAreaShip = MovieAreaShip.new
					mMovieAreaShip.movie_id = mMovietime.movie_id
					mMovieAreaShip.area_id = mMovietime.area_id
					mMovieAreaShip.save
				end
			
			else

				puts "Can't find the movie " + movie_title

			end

		end

  end

end