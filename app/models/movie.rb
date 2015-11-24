class Movie < ActiveRecord::Base
	has_many :photos
	has_many :trailers
	has_many :movie_ranks
	has_many :movie_times
	has_many :movie_review
	has_many :movie_area_ships
	has_many :areas, :through => :movie_area_ships
	has_one :pub_movie_rank_table
end
