require 'sinatra'
require 'haml'

require "./tracks_provider"

get '/' do
	haml :index
end

get '/tracks' do

end