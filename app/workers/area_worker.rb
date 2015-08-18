class AreaWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def perform(area_link, area_id)
    url = URI.parse(area_link)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		theaters = doc.css("span.at11 a")
		theaters.each do | theater |
			theater_title = theater.children[0].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
			theater_link = "http://www.atmovies.com.tw/showtime/" + theater.attr("href")
			puts theater_title
			puts theater_link

			mTheater = Theater.new
			mTheater.name = theater_title
			mTheater.theater_open_eye_link = theater_link
			mTheater.area_id = area_id
			mTheater.save
		end
  end
end