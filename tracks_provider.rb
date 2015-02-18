require 'soundcloud'
require 'json'
require 'open-uri'
require 'dalli'
require 'yaml'

class TracksProvider
	CLIENT_ID = 'a2340d5b7b5f7e58128486190268ce71'
	PAGE_SIZE = 200
	PAGE_COUNT = 2
	LICENSE = 'cc-by-sa'

	def initialize
		@dc = Dalli::Client.new
		@genres = YAML.load_file('config/genres.yaml')
		@default_genre_imgs = {}
	end

	def update
		client = get_api_connector
		tracks = []

		fetch_default_genre_images

		@genres.each do |genre|
			genre_tracks = fetch_tracks_api(genre,client) #+ fetch_tracks_web(genre)
			genre_tracks.map do |track|
				track['genre'] = genre
				track
			end
			tracks.concat genre_tracks
		end

		tracks.uniq! { |t| t['uri'].split('/').last }
		tracks.map! { |track| track_summary(track) }
		tracks.sort_by! { |t| -t[:freshness] }

		@genres.each do |genre|
			genre_tracks = tracks.select { |track| track[:genre] == genre }
			genre.downcase!
			@dc.set(genre, genre_tracks)
		end

		tracks
	end

	def fetch_tracks_api genre, client=nil
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
			:artist => track['user']['username'],
			:title => track['title'],
			:mp3 => track['stream_url'] + "?client_id=#{CLIENT_ID}",
			:id => track['id'],
			:genre => track['genre'],
			:permalink => track['permalink_url'],
			:artwork => img_track(track),
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

	def img_track track
		soundcloud_img = track['artwork_url'].to_s
		if soundcloud_img.empty?
			@default_genre_imgs[track['genre']] || ''
		else
			soundcloud_img
		end
	end

	def fetch_default_genre_images
		images_paths = Dir["public/img/*.jpg"]
		images_paths.each do |img|
			# strip top level dir
			img.slice! 'public/'
			genre_name = File.basename(img, '.jpg')
			@default_genre_imgs[genre_name] = img
		end
		@default_genre_imgs
	end

	def get_api_connector
		Soundcloud.new(:client_id => CLIENT_ID)
	end

end