require('sinatra')
require('sinatra/contrib/all')
require_relative('./models/film')
also_reload('./models/*')

get "/film" do
  @films = Film.all()
  erb(:films)
end

get "/film/:name" do
  Film.find_by_name(params[:name].tr('_',' '))
end
