class ListWorker
	include Sidekiq::Worker
	sidekiq_options queue: "movie"

	def perform(list_url, movie_round)
		url = URI.parse(list_url)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		movie_host = "http://www.atmovies.com.tw"
		doc.css("div.listall a").each do |movie|
			 title = movie.children[4].to_s.gsub("\r","").gsub("\n","").gsub("\t","")
			 movie_link = movie_host + movie.attr("href")
			 MovieWorker.perform_async(movie_link, movie_round)
		end
	end

end