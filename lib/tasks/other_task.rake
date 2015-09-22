require 'net/http'

namespace :other_task do

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

		Movie.all.each do |movie|
			puts movie.title
			link = movie.yahoo_link
			yahoo_id = link[link.index('id=')+3..link.length].to_i
			movie.yahoo_id = yahoo_id
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