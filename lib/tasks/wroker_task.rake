require 'net/http'

namespace :worker_task do

	task :test => :environment do
		(1..10).each do |num|
			HardWorker.perform_async("aa","cc")
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
		YahooNewsLink.all.each do |link|
			NewsWorker.perform_async(link.link, link.news_type)
		end
	end

end