require 'soundcloud'
require 'json'
require 'open-uri'

class TracksProvider
	CLIENT_ID = 'a2340d5b7b5f7e58128486190268ce71'
	PAGE_SIZE = 200
	PAGE_COUNT = 2
	LICENSE = 'cc-by-sa'
	GENRES = ['jazz']

	def update
		client = get_api_connector
		tracks = []

		GENRES.each do |genre|
			tracks.concat(fetch_tracks_api(genre,client))
			tracks.concat(fetch_tracks_web(genre))
		end

		tracks.uniq! { |t| t['uri'].split('/').last }
		tracks.map! { |track| track_summary(track) }
		tracks.sort_by! { |t| -t[:freshness] }

		tracks
	end

	def fetch_tracks_api genre, client
		client ||= get_api_connector
		stream_urls = []
		params = {
			:genres => genre,
			:limit => PAGE_SIZE,
			:licence => LICENSE,
			:"duration[from]" => 150000,
			:"duration[to]" => 480000
		}

		PAGE_COUNT.times do |page|
			puts "Fetching from API. Genre #{genre}, Page #{page}"
			params[:offset] = PAGE_SIZE * page
			tracks = client.get('/tracks', params)
			tracks.each do |track|
				stream_urls << track if track.streamable
			end
		end
		puts "Returning total: #{stream_urls.count}"
		stream_urls
	end

	def fetch_tracks_web genre
		tracks_total = []
		PAGE_COUNT.times do |page|
			puts "Fetching from WEB. Genre #{genre}, Page #{page}"
			offset = PAGE_SIZE * page
			url = "https://api-v2.soundcloud.com/explore/#{genre}?tag=uniform-time-decay-experiment%3A1%3A1389973574&limit=#{PAGE_SIZE}&offset=#{offset}&linked_partitioning=1"
			begin
				tracks = JSON.parse(open(url).read)
			rescue Exception
			end
			tracks_total.concat(tracks['tracks'])
		end
		puts "Returning total: #{tracks_total.count}"
		tracks_total
	end

	def track_summary track
		{
			:title => track['title'],
			:mp3 => track['stream_url'] + "?client_id=#{CLIENT_ID}",
			:id => track['id'],
			:freshness => freshness(track)
		}
	end

	def freshness track
		days = Date.today - Date.parse(track['created_at'])
		days = 1 if days < 1
		plays = track['playback_count'].to_i
		plays = 1 if plays < 1
		freshness = plays / days.to_f ** 1.2
	end

	def get_api_connector
		Soundcloud.new(:client_id => CLIENT_ID)
	end

end