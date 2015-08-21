require 'net/http'

class YahooMovieWorker
  include Sidekiq::Worker
  include Capybara::DSL
  sidekiq_options queue: "movie_yahoo"

  def perform(movie_id)

    Capybara.current_driver = :selenium_chrome

    mMovie = Movie.find(movie_id)

    page.visit mMovie.yahoo_link
    begin
    	click_on 'yuievtautoid-1'
    rescue Exception => e
    	
    end 
    page_no = Nokogiri::HTML(page.html)

    title = page_no.css(".text.bulletin h4").text
    title_eng = page_no.css(".text.bulletin h5").text

    movie_class = ""
    str = page_no.css("img.gate")[0].attr("src")
    if str.index("icon_gate_1")
      movie_class = "普通級"
    elsif str.index("icon_gate_2")
      movie_class = "保護級"
    elsif str.index("icon_gate_3")
      movie_class = "輔導級"
    elsif str.index("icon_gate_4")
      movie_class = "限制級"
    end

    movie_info = ""
    if page_no.css(".full p")[0] != nil
    	movie_info = page_no.css(".full p")[0].to_html
    elsif page_no.css(".text.show p")[0] != nil 
    	movie_info = page_no.css(".text.show p")[0].to_html
    end
    medium_pic = page_no.css(".border img")[0].attr("src")
    large_pic = page_no.css(".ourter a")[0].attr("href")

    publish_date = page_no.css("span.dta")[0].children[0].to_s
    type = page_no.css("span.dta")[1].text
    length = page_no.css("span.dta")[2].text
    director = page_no.css("span.dta")[3].text
    actors = page_no.css("span.dta")[4].text
    official = page_no.css("span.dta")[5].text

    puts title
    puts title_eng
    puts movie_class
    puts movie_info
    puts publish_date
    puts type
    puts length
    puts director
    puts actors
    puts official

    
    mMovie.title = title
    mMovie.title_eng = title_eng
    mMovie.movie_class = movie_class
    mMovie.movie_info = movie_info
    mMovie.publish_date = publish_date
    mMovie.director = director
    mMovie.actors = actors
    mMovie.official = official
    mMovie.movie_type = type
    mMovie.movie_length = length
    begin
    	 mMovie.publish_date_date = publish_date.to_date
    rescue Exception => e
    	
    end
   	mMovie.small_pic = medium_pic
   	mMovie.large_pic = large_pic
   	mMovie.movie_class = movie_class
   	mMovie.is_yahoo_crawled = true
   	mMovie.save

  end
end