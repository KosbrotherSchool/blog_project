class Theater < ActiveRecord::Base
	has_many :movie_times
end
