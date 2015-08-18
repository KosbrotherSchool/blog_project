class Movie < ActiveRecord::Base

	has_many :photos
	has_many :trailers

end
