class NewsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def perform(link, news_type)
    uri = URI.parse(link)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    page_no = Nokogiri::HTML(res.body)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.reverse_each do |news|

      news_ul = news.css("ul")[0]
      if news_ul.css("li.text a")[0].attr("href").index("https")
        news_link = news_ul.css("li.text a")[0].attr("href")
      else
        news_link = "https://tw.movies.yahoo.com"+ news_ul.css("li.text a")[0].attr("href")
      end
      news_link = "https://tw.movies.yahoo.com/news/" + news_link.split('/').last

      news_title = news_ul.css("li.text a")[0].text
      news_info = news_ul.css("li.text p")[0].children[0].text
      news_update_date = news_ul.css("span.date span")[0].text
      pic_link = news.css(".pict img")[0].attr("src")

      puts news_title
      
      if MovieNews.where('title LIKE ?', "#{news_title}").size != 0
        puts "Already has this movie news"
      else
        mNews = MovieNews.new
        mNews.title = news_title
        mNews.info = news_info
        mNews.news_link = news_link
        mNews.publish_day = news_update_date
        mNews.pic_link = pic_link
        begin
        	mNews.publish_date = news_update_date.to_date
        rescue Exception => e
        	
        end
        mNews.news_type = news_type
  			mNews.save
      end

    end
  end
end