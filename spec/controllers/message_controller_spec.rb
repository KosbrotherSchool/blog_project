require 'rails_helper'

RSpec.describe MessageController, type: :controller do

  describe "GET #messages" do
    it "returns http success" do
      get :messages
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #update_messages" do
    it "returns http success" do
      get :update_messages
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #update_reply" do
    it "returns http success" do
      get :update_reply
      expect(response).to have_http_status(:success)
    end
  end

end
