class Movie < ActiveRecord::Base

	has_many :photos
	has_many :trailers
	has_many :movie_ranks
end
