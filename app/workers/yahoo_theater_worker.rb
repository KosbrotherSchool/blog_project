require 'net/http'

class YahooTheaterWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def parselink(link)
    if link != nil && link.index("*")
      link = link[link.index("*")+1..link.length]
    end
    return link
  end

  def parseYahooId(link)
    if link != nil && link.index('id=')
      yahoo_id = link[link.index('id=')+3..link.length].to_i
      return yahoo_id
    end
    return nil
  end

  def perform(theater_id)
    theater = Theater.find(theater_id)
    uri = URI.parse(theater.yahoo_link)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # You should use VERIFY_PEER in production
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)
    doc = Nokogiri::HTML(res.body)

    items = doc.css(".vlist .item")
    items.each do |item|

      title = item.css(".text h4").text.strip
      remark = ""
      item.css(".mvtype img").each do |img|
        if img.attr("src").index("digital.gif")
          remark = remark + "數位,"
        end
        if img.attr("src").index("chi.gif")
          remark = remark + "中文,"
        end
        if img.attr("src").index("imax.gif")
          remark = remark + "IMAX,"
        end
        if img.attr("src").index("3d.gif")
          remark = remark + "3D,"
        end
        if img.attr("src").index("atmos.gif")
          remark = remark + "Atmos,"
        end
      end
      if remark != ""
        remark = remark[0..remark.length - 2]
      end

      movie_link = item.css(".text h4 a")[0].attr("href")
      movie_link = parselink(movie_link)
      yahoo_id = parseYahooId(movie_link)

      if yahoo_id != nil
        if Movie.where("yahoo_id = #{yahoo_id}").size != 0
          mMovie = Movie.where("yahoo_id = #{yahoo_id}").first
          mMovie.update(:movie_round => 1)
        else
          mMovie = Movie.new
          mMovie.title = title
          mMovie.yahoo_link = yahoo_link
          mMovie.movie_round = 1
          mMovie.yahoo_id = yahoo_id
          mMovie.save
          YahooMovieWorker.perform_async(mMovie.id)
        end

        movie_time = ""
        item.css("span.tmt").each do |time|
          movie_time = movie_time + time.text + ","
        end
        if movie_time != ""
          movie_time = movie_time[0..movie_time.length - 2]
        end
        
        mMovieTime = MovieTime.new
        mMovieTime.remark = remark;
        mMovieTime.movie_title = title;
        mMovieTime.movie_id = mMovie.id;
        mMovieTime.movie_time = movie_time
        mMovieTime.theater_id = theater_id
        mMovieTime.area_id = theater.area_id
        mMovieTime.movie_photo = mMovieTime.movie.small_pic
        mMovieTime.save

        if MovieAreaShip.where("movie_id = #{mMovieTime.movie_id} AND area_id = #{mMovieTime.area_id} AND is_show = false").size == 0
          mMovieAreaShip = MovieAreaShip.new
          mMovieAreaShip.movie_id = mMovieTime.movie_id
          mMovieAreaShip.area_id = mMovieTime.area_id
          mMovieAreaShip.save
        end
        
      end

    end

  end

end