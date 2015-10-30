require 'rails_helper'

RSpec.describe Api2::MovieController, type: :controller do

  describe "GET #movies" do
    it "returns http success" do
      get :movies
      expect(response).to have_http_status(:success)
    end
  end

end
