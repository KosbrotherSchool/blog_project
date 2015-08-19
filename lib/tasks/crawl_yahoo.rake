require 'net/http'

namespace :crawl_yahoo do

  task :crawl_up_going_movies => :environment do

    include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    Capybara.app_host = 'https://tw.movies.yahoo.com'

    page.visit '/movie_comingsoon.html'
    doc = Nokogiri::HTML(page.html)
    movies = doc.css(".row-container .item")
    movies.each do |movie|

      title = movie.css(".text h4 a")[0].children[0].to_s
      title_eng =  movie.css(".text h5 a")[0].children[0].to_s
      publish_date = movie.css("span.date span").text
      small_pic = movie.css(".img a img")[0].attr("src")
      link = movie.css(".text h4 a")[0].attr("href")
      
      # puts title
      # puts title_eng
      # puts publish_date
      # puts small_pic
      # puts link

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
        mMovie.update(movie_round: '3')
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.title_eng = title_eng
        mMovie.publish_date = publish_date
        begin
          mMovie.publish_date_date = publish_date.to_date
        rescue Exception => e
          
        end
        mMovie.small_pic = small_pic
        mMovie.yahoo_link = link
        mMovie.movie_round = 3
        mMovie.save
        YahooMovieWorker.perform_async(mMovie.id)
      end

    end

    links = Array.new
    doc.css("a.pagelink").last.remove
    doc.css("a.pagelink").each do |pagelink|

      links << "/movie_comingsoon.html" + pagelink.attr("href")

    end

    links.each do |page_link|

      page.visit page_link
      doc = Nokogiri::HTML(page.html)
      movies = doc.css(".row-container .item")
      movies.each do |movie|

        title = movie.css(".text h4 a")[0].children[0].to_s
        title_eng =  movie.css(".text h5 a")[0].children[0].to_s
        publish_date = movie.css("span.date span").text
        small_pic = movie.css(".img a img")[0].attr("src")
        link = movie.css(".text h4 a")[0].attr("href")
        
        # puts title
        # puts title_eng
        # puts publish_date
        # puts small_pic
        # puts link

        if Movie.where('title LIKE ?', "#{title}").size != 0
          mMovie = Movie.where('title LIKE ?', "#{title}").first
          mMovie.update(movie_round: '3')
        else
          mMovie = Movie.new
          mMovie.title = title
          mMovie.title_eng = title_eng
          mMovie.publish_date = publish_date
          begin
            mMovie.publish_date_date = publish_date.to_date
          rescue Exception => e
            
          end
          mMovie.small_pic = small_pic
          mMovie.yahoo_link = link
          mMovie.movie_round = 3
          mMovie.save
          YahooMovieWorker.perform_async(mMovie.id)
        end

      end

    end

  end

  task :crawl_single_movie => :environment do

    include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    Capybara.app_host = 'https://tw.movies.yahoo.com'

    page.visit '/movieinfo_main.html/id=5631'
    click_on 'yuievtautoid-1'
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

    movie_info = page_no.css(".full p")[0].to_html
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

  end

  task :crawl_thisweek_movies => :environment do
    Movie.update_all(is_this_week_new: false)

    uri = URI.parse('https://tw.movies.yahoo.com/movie_thisweek.html')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)
    doc = Nokogiri::HTML(res.body)

    movies = doc.css(".row-container .item")
    movies.each do |movie|

      title = movie.css(".text h4 a")[0].children[0].to_s
      title_eng =  movie.css(".text h5 a")[0].children[0].to_s
      publish_date = movie.css("span.date span").text
      small_pic = movie.css(".img a img")[0].attr("src")
      link = movie.css(".text h4 a")[0].attr("href")
      
      puts title
      puts title_eng
      puts publish_date
      puts small_pic
      puts link

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
        mMovie.update(movie_round: '1')
        mMovie.update(is_this_week_new: true)
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.title_eng = title_eng
        mMovie.publish_date = publish_date
        begin
          mMovie.publish_date_date = publish_date.to_date
        rescue Exception => e
          
        end
        mMovie.small_pic = small_pic
        mMovie.yahoo_link = link
        mMovie.movie_round = 1
        mMovie.is_this_week_new = true
        mMovie.save
        YahooMovieWorker.perform_async(mMovie.id)
      end

    end

  end

  task :crawl_article_list => :environment do

    include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    Capybara.app_host = 'https://tw.movies.yahoo.com'

    puts "Crawl News List"
    page.visit '/article_news_list.html?p=1'
    page_no = Nokogiri::HTML(page.html)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.each do |news|

      news_ul = news.css("ul")[0]
      news_link = news_ul.children[0].children[1].children[0].attr("href")
      news_title = news_ul.children[0].children[1].children[0].children[0].to_s
      news_info = news_ul.children[0].children[3].children[0].to_s
      news_update_date = news_ul.children[0].children[5].children[1].children[0].to_s
      pic_link = news.css(".pict a").children[0].attr("src")

      # puts news_title
      # puts news_link
      # puts news_info
      # puts news_update_date
      # puts pic_link

    end

    puts "Crawl Movie Guide"
    page.visit '/article_movieguide_list.html?p=1'
    page_no = Nokogiri::HTML(page.html)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.each do |news|

      news_ul = news.css("ul")[0]
      news_link = news_ul.children[0].children[1].children[0].attr("href")
      news_title = news_ul.children[0].children[1].children[0].children[0].to_s
      news_info = news_ul.children[0].children[3].children[0].to_s
      news_update_date = news_ul.children[0].children[5].children[1].children[0].to_s
      pic_link = news.css(".pict a").children[0].attr("src")

      # puts news_title
      # puts news_link
      # puts news_info
      # puts news_update_date
      # puts pic_link

    end

    puts "Crawl Review List"
    page.visit '/article_review_list.html'
    page_no = Nokogiri::HTML(page.html)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.each do |news|

      news_ul = news.css("ul")[0]
      news_link = news_ul.children[0].children[1].children[0].attr("href")
      news_title = news_ul.children[0].children[1].children[0].children[0].to_s
      news_info = news_ul.children[0].children[3].children[0].to_s
      news_update_date = news_ul.children[0].children[5].children[1].children[0].to_s
      pic_link = news.css(".pict a").children[0].attr("src")

      # puts news_title
      # puts news_link
      # puts news_info
      # puts news_update_date
      # puts pic_link

    end

    puts "Crawl Feature List"
    page.visit '/article_features_list.html'
    page_no = Nokogiri::HTML(page.html)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.each do |news|

      news_ul = news.css("ul")[0]
      news_link = news_ul.children[0].children[3].children[0].attr("href")
      news_title = news_ul.children[0].children[3].children[0].children[0].to_s
      news_info = news_ul.children[0].children[5].children[0].to_s
      news_update_date = news_ul.children[0].children[7].children[1].children[0].to_s
      pic_link = news.css(".pict a").children[0].attr("src")

      puts news_title
      puts news_link
      puts news_info
      puts news_update_date
      puts pic_link

    end

  end

  task :crawl_futrue_ranks => :environment do

    include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    Capybara.app_host = 'https://tw.movies.yahoo.com'

    puts "Crawl Expect Rank"
    page.visit '/chart.html?cate=exp_30'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")
    movies.each do |movie|

      rank =  movie.children[1].children[0].children[0].to_s
      
      begin
        title = movie.children[3].css(".text a")[0].children[0].to_s
        movie_link = movie.children[3].css(".text a")[0].attr("href")
      rescue Exception => e
        title = movie.children[3].children[1].children[0].to_s
        movie_link = movie.children[3].children[1].attr("href")
      end

      begin
        publish_date = movie.children[5].children[0].to_s.gsub("\n","").gsub(" ","")
      rescue Exception => e
        publish_date = ""
      end

      begin
        movie_trailer_link = movie.children[7].children[0].children[0].attr("href")
      rescue Exception => e
        movie_trailer_link = ""
      end

      begin
        expect_people = movie.children[9].children[1].children[0].to_s
        total_s =  movie.children[9].children[3].children[0].to_s
        total_s = total_s.gsub("共","")
        total_s = total_s.gsub("人投票","")
      rescue Exception => e
        expect_people = 0
        total_s = 0
      end

      # puts rank + " " + title
      # puts movie_link
      # puts publish_date
      # puts movie_trailer_link
      # puts expect_people + " / " + total_s
      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 5
      mMovieRank.movie_id = mMovie.id
      mMovieRank.current_rank = rank.to_i
      begin
        mMovieRank.expect_people = expect_people.to_i
      rescue Exception => e
        
      end
      begin
        mMovieRank.total_people =  total_s.to_i
      rescue Exception => e
        
      end
      mMovieRank.save

    end

    puts "Crawl Satisfied Rank"
    page.visit '/chart.html?cate=rating'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")
    movies.each do |movie|

      rank =  movie.children[1].children[0].children[0].to_s

      begin
        title = movie.children[3].css(".text a")[0].children[0].to_s
        movie_link = movie.children[3].css(".text a")[0].attr("href")
      rescue Exception => e
        title = movie.children[3].children[1].children[0].to_s
        movie_link = movie.children[3].children[1].attr("href")
      end

      begin
        publish_date = movie.children[5].children[0].to_s.gsub("\n","").gsub(" ","")
      rescue Exception => e
        publish_date = ""
      end

      begin
        movie_trailer_link = movie.children[7].children[0].children[0].attr("href")
      rescue Exception => e
        movie_trailer_link = ""
      end

      begin
        movie_rate = movie.children[9].children[1].children[0].to_s
      rescue Exception => e
        movie_rate = 0
      end
      
      begin
        str = movie.children[9].children[3].children[0].to_s
        str = str.gsub("共","")
        str = str.gsub("人評分","")
        rank_people = str
      rescue Exception => e
        rank_people = "0"
      end

      # puts rank + " " + title
      # puts movie_link
      # puts publish_date
      # puts movie_trailer_link
      # puts movie_rate + " / " + rank_people

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 6
      mMovieRank.movie_id = mMovie.id
      mMovieRank.current_rank = rank.to_i
      mMovieRank.satisfied_num = movie_rate
      begin
        mMovieRank.total_people =  rank_people.to_i
      rescue Exception => e
        
      end
      mMovieRank.save

    end

  end

  task :crawl_movie_ranks => :environment do
    MovieRank.delete_all

    include Capybara::DSL
    Capybara.current_driver = :selenium_chrome
    Capybara.app_host = 'https://tw.movies.yahoo.com'

    puts "Crawl Taipei Rank"
    page.visit '/chart.html?cate=taipei'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")
    movies.each do |movie|
 
      rank =  movie.children[1].children[1].children[0].to_s
      last_week_rank  = movie.children[3].children[0].to_s.gsub("\n","")
      
      begin
        title = movie.children[5].css(".text a")[0].children[0].to_s
        movie_link = movie.children[5].css(".text a")[0].attr("href")
      rescue Exception => e
        title = movie.children[5].children[1].children[0].to_s
        movie_link = movie.children[5].children[1].attr("href")
      end
      
      begin
        publish_weeks = movie.children[7].children[0].to_s.gsub("\n","").gsub(" ","")
      rescue Exception => e
        publish_weeks = ""
      end
      
      begin
        movie_trailer_link = movie.children[9].children[0].children[0].attr("href")
      rescue Exception => e
        movie_trailer_link = ""
      end
      
      begin
        str = movie.children[11].children[0].attr("src")
        viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d
        if viwer_rating > 10
          viwer_rating = viwer_rating / 10
        end
      rescue Exception => e
        viwer_rating = "0"
      end

      # puts rank + " " + last_week_rank + " "+ title + " "
      # puts movie_link
      # puts publish_weeks
      # puts movie_trailer_link
      # puts viwer_rating.to_s

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 1
      mMovieRank.movie_id = mMovie.id
      mMovieRank.current_rank = rank.to_i
      mMovieRank.last_week_rank = last_week_rank.to_i
      mMovieRank.satisfied_num = viwer_rating.to_s
      mMovieRank.save

    end 

    puts "Crawl US Rank"
    page.visit '/chart.html?cate=us'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")
    movies.each do |movie|
 
      rank =  movie.children[1].children[1].children[0].to_s
      last_week_rank  = movie.children[3].children[0].to_s.gsub("\n","")
      
      begin
        title = movie.children[5].css(".text a")[0].children[0].to_s
        movie_link = movie.children[5].css(".text a")[0].attr("href")
      rescue Exception => e
        title = movie.children[5].children[1].children[0].to_s
        movie_link = movie.children[5].children[1].attr("href")
      end

      if title == "" 
        title = movie.children[5].children[0].to_s.gsub("\n","")
      end
      
      begin
        publish_date = movie.children[7].children[0].to_s.gsub("\n","").gsub(" ","")
      rescue Exception => e
        publish_date = ""
      end
      
      begin
        movie_trailer_link = movie.children[9].children[0].children[0].attr("href")
      rescue Exception => e
        movie_trailer_link = ""
      end
      
      begin
        str = movie.children[11].children[0].attr("src")
        viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d
        if viwer_rating > 10
          viwer_rating = viwer_rating / 10
        end
      rescue Exception => e
        viwer_rating = "0"
      end

      # puts rank + " " + last_week_rank + " "+ title + " "
      # puts movie_link
      # puts publish_date
      # puts movie_trailer_link
      # puts viwer_rating.to_s

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 2
      mMovieRank.movie_id = mMovie.id
      mMovieRank.current_rank = rank.to_i
      mMovieRank.last_week_rank = last_week_rank.to_i
      mMovieRank.satisfied_num = viwer_rating.to_s
      mMovieRank.save

    end

    puts "Crawl Week Rank"
    page.visit '/chart.html?cate=week'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")

    movies.each do |movie|

      week_num = movie.children[1].children[1].children[0].to_s
      duration = movie.children[3].children[0].to_s + movies[1].children[3].children[2].to_s.gsub("\n","")
      title = movie.children[5].children[1].children[0].to_s
      movie_link = movie.children[5].children[1].attr("href")
      show_weeks = movie.children[7].children[0].to_s.gsub("\n","").gsub(" ","")
      movie_trailer_link = movie.children[9].children[0].children[0].attr("href")
      begin
        str = movie.children[11].children[0].attr("src")
        viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d
        if viwer_rating > 10
          viwer_rating = viwer_rating / 10
        end
      rescue Exception => e
        viwer_rating = "0"
      end

      # puts week_num + " " + duration
      # puts title + " " + show_weeks
      # puts movie_link
      # puts movie_trailer_link
      # puts viwer_rating.to_s

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 3
      mMovieRank.movie_id = mMovie.id
      mMovieRank.the_week = week_num
      mMovieRank.static_duration = duration
      mMovieRank.publish_weeks = show_weeks
      mMovieRank.satisfied_num = viwer_rating.to_s
      mMovieRank.save

    end

    puts "Crawl Year Rank"
    page.visit '/chart.html?cate=year'
    page_no = Nokogiri::HTML(page.html)
    page_no.css("tbody tr").first.remove
    movies = page_no.css("tbody tr")

    movies.each do |movie|
      rank =  movie.children[1].children[1].children[0].to_s

      begin
        title = movie.children[5].css(".text a")[0].children[0].to_s
        movie_link = movie.children[5].css(".text a")[0].attr("href")
      rescue Exception => e
        title = movie.children[5].children[1].children[0].to_s
        movie_link = movie.children[5].children[1].attr("href")
      end

      if title == "" 
        title = movie.children[5].children[0].to_s.gsub("\n","")
      end
      
      begin
        publish_date = movie.children[7].children[0].to_s.gsub("\n","").gsub(" ","")
      rescue Exception => e
        publish_date = ""
      end
      
      begin
        movie_trailer_link = movie.children[9].children[0].children[0].attr("href")
      rescue Exception => e
        movie_trailer_link = ""
      end
      
      begin
        str = movie.children[11].children[0].attr("src")
        viwer_rating = str[str.index("rating_star_")..str.length].gsub("rating_star_","").gsub(".gif","").to_d
        if viwer_rating > 10
          viwer_rating = viwer_rating / 10
        end
      rescue Exception => e
        viwer_rating = "0"
      end

      # puts rank + " "+ title + " "
      # puts movie_link
      # puts publish_date
      # puts movie_trailer_link
      # puts viwer_rating.to_s

      if Movie.where('title LIKE ?', "#{title}").size != 0
        mMovie = Movie.where('title LIKE ?', "#{title}").first
      else
        mMovie = Movie.new
        mMovie.title = title
        mMovie.yahoo_link = movie_link
        mMovie.save
        if mMovie.yahoo_link != nil && mMovie.yahoo_link != ""
          YahooMovieWorker.perform_async(mMovie.id)
        end
      end
      

      mMovieRank = MovieRank.new
      mMovieRank.rank_type = 4
      mMovieRank.movie_id = mMovie.id
      mMovieRank.current_rank = rank.to_i
      mMovieRank.satisfied_num = viwer_rating.to_s
      mMovieRank.save

    end

  end

  task :crawl_movie_news => :environment do

    uri = URI.parse('https://tw.movies.yahoo.com/article_news_list.html?p=1')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    page_no = Nokogiri::HTML(res.body)
    page_no.css(".item").last.remove
    all_news = page_no.css(".item")
    all_news.each do |news|

      news_ul = news.css("ul")[0]
      news_link = news_ul.children[0].children[1].children[0].attr("href")
      news_title = news_ul.children[0].children[1].children[0].children[0].to_s
      news_info = news_ul.children[0].children[3].children[0].to_s
      news_update_date = news_ul.children[0].children[5].children[1].children[0].to_s
      pic_link = news.css(".pict a").children[0].attr("src")

      puts news_title
      puts news_link
      puts news_info
      puts news_update_date
      puts pic_link

    end

  end

end