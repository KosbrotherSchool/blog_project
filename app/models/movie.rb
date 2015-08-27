class Movie < ActiveRecord::Base
	has_many :photos
	has_many :trailers
	has_many :movie_ranks
	has_many :movie_times
end
