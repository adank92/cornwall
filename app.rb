require 'sinatra'
require 'json'
require 'redis'
require 'yaml'

get '/' do
  erb :index
end

get '/tracks/:genre/:offset/:limit' do
  # Returns track based on the genre from memcached
  genre = params[:genre].downcase
  offset = params[:offset].to_i
  limit = params[:limit].to_i
  tracks = tracks_fetch(genre, offset, limit)
  JSON.generate(tracks)
end

get '/genres' do
  # Returns available genres
  genres = YAML.load_file('config/genres.yaml')
  genres.map!(&:capitalize)
  JSON.generate(genres)
end

def tracks_fetch(genre, offset, limit)
  # Redis communication
  rd = Redis.new
  return [] unless tracks = rd.get(genre)
  tracks = JSON.parse(tracks, symbolize_names: true)
  tracks = tracks[offset..limit]
  Hash[tracks.map { |track| [track[:id], track] }]
end
