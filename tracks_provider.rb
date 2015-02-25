require 'soundcloud'
require 'json'
require 'open-uri'
require 'redis'
require 'yaml'

class TracksProvider
  def initialize
    @rc = Redis.new
    @config = YAML.load_file('config/config.yaml')
  end

  def update
    tracks = sanitize_tracks(fetch_tracks)
    persist_tracks tracks
    tracks
  end

  def sanitize_tracks(tracks)
    default_images = fetch_default_genre_images
    tracks.uniq! { |t| t['uri'].split('/').last }
    tracks.map! do |t|
      genre = t['genre'].downcase
      track_summary(t, default_images[genre])
    end
    tracks.sort_by { |t| -t[:freshness] }
  end

  def persist_tracks(tracks)
    @config['genres'].each do |genre|
      genre_tracks = tracks.select { |track| track[:genre] == genre }
      genre.downcase!
      @rc.set(genre, genre_tracks.to_json)
    end
  end

  def fetch_tracks(client = api_connector)
    @config['genres'].inject([]) do |acc, genre|
      genre_tracks = fetch_tracks_api(genre, client)
      acc.concat genre_tracks
    end
  end

  def fetch_tracks_api(genre, client = api_connector)
    stream_urls = []
    params = params_api(genre)

    @config['page_count'].times do |page|
      puts "Fetching from API. Genre #{genre}, Page #{page}"
      params[:offset] = @config['page_size'] * page
      tracks = client.get('/tracks', params)
      tracks.each { |track| stream_urls << track if track.streamable }
    end

    puts "Returning total: #{stream_urls.count}"
    stream_urls
  end

  def fetch_tracks_web(genre)
    tracks_total = []
    @config['page_count'].times do |page|
      puts "Fetching from WEB. Genre #{genre}, Page #{page}"
      offset = @config['page_size'] * page
      url = "https://api-v2.soundcloud.com/explore/
      #{genre}?tag=uniform-time-decay-experiment%3A1%3A1389973574
      &limit=#{@config['page_size']}
      &offset=#{offset}
      &linked_partitioning=1"
      begin
        tracks = JSON.parse(open(url).read)
      rescue StandardError
      end
      tracks_total.concat(tracks['tracks'])
    end

    puts "Returning total: #{tracks_total.count}"
    tracks_total
  end

  def freshness(track)
    days = Date.today - Date.parse(track['created_at'])
    days = 1 if days < 1
    plays = track['playback_count'].to_i
    plays = 1 if plays < 1
    plays / days.to_f**1.2
  end

  def fetch_default_genre_images
    default_genre_imgs = {}
    images_paths = Dir['public/img/*.jpg']
    images_paths.each do |img|
      # strip top level dir
      img.slice! 'public/'
      genre_name = File.basename(img, '.jpg')
      default_genre_imgs[genre_name] = img
    end
    default_genre_imgs
  end

  def track_summary(track, default_image)
    {
      artist: track['user']['username'],
      title: track['title'],
      mp3: "#{track['stream_url']}?client_id=#{@config['client_id']}",
      id: track['id'],
      genre: track['genre'].downcase,
      permalink: track['permalink_url'],
      artwork: img_track(track, default_image),
      freshness: freshness(track)
    }
  end

  def params_api(genre)
    {
      genres: genre,
      limit: @config['page_size'],
      licence: @config['license'],
      :"duration[from]" => 150_000,
      :"duration[to]" => 480_000
    }
  end

  def img_track(track, default_image)
    track_image = track['artwork_url'].to_s
    track_image = default_image if track_image.empty?
    track_image || ''
  end

  def api_connector
    Soundcloud.new(client_id: @config['client_id'])
  end
end
