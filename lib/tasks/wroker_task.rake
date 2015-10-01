require 'net/http'

namespace :worker_task do

	task :test => :environment do
		(1..10).each do |num|
			HardWorker.perform_async("aa","cc")
		end
	end

	task :yahoo_first_round_movie_reviews => :environment do
		Movie.where("movie_round = 1 and is_review_crawled = false and yahoo_id is not NULL").each do |movie|
			YahooReviewWorker.perform_async(movie.id)
		end
	end

	task :run_first_round_movie_workers => :environment do
		open_eye_first_round_url = "http://www.atmovies.com.tw/movie/movie_now-0.html"
		ListWorker.perform_async(open_eye_first_round_url, 1)
	end

	task :run_second_round_movie_workers => :environment do
		open_eye_second_round_url = "http://www.atmovies.com.tw/movie/movie_now2-0.html"
		ListWorker.perform_async(open_eye_second_round_url, 2)
	end

	task :run_theater_get_movie_time_workers => :environment do
		# MovieAreaShip.delete_all
		# MovieTime.delete_all
		Theater.all.each do |theater|
			TheaterWorker.perform_async(theater.theater_open_eye_link, theater.id)
		end
	end

	task :run_area_get_theater_workers => :environment do
		Area.all.each do |area|
			AreaWorker.perform_async(area.open_eye_area_link, area.id)
		end
	end

	task :run_movie_news_worker => :environment do
		YahooNewsLink.all.reverse.each do |link|
			NewsWorker.perform_async(link.link, link.news_type)
		end
	end

	task :run_yahoo_theater_get_movie_time => :environment do
		Theater.where("theater_open_eye_link is NULL").each do |theater|
			YahooTheaterWorker.perform_async(theater.id)
		end
	end

	task :run_open_eye_theater_get_movie_time => :environment do
		Theater.where("theater_open_eye_link is NOT NULL").each do |theater|
			OpenEyeTheaterWorker.perform_async(theater.id)
		end
	end

	task :run_movie_get_photos_trailers => :environment do
		Movie.where("open_eye_link IS NOT NULL and open_eye_link != '' and is_open_eye_crawled = false ").each do |movie|
			MovieWorker.perform_async(movie.id)
		end
	end

	task :get_movie_by_yahoo_id => :environment do

		(101..5970).each do |yahoo_id|
			if Movie.where("yahoo_id = #{yahoo_id}").size == 0
				YahooMovieWorkerByYahooID.perform_async(yahoo_id)
			end
		end

	end

end