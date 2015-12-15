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
      movies = Movie.select('movies.id, title, movie_class, small_pic, large_pic, point, review_size').joins(:pub_movie_rank_table).paginate(:page => params[:page], :per_page => 20)
    else
      movies = Movie.select('movies.id, title, small_pic, large_pic, point, review_size').joins(:pub_movie_rank_table)
    end
    render :json => movies
  end

  def second_movies
    if params[:page] != nil
      movies = Movie.select('id, title, small_pic, large_pic, point, review_size').where("movie_round = 2").order('publish_date_date DESC').paginate(:page => params[:page], :per_page => 20)
    else
      movies = Movie.select('movies.id, title, small_pic, large_pic, point, review_size').where("movie_round = 2").order('publish_date_date DESC')
    end
    render :json => movies
  end

  def up_going_movies
    if params[:page] != nil
      movies = Movie.select('id, title, small_pic, large_pic, publish_date').where("movie_round = 3 and yahoo_link is not NULL and is_this_week_new = false").order('publish_date_date ASC').paginate(:page => params[:page], :per_page => 20)
    else
      movies = Movie.select('id, title, small_pic, large_pic, publish_date').where("movie_round = 3").order('publish_date_date ASC')
    end
    render :json => movies
  end

  def message
    if params[:page].to_i == 1
      h_messsages = IosMessage.where(" board_id = #{params[:board_id]} and is_head = true")
      messages = IosMessage.where(" board_id = #{params[:board_id]} and is_head = false ").order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      messages.each do |theMessage|
        h_messsages << theMessage
      end
      render :json =>  h_messsages
    else
      messages = IosMessage.where(" board_id = #{params[:board_id]} and is_head = false ").order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      render :json => messages 
    end
  end

  def highlight_messages
    messages = IosMessage.where(" is_highlight = true")
    render :json => messages
  end

  def reply
    message = IosMessage.find(params[:message_id])
    message.view_count = message.view_count + 1
    message.save
    replies = IosMessageReply.where(" ios_message_id = #{params[:message_id]}").paginate(:page => params[:page], :per_page => 20)
    render :json => replies
  end

  def update_message_like
    begin
      message = IosMessage.find(params[:message_id])
      message.like_count = message.like_count + 1
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end

  def update_reply_like
    begin
      reply = IosMessageReply.find(params[:reply_id])
      reply.like_count = reply.like_count + 1
      reply.save
      render :json => "ok"
    rescue Exception => e
       render :json => "error"
    end
  end

  def news
    news_type = params[:news_type].to_i
    news = MovieNews.select("id, title, news_link, publish_day, pic_link").where("news_type = #{news_type}").order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    render :json => news
  end

  def blog_posts
    posts = BlogPost.select("title, link, pub_date, pic_link").order('pub_date DESC').paginate(:page => params[:page], :per_page => 20)
    render :json => posts
  end

  def search
    query = params[:query]
    movies = Movie.select('id, title, title_eng, publish_date, movie_class, actors, movie_type, small_pic').where('title LIKE ? OR title_eng LIKE ? OR actors LIKE ?', "%#{query}%", "%#{query}%", "%#{query}%").paginate(:page => params[:page], :per_page => 20)
    render :json => movies 
  end

  def reviews 
    movie_id = params[:movie_id]
    reviews = MovieReview.select("id, movie_id, author, title, content, publish_date, point, head_index").where("movie_id = #{movie_id}").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
    render :json => reviews
  end

  skip_before_filter :verify_authenticity_token, :only => :update_messages

  def update_messages
    begin
      message = IosMessage.new
      message.board_id = params[:b]
      message.author = params[:a]
      message.title = params[:t]
      message.tag = params[:tag]
      message.content = params[:c]
      message.pub_date = Time.current.to_date.to_s
      message.head_index = params[:h].to_i
      message.link_url = params[:l]
      
      message.view_count = 0
      message.like_count = 0
      message.reply_size = 0
      message.is_head = false
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end

  skip_before_filter :verify_authenticity_token, :only => :update_replies

  def update_replies
    begin
      reply = IosMessageReply.new
      reply.ios_message_id = params[:m_id]
      reply.author = params[:a]
      reply.content = params[:c]
      reply.pub_date = Time.current.to_date.to_s
      reply.head_index = params[:h].to_i
      reply.save

      message = IosMessage.find(params[:m_id])
      message.reply_size = message.reply_size + 1
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end


end
