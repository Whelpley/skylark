require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { User.create(username: 'bob', email: 'someone@gmail.com', password: 'something') }
  let(:file_to_upload) { fixture_file_upload('export.tiff', 'image/tiff') }
  before do
    sign_in user
  end

  describe '#create' do
    let(:tileset_name) { 'Fatma image' }
    let(:description) { 'This is an image' }
    let(:camera_type) { 'Canon Camera'}
    let(:date_string) { '2016-12-02'}
    let(:params) do
      {
          image: {
              tileset_name: tileset_name,
              description:  description,
              camera_type:  camera_type,
              date_taken:   date_string,
              image_file:   file_to_upload
          }
      }
    end

    describe 'happy path' do
      it 'calls the MapBoxService to upload files' do
        expect_any_instance_of(MapBoxService).to receive(:upload_file).with(file_to_upload, tileset_name)
        post :create, params
      end

      it 'redirects to images path' do
        post :create, params
        expect(response).to redirect_to images_path
      end

      it 'sets the flash message' do
        post :create, params
        expect(flash[:success]).to eq ["You have successfully uploaded an image with title of #{tileset_name}!"]
      end

      it 'saves the image record' do
        post :create, params

        image = Image.last
        expect(image.tileset_name).to eq tileset_name
        expect(image.description).to eq description
        expect(image.camera_type).to eq camera_type
        expect(image.date_taken).to eq Date.parse(date_string)
      end
    end

    describe 'validation errors' do
      it 'renders new if image node is missing' do
        post :create
        expect(response).to render_template 'images/new'
      end

      it 'sets a flash message if image node is missing' do
        post :create
        expect(flash[:error]).to eq ['Something went wrong. Please try again.']
      end

      it 'renders new if image fails activerecord validation' do
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        post :create, params
        expect(response).to render_template 'images/new'
      end

      it 'sets a flash message if image node is missing' do
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        allow_any_instance_of(Image).to receive(:errors).and_return(double(full_messages: ['error']))

        post :create, params
        expect(flash[:error]).to eq ['error']
      end

    end
  end
end


# Jordan's example code
# describe ArticlesController do
#   let(:article) { FactoryGirl.create :article}
#   let(:attributes) { FactoryGirl.attributes_for :article}
#   describe "GET #index" do
#     before(:each) do
#       get :index
#     end
#     it "responds with a 200" do
#       expect(response.status).to eq(200)
#     end
#     it "assigns the articles instance variable" do
#       expect(assigns(:articles)).to be_a(ActiveRecord::Relation)
#     end
#     it "assigns the article instance variable" do
#       expect(assigns(:article)).to be_a(Article)
#     end
#   end

#   describe 'POST #create' do
#     it "saves a new article in the database" do
#       expect{
#       post :create, :article => attributes}.to change{ Article.count}.by(1)
#     end
#     it "redirects to the root path" do
#       post :create, :article => attributes
#       expect(response.status).to eq(302)
#     end
#   end
#   describe 'GET #show' do
#     before(:each) do
#       get :show, id: article.id
#     end
#     it "assigns the article instance variable" do
#       expect(assigns(:article)).to be_a(Article)
#     end
#   end
#   describe 'PUT #update' do
#     let!(:title) { "A treatise on Malomars." }
#     it 'updates a field on an article' do
#       put :update, id: article.id, article: { title: title, body: article.body }
#       expect(article.reload.title).to eq(article.title)
#     end
#   end
#   describe 'DELETE #destroy' do
#     it 'decrements articles by one' do
#       article_id = article.id
#       expect {
#         delete :destroy, id: article_id
#       }.to change{ Article.count }.by(-1)
#     end
#     it 'redirects to the root path' do
#       article_id = article.id
#       delete :destroy, id: article_id
#       expect(response.status).to eq(302)
#     end
#   end

# end
