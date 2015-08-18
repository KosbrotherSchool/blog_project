class Photo < ActiveRecord::Base

	belongs_to :movie, :class_name => "Movie"

end
