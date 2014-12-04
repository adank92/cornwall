require 'sinatra'
require 'json'
require 'dalli'
require 'yaml'

get '/' do
	erb :index
end

get '/tracks/:genre/:offset/:limit' do
	# Returns track based on the genre from memcached
	genre = params[:genre].downcase
	offset = params[:offset].to_i
	limit = params[:limit].to_i
	JSON.generate(tracks_fetch(genre,offset,limit))
end

get '/genres' do
	# Returns available genres
	genres = YAML.load_file('config/genres.yaml')
	genres.map!{ |genre| genre.capitalize }
	JSON.generate(genres)
end

def tracks_fetch genre, offset, limit
	# Memcached communication
	dc = Dalli::Client.new
	dc.get(genre)[offset..limit] || []
end