class MovieTime < ActiveRecord::Base
	belongs_to :theater
	belongs_to :movie
end
