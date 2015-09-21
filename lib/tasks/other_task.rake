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

	task :check_ruby_return_method => :environment do
		num = getANum()
		puts num.to_s
	end

	def getANum()
		return 10
	end

end