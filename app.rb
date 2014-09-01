require 'sinatra'
require 'soundcloud'
require 'json'
require 'haml'

CLIENT_ID = 'a2340d5b7b5f7e58128486190268ce71'

def get_tracks(offset)
	client = Soundcloud.new(:client_id => CLIENT_ID)

	tracks = client.get('/tracks', :limit => 10, :offset => offset, :genres => 'jazz', :licence => 'cc-by-sa', :"duration[from]" => 150000, :"duration[to]" => 480000)
end

def get_embed 
	get_tracks
	track_url = tracks.sample.permalink_url

	embed_info = client.get('/oembed', :url => track_url)

	# print the html for the player widget
	embed_info['html']
end

get '/' do
	haml :index
end

post '/getTracksUrl' do
	used_ids = params[:used_ids] || []
	begin
		offset = offset ? offset + 10 : 0
		tracks = get_tracks(offset)
		stream_urls ||= []
		stream_urls  = 	tracks.inject(stream_urls) do |acc, track|
						   acc << {:title => track.title, :mp3 => track.stream_url, :id => track.id} if track.streamable && !used_ids.include?(track.id.to_s)
						   acc
						end
	end while stream_urls.count < 5

	stream_urls.collect! do |track|
		track[:mp3] += "?client_id=#{CLIENT_ID}"
		track
	end

	stream_urls.slice!(0,5).to_json
end