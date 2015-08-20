class Api::MovieController < ApplicationController

  def rank_movies
    # 1 台北票房, 2 全美票房, 3 周票房冠軍 4 年度票房 5 網友期待 6 網友滿意
    rank_type = params[:rank_type].to_i
    movies = MovieRank.select("*").joins(:movie).where("rank_type = #{rank_type}")
    render :json => movies
  end

  def movies
    movie_round = params[:movie_round].to_i
    movies = Movie.where("movie_round = #{movie_round}").paginate(:page => params[:page], :per_page => 10)
    render :json => movies
  end

  def areas
    areas = Area.all
    render :json => areas
  end

  def theaters
    if params[:area] != nil && params[:area] != ""
      area_id = params[:area].to_i
      theaters = Theater.where(" area_id = #{area_id}")
    else
      theaters = Theater.all.paginate(:page => params[:page], :per_page => 10)
    end
    render :json => theaters
  end

  def movietimes
    if params[:theater] != nil && params[:movie_id] != nil
      theater_id = params[:theater].to_i
      movie_id = params[:movie].to_i
      times = MovieTimes.where("theater_id = #{theater_id} and movie_id = #{movie_id}")
    elsif params[:theater] != nil
      theater_id = params[:theater].to_i
      times = MovieTimes.where("theater_id = #{theater_id}")
    elsif params[:movie] != nil
      movie_id = params[:movie].to_i
      times = MovieTimes.where("movie_id = #{movie_id}")
    end
    render :json => times
  end

  def news
    news_type = params[:news_type].to_i
    news = MovieNews.where("news_type = #{news_type}").paginate(:page => params[:page], :per_page => 10)
    render :json => news
  end
end
