require 'net/http'

namespace :other_task do

	task :update_pub_movie_rank_table => :environment do

		ids = MovieRank.joins(:movie).order('current_rank ASC').pluck(:movie_id)
		rank_num = 1
		ids.each do |movie_id|
			pmTable = PubMovieRankTable.new
			pmTable.movie_id = movie_id
			pmTable.current_rank = rank_num
			rank_num = rank_num + 1
			pmTable.save
			puts pmTable.movie.title
		end

		movie_ids = Movie.where("movie_round = 1 and is_this_week_new = false").order('publish_date_date DESC').pluck(:id)
		movie_ids.each do |movie_id|
			if PubMovieRankTable.where(" movie_id = #{movie_id}").size == 0
				pmTable = PubMovieRankTable.new
				pmTable.movie_id = movie_id
				pmTable.current_rank = rank_num
				rank_num = 0
				pmTable.save
				puts pmTable.movie.title
			end 
		end

	end

	task :update_movie_time_data => :environment do
		MovieTime.delete_all("is_show = true")
		MovieTime.update_all("is_show = true")
		MovieAreaShip.delete_all("is_show = true")
		MovieAreaShip.update_all("is_show = true")
	end

	task :crawl_this_week_movie_review => :environment do

		Movie.where("is_this_week_new = true").each do |movie|
			YahooReviewWorker.perform_async(movie.id)
		end

	end

	task :update_this_week_movie_review_size_and_points => :environment do

		Movie.where("is_this_week_new = true").each do |movie|
			puts movie.title
			movie.review_size = movie.movie_review.size
			if movie.movie_review.size != 0
				total = 0.0
				movie.movie_review.each do |review|
					total = total +review.point
				end
				avg = total / movie.review_size
				movie.point = avg
			end
			puts movie.review_size.to_s + " "+movie.point.to_s
			movie.save
		end

	end

	task :update_movie_review_size_and_points => :environment do

		Movie.all.each do |movie|
			puts movie.title
			movie.review_size = movie.movie_review.size
			if movie.movie_review.size != 0
				total = 0.0
				movie.movie_review.each do |review|
					total = total +review.point
				end
				avg = total / movie.review_size
				movie.point = avg
			end
			puts movie.review_size.to_s + " "+movie.point.to_s
			movie.save
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