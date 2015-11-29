class IosMessage < ActiveRecord::Base
	has_many :ios_message_replies
end
