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

	def get_api_connector
		client = Soundcloud.new(:client_id => CLIENT_ID)
	end

	def tracks_api (amount, genre)
		offset = 0
		limit = 200
		client = get_api_connector
		stream_urls = []

		while stream_urls.count < amount
			tracks = client.get('/tracks', :limit => limit, :offset => offset, :genres => genre, :licence => 'cc-by-sa', 
			:"duration[from]" => 150000, :"duration[to]" => 480000)
			tracks.each do |track|
				if track.streamable
					stream_urls << {:title => track.title, :mp3 => track.stream_url, :id => track.id}
				end
			end
			offset += limit
		end

		stream_urls
	end

	def tracks_web pages, genre
		offset = 0
		limit = 50
		tracks_total = []
	  pages.times do
	  	url = "https://api-v2.soundcloud.com/explore/#{genre}?tag=uniform-time-decay-experiment%3A1%3A1389973574&limit=#{limit}&offset=#{offset}&linked_partitioning=1"
	  	begin
	  		tracks = JSON.parse(open(url).read)
	  	rescue Exception
	    tracks_total += tracks['tracks']
	    offset += limit
	  end
	  tracks_total
	end

end