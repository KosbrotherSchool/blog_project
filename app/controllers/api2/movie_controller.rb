class Api2::MovieController < ApplicationController
  def movies
    if params[:movie_id] != nil
      movie = Movie.find(params[:movie_id])
      render :json => movie
    elsif params[:movie_round] != nil
        movie_round = params[:movie_round].to_i
        if movie_round <= 2
          movies = Movie.select('id, title, small_pic, large_pic, point, review_size').where("movie_round = #{movie_round} and yahoo_link is not NULL and is_this_week_new = false").order('publish_date_date DESC').paginate(:page => params[:page], :per_page => 10)
        elsif(movie_round == 3)
          movies = Movie.select('id, title, small_pic, large_pic, point, review_size').where("movie_round = #{movie_round} and yahoo_link is not NULL and is_this_week_new = false").order('publish_date_date ASC').paginate(:page => params[:page], :per_page => 10)
        elsif(movie_round == 4)
           movies = Movie.select('id, title, small_pic, large_pic, point, review_size').where("is_this_week_new = true and yahoo_link is not NULL")
        end
        render :json => movies   
    end
  end

  def rank_movies
    movies = MovieRank.select("movies.id, title, small_pic, large_pic, point, review_size").joins(:movie).where("rank_type = 1 and yahoo_link is not NULL and is_show = true").order('current_rank ASC').paginate(:page => params[:page], :per_page => 10)
    render :json => movies
  end

  # iOS
  def pub_movies
    if params[:page] != nil
      movies = Movie.select('movies.id, title, small_pic, large_pic, point, review_size').joins(:pub_movie_rank_table).paginate(:page => params[:page], :per_page => 10)
    else
      movies = Movie.select('movies.id, title, small_pic, large_pic, point, review_size').joins(:pub_movie_rank_table)
    end
    render :json => movies
  end

end
