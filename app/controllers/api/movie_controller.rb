class Api::MovieController < ApplicationController

  def rank_movies
    # 1 台北票房, 2 全美票房, 3 周票房冠軍 4 年度票房 5 網友期待 6 網友滿意
    rank_type = params[:rank_type].to_i
    movies = MovieRank.select("*").joins(:movie).where("rank_type = 1")
    render :json => movies
  end

  def first_round_movies
  end

  def second_round_movies
  end

  def areas
  end

  def theaters
  end

  def movie_movietime
  end

  def theater_movietime
  end

  def news
  end
end
