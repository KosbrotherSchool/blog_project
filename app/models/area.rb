class Area < ActiveRecord::Base
	has_many :movie_area_ships
	has_many :movies, :through => :movie_area_ships
end
