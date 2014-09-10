require 'soundcloud'
require 'json'

class TracksProvider
	CLIENT_ID = 'a2340d5b7b5f7e58128486190268ce71'

	def get_tracks
		offset = 0
		stream_urls = []
		used_ids = []
		client = Soundcloud.new(:client_id => CLIENT_ID)

		while stream_urls.count < 5		
			tracks = client.get('/tracks', :limit => 10, :offset => offset, :genres => 'jazz', 
				:licence => 'cc-by-sa', :"duration[from]" => 150000, :"duration[to]" => 480000)
			tracks.each do |track|
				if track.streamable and not used_ids.include?(track.id.to_s)
					stream_urls << {:title => track.title, :mp3 => track.stream_url, :id => track.id}
				end
			end
			offset += 10
		end
		stream_urls.map! do |track|
			track[:mp3] += "?client_id=#{CLIENT_ID}"
			track
		end

		stream_urls.slice!(0,5).to_json
	end
end