require 'net/http'

namespace :other_task do

	task :crawl_single_open_eye_theater => :environment do

		# 47 中源戲院, 79 新榮戲院, 39朝代戲院, 麻豆戲院 80
		mTheater = Theater.find(80)
		url = URI.parse(mTheater.theater_open_eye_link)
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
				movie_remark = movie.css(".version")[0].children[1].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
			rescue Exception => e
				
			end

			link = movie_link
			if link.index("film_id=")
				open_eye_id = link[link.index("film_id=")+8..link.length]
			else
				open_eye_id = link[link.index("/movie/")+7..link.length-2]
			end

			# movie_times = Array.new
			movie_time = ""
			movie.css("ul li").each do | item |
				time = ""
				if item.children[0].to_s.index("訂票")
					time = item.children[0].children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				else
					time = item.children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","").gsub(" ","")
				end
        movie_time = movie_time + time + ","        
			end

		 	if movie_time != ""
        movie_time = movie_time[0..movie_time.length - 2]
      end

      puts movie_title
      puts movie_time
			# puts movie_link
			# puts movie_remark
			

			# if movie_title can't match => not save
			# if Movie.where('title LIKE ?', "#{movie_title}")
			if Movie.where("open_eye_id = '#{open_eye_id}'").size != 0

				mMovietime = MovieTime.new
				mMovietime.remark = movie_remark
				mMovietime.movie_title = movie_title
				mMovietime.movie_time = movie_time
				mMovietime.movie_time_open_eye_link = movie_link
				mMovietime.theater_id = mTheater.id
				mMovietime.area_id = mMovietime.theater.area_id

				mMovie = Movie.where("open_eye_id = '#{open_eye_id}'").first
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

	task :modify_movie_yahoo_link => :environment do
		Movie.all.each do |movie|

			link = movie.yahoo_link
			if link != nil && link.index("*")
				link = link[link.index("*")+1..link.length]
				movie.yahoo_link = link
				movie.save
			end

		end
	end

	task :give_yahoo_id_to_moive => :environment do

		Movie.where("yahoo_id is null").each do |movie|
			puts movie.title
			link = movie.yahoo_link
			yahoo_id = link[link.index('id=')+3..link.length].to_i
			movie.yahoo_id = yahoo_id
			movie.save
		end

	end

	task :give_open_eye_id_to_movie => :environment do

		Movie.where("open_eye_link is NOT NULL and open_eye_id is NULL").each do |movie|

			puts movie.title
			link = movie.open_eye_link
			if link.index("film_id=")
				open_eye_id = link[link.index("film_id=")+8..link.length]
			else
				open_eye_id = link[link.index("/movie/")+7..link.length-2]
			end
			movie.open_eye_id = open_eye_id
			movie.save

		end

	end

	task :update_movie_review_size => :environment do

		Movie.where("is_review_crawled = true").each do |movie|
			puts movie.title
			movie.review_size = movie.movie_review.size
			movie.save
		end

	end

	task :check_ruby_return_method => :environment do
		num = getANum()
		puts num.to_s
	end

	def getANum()
		return 10
	end

end