class MovieAreaShip < ActiveRecord::Base
	belongs_to :movie
	belongs_to :area
end
