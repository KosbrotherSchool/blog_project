class Api::MovieController < ApplicationController

  def rank_movies
    # 1 台北票房, 2 全美票房, 3 周票房冠軍 4 年度票房 5 網友期待 6 網友滿意
    rank_type = params[:rank_type].to_i
    movies = MovieRank.select("*").joins(:movie).where("rank_type = #{rank_type} and yahoo_link is not NULL")
    render :json => movies
  end

  def movies
    if params[:movie_id] != nil
      movie = Movie.find(params[:movie_id])
      render :json => movie
    elsif params[:movie_round] != nil
      if params[:movie_round].to_i != 4
          movie_round = params[:movie_round].to_i
          movies = Movie.where("movie_round = #{movie_round} and yahoo_link is not NULL").paginate(:page => params[:page], :per_page => 10)
          render :json => movies
      else
          movies = Movie.where("is_this_week_new = true and yahoo_link is not NULL").paginate(:page => params[:page], :per_page => 10)
          render :json => movies
      end     
    end
    
  end

  def areas
    areas = Area.select("id, name").all
    render :json => areas
  end

  def theaters
    if params[:area] != nil && params[:area] != ""
      area_id = params[:area].to_i
      theaters = Theater.select("id, name, address, phone, area_id").where(" area_id = #{area_id}")
    else
      theaters = Theater.select("id, name, address, phone, area_id").all
    end
    render :json => theaters
  end

  def movietimes
    if params[:theater] != nil
      theater_id = params[:theater].to_i
      times = MovieTime.where("theater_id = #{theater_id}")
    elsif params[:movie] != nil && params[:area] != nil
      movie_id = params[:movie].to_i
      area_id = params[:area].to_i
      times = MovieTime.where("movie_id = #{movie_id} and area_id = #{area_id}")
    end
    render :json => times
  end

  def news
    news_type = params[:news_type].to_i
    news = MovieNews.where("news_type = #{news_type}").paginate(:page => params[:page], :per_page => 10)
    render :json => news
  end

  def photos
    movie_id = params[:movie].to_i
    photos = Photo.where("movie_id = #{movie_id}")
    render :json => photos
  end

  def youtubes
    if params[:column_id] != nil && params[:sub_column_id] != nil
      # return youtube videos
      column_id = params[:column_id].to_i
      sub_column_id = params[:sub_column_id].to_i
      videos = YoutubeVideo.where("youtube_column_id = #{column_id} and sub_column_id = #{sub_column_id}")
    elsif params[:column_id] != nil
      # return sub_columns
      videos = YoutubeVideo.select("*").includes(:youtube_sub_column).where("youtube_column_id = 1").size
    else
      # return random 10 videos
      videos = YoutubeVideo.limit(10).order("RAND()")
    end
    render :json => videos
  end

end
