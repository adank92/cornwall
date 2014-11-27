require 'sinatra'
require 'haml'
require 'json'
require 'dalli'

WEB_PAGE_SIZE = 20

get '/' do
	erb :index
end

get '/tracks/:genre/:page' do
	genre = params[:genre]
	page = params[:page].to_i
	JSON.generate(tracks_fetch(genre,page))
end

def tracks_fetch genre, page
	dc = Dalli::Client.new
	offset = page * WEB_PAGE_SIZE
	limit = offset + WEB_PAGE_SIZE
	dc.get(genre)[offset..limit] || []
end