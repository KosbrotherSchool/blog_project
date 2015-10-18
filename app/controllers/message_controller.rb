class MessageController < ApplicationController

  def messages
  	if params[:message_id] != nil
      message = Message.find(params[:message_id])
      message.view_count = message.view_count + 1
      message.save
      array = Array.new
      array << message
      array << message.replies.select("author, content, pub_date")
      render :json => array
    else
      messages = Message.select("id, author, title, message_tag, pub_date, view_count, reply_size").order('created_at DESC').paginate(:page => params[:page], :per_page => 10)
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
      message.pub_date = Date.today.to_s
      message.view_count = 0;
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end


  skip_before_filter :verify_authenticity_token, :only => :update_reply

  def update_reply
  	begin
      reply = Reply.new
      reply.author = params[:a]
      reply.content = params[:c]
      reply.pub_date = Date.today.to_s
      reply.message_id = params[:message_id]
      reply.save
      message = Message.find(params[:message_id])
      message.reply_size = message.reply_size + 1
      message.save
      render :json => "ok"
    rescue Exception => e
      render :json => "error"
    end
  end
end
