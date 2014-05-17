require 'sinatra'
require 'soundcloud'

get '/' do
	get_embed()	 
end

def get_embed 
	client = Soundcloud.new(:client_id => '6fe6ce71b46f66b793118edd2284e96c')
	
	tracks = client.get('/tracks', :genres => 'jazz', :licence => 'cc-by-sa', :duration =>  '180000')
	track = tracks.sample
	track_url = track.permalink_url



	embed_info = client.get('/oembed', :url => track_url)

	# print the html for the player widget
	embed_info['html']