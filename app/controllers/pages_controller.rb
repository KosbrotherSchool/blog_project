class PagesController < ApplicationController
  
  def index
  	@user = User.new
  end

  def send_message
  	@user = User.new(user_params)
  	if @user.save
  		redirect_to :controller => 'pages', :action => 'index', :msg => 'success'
  	else
  		redirect_to :controller => 'pages', :action => 'index', :msg => 'error'
  	end
  end

  private

  def user_params
  	params.require(:user).permit(:name,:email,:message)
  end

end
