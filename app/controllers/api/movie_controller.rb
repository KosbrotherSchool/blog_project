class Api::MovieController < ApplicationController

  def version
    render :json => AppVersion.select("version_name, version_content, version_code").last
  end

  def search
    query = params[:query]
    movies = Movie.select('id, title, title_eng, publish_date, movie_class, actors, movie_type, small_pic').where('title LIKE ? OR title_eng LIKE ? OR actors LIKE ?', "%#{query}%", "%#{query}%", "%#{query}%").paginate(:page => params[:page], :per_page => 10)
    render :json => movies 
  end

  def rank_movies
    # 1 台北票房, 2 全美票房, 3 周票房冠軍 4 年度票房 5 網友期待 6 網友滿意
    rank_type = params[:rank_type].to_i
    if params[:page] == nil
      if params[:new_api] != nil
         movies = MovieRank.select("movies.id, title, title_eng, movie_type, movie_class, publish_date, small_pic, point, review_size").joins(:movie).where("rank_type = #{rank_type} and yahoo_link is not NULL and is_show = true").order('current_rank ASC')
         render :json => movies
      else
        movies = MovieRank.select("movies.id, title, movie_type, movie_class, actors, publish_date, small_pic, publish_weeks, the_week, static_duration, expect_people, total_people, satisfied_num").joins(:movie).where("rank_type = #{rank_type} and yahoo_link is not NULL and is_show = true")
        render :json => movies
      end
    else
      if rank_type == 1
        movies = MovieRank.select("movies.id, title, small_pic, point, review_size").joins(:movie).where("rank_type = #{rank_type} and yahoo_link is not NULL and is_show = true").order('current_rank ASC').paginate(:page => params[:page], :per_page => 10)
        render :json => movies
      end
    end
    
  end

  def movies
    if params[:movie_id] != nil
      movie = Movie.find(params[:movie_id])
      render :json => movie
    elsif params[:movie_round] != nil
        movie_round = params[:movie_round].to_i
        if movie_round <= 2
          movies = Movie.select('id, title, publish_date, movie_class, small_pic, point, review_size').where("movie_round = #{movie_round} and yahoo_link is not NULL and is_this_week_new = false").order('publish_date_date DESC').paginate(:page => params[:page], :per_page => 10)
        elsif(movie_round == 3)
          movies = Movie.select('id, title, publish_date, movie_class, small_pic, point, review_size').where("movie_round = #{movie_round} and yahoo_link is not NULL and is_this_week_new = false").order('publish_date_date ASC').paginate(:page => params[:page], :per_page => 10)
        elsif(movie_round == 4)
           movies = Movie.select('id, title, publish_date, movie_class, actors, movie_type, small_pic, title_eng, point, review_size').where("is_this_week_new = true and yahoo_link is not NULL")
        end
        render :json => movies   
    end
    
  end

  def areas
    if params[:movie_id] != nil
      movie = Movie.find(params[:movie_id])
      areas = movie.areas.where("is_show = true")
      render :json => areas
    else
      areas = Area.select("id, name").all
      render :json => areas
    end
  end

  def theaters
    if params[:area] != nil && params[:area] != ""
      area_id = params[:area].to_i
      theaters = Theater.select("id, name, address, phone, area_id").where(" area_id = #{area_id}")
    else
      theaters = Theater.select("id, name, address, phone, area_id").where(" theater_open_eye_link is NOT NULL or official_site_link is NOT NULL")
    end
    render :json => theaters
  end

  def movietimes
    if params[:theater] != nil
      theater_id = params[:theater].to_i
      times = MovieTime.where("theater_id = #{theater_id} and is_show = true")
    elsif params[:movie] != nil && params[:area] != nil
      movie_id = params[:movie].to_i
      area_id = params[:area].to_i
      times = MovieTime.where("movie_id = #{movie_id} and area_id = #{area_id} and is_show = true")
    end
    render :json => times
  end

  def news
    news_type = params[:news_type].to_i
    news = MovieNews.select("id, title, news_link, publish_day, pic_link").where("news_type = #{news_type}").order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
    render :json => news
  end

  def photos
    movie_id = params[:movie_id].to_i
    photos = Photo.where("movie_id = #{movie_id}")
    render :json => photos
  end

  def trailers
    movie_id = params[:movie_id].to_i
    trailers = Trailer.where("movie_id = #{movie_id}")
    render :json => trailers
  end

  def youtubes
    if params[:column_id] != nil && params[:sub_column_id] != nil
      # return youtube videos
      column_id = params[:column_id].to_i
      sub_column_id = params[:sub_column_id].to_i
      videos = YoutubeVideo.where("youtube_column_id = #{column_id} and sub_column_id = #{sub_column_id}")
      render :json => videos
    elsif params[:column_id] != nil
      # return sub_columns
      column_id = params[:column_id].to_i
      videos = YoutubeVideo.select("*").joins(:youtube_sub_column).where("youtube_videos.youtube_column_id = #{column_id}")
      render :json => videos
    elsif params[:random] != nil
      # return random 10 videos
      videos = YoutubeVideo.limit(5).order("RAND()")
      render :json => videos
    else
      # return columns
      columns = YoutubeColumn.where("is_show = true").order('id DESC').paginate(:page => params[:page], :per_page => 10)
      render :json => columns
    end
  end


  def reviews 
    movie_id = params[:movie_id]
    reviews = MovieReview.select("id, movie_id, author, title, content, publish_date, point, head_index").where("movie_id = #{movie_id}").order('updated_at DESC').paginate(:page => params[:page], :per_page => 10)
    render :json => reviews
  end

  skip_before_filter :verify_authenticity_token, :only => :update_reviews

  def update_reviews
    begin
      review = MovieReview.new
      review.movie_id = params[:m]
      review.author = params[:a]
      review.title = params[:t]
      review.content = params[:c]
      review.point = params[:p]
      review.publish_date = Time.current.to_date.to_s
      review.head_index = params[:h].to_i
      review.save

      movie = Movie.find(params[:m])
      movie.review_size = movie.review_size + 1
      movie.save

      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end

  def blogs
    blogs = MovieBlog.select("id, title, link, pic_link").all
    render :json => blogs
  end

  def movie_by_time
    # params[:time] need to be like "10:" or "17:" ...
    if params[:area_id] != nil && params[:theater_id] != nil
      movie_times = MovieTime.select("remark, movie_title, movie_time, movie_id, theater_id, area_id").where("area_id = #{params[:area_id]} and theater_id = #{params[:theater_id]} and movie_time LIKE '%#{params[:time]}%'")
    elsif params[:area_id] != nil
      movie_times = MovieTime.select("remark, movie_title, movie_time, movie_id, theater_id, area_id").where("area_id = #{params[:area_id]} and movie_time LIKE '%#{params[:time]}%'")
    end
    render :json => movie_times
  end

  def blog_posts
    posts = BlogPost.select("title, link, pub_date, pic_link").order('pub_date DESC').paginate(:page => params[:page], :per_page => 10)
    render :json => posts
  end

  def review_rank
    movies = Movie.select("id, title, title_eng, movie_class, movie_type, small_pic, publish_date, review_size, point").where("movie_round = 1").order('review_size DESC').paginate(:page => params[:page], :per_page => 10)
    render :json => movies
  end

  def point_rank
    movies = Movie.select("id, title, title_eng, movie_class, movie_type, small_pic, publish_date, review_size, point").where("movie_round = 1").order('point DESC').paginate(:page => params[:page], :per_page => 10)
    render :json => movies
  end

  def messages
    if params[:message_id] != nil
      message = Message.find(params[:message_id])
      message.view_count = message.view_count + 1
      message.save
      render :json => message
    else
      messages = Message.select("id, author, title, message_tag, pub_date, view_count").order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
      render :json => messages
    end  
  end

  skip_before_filter :verify_authenticity_token, :only => :update_messages

  def update_messages
    begin
      message = Message.new
      message.author = params[:a]
      message.title = params[:t]
      message.message_tag = params[:tag]
      message.content = params[:c]
      message.pub_date = Time.current.to_date.to_s
      message.view_count = 0;
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end

  def update_open_link
    movie_id = params[:key]
    movie = Movie.find(movie_id)
    movie.open_eye_link = params[:movie][:open_eye_link]
    link = params[:movie][:open_eye_link]
      if link.index("film_id=")
        open_eye_id = link[link.index("film_id=")+8..link.length]
      elsif link.index("filmid=")
        open_eye_id = link[link.index("filmid=")+7..link.length]
      else
        open_eye_id = link[link.index("/movie/")+7..link.length-2]
      end
    movie.open_eye_id = open_eye_id
    movie.save
    redirect_to root_path+"api/movie/open_link_list?page="+params[:page]
  end

  def open_link_list
    
    @movies = Movie.select("id, title, title_eng, open_eye_link, open_eye_id").where("open_eye_link is NULL").paginate(:page => params[:page], :per_page => 10)

  end

  def imdb_list
    
    @movies = Movie.select("id, title, title_eng, imdb_point, imdb_link, potato_point, potato_link, movie_class ").where("movie_round = 1 AND (imdb_point is NULL OR potato_point is NULL OR movie_class = '')").paginate(:page => params[:page], :per_page => 10)

  end

  def update_imdb_and_potato_and_class

    movie_id = params[:key]
    movie = Movie.find(movie_id)

    if movie.movie_class == ""
      movie.movie_class = params[:movie][:movie_class]
    end
    
    if movie.imdb_point == nil
      movie.imdb_point = params[:movie][:imdb_point]
      movie.imdb_link = params[:movie][:imdb_link]
    end
    
    if movie.potato_point == nil
      movie.potato_point = params[:movie][:potato_point]
      movie.potato_link = params[:movie][:potato_link]
    end
    movie.save
    redirect_to root_path+"api/movie/imdb_list?page="+params[:page]
  end

end
