require 'sinatra'
require 'haml'
require 'json'
require 'dalli'

get '/' do
	erb :index
end

get '/tracks/:genre/:offset/:limit' do
	# Returns track based on the genre from memcached
	genre = params[:genre]
	offset = params[:offset].to_i
	limit = params[:limit].to_i
	JSON.generate(tracks_fetch(genre,offset,limit))
end

def tracks_fetch genre, offset, limit
	# Memcached communication
	dc = Dalli::Client.new
	dc.get(genre)[offset..limit] || []
end