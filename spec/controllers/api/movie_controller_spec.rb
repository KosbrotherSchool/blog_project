require 'rails_helper'

RSpec.describe Api::MovieController, type: :controller do

  describe "GET #rank_movies" do
    it "returns http success" do
      get :rank_movies
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #first_round_movies" do
    it "returns http success" do
      get :first_round_movies
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #second_round_movies" do
    it "returns http success" do
      get :second_round_movies
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #areas" do
    it "returns http success" do
      get :areas
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #theaters" do
    it "returns http success" do
      get :theaters
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #movie_movietime" do
    it "returns http success" do
      get :movie_movietime
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #theater_movietime" do
    it "returns http success" do
      get :theater_movietime
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #news" do
    it "returns http success" do
      get :news
      expect(response).to have_http_status(:success)
    end
  end

end
