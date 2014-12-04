var as;
var audio;
var genres;
var current_genre;
var tracks = [];

$(function() {
	// Dom ready call
  setAudio();
	setBindings();
  fetchGenres();
});

function fetchGenres(){
  $.get( "/genres", function( data ) {
    genres = data;
    $.each(data, function(key, genre){
      $('.dropdown-menu').append('<li><a href="#">'+genre+'</a></li>');
    });
    default_genre = $('.dropdown-menu li a').first().text();
    toggleDropdownText(default_genre);
    fetchTracks(default_genre, 0);
  }, "json" );
}

function setBindings(){
	// Sets bindings for tracks
  $( document ).on( "click", "#tracks-container a", function (e){
    e.preventDefault();
    playTrack($(this));
  })
  $( document ).on( "click", ".dropdown-menu li a", function(e){
    e.preventDefault();
    toggleDropdownText($(this).text());
    clearTracks();
    fetchTracks($(this).text(), 0);
  });
  $( document ).on( "click", ".load-more button", function(e){
    offset = Object.keys(tracks).length;
    fetchTracks(current_genre, offset);
  });
}

function fetchTracks(genre, offset) {
  // Fetches tracks from the backend
  var limit = calculateTotalTracks() + offset;
  $.get( "/tracks/"+genre+"/"+offset+"/"+limit, function( data ) {
    tracks = $.extend({},tracks,data);
    $.each(data, function(key, track){
      var background_div = $('<div/>', {
          class: 'super',
          style: 'background-image: url('+track.artwork+');'
      });
      $('<a/>', {
          class: 'super',
          href: '#',
          'track-id': key,
          html: background_div
      }).appendTo('#tracks-container');
    });

    addLoadMore();
  }, "json" );
}

function playTrack(track_case){
  $("#tracks-container a").removeClass('playing_track');
  var track = tracks[track_case.attr('track-id')];
  $('.track-info .title').html(track.title);
  $('.track-info .artist').html(track.artist);
  $('.soundcloud-link').attr('href', track.permalink);
  audio.load(track.mp3);
  audio.play();
  track_case.addClass('playing_track');
}

function playFirstTrack(){
  var track_case = $("#tracks-container a").first();
  playTrack(track_case);
}

function calculateTotalTracks(){
	// Returns amount of tracks that fits in the screen
	// Taking into account player's size and scrollbar's as well.
	var tracks_height = Math.ceil(($(document).height() - 60) / 160);
	var tracks_width = Math.floor(($('body').innerWidth() - 20) / 160);

  // If load-more button exists then fetch more tracks
  var substract = 2 - $(".load-more").length;
	return (tracks_height * tracks_width) - substract;
}

function clearTracks(){
  tracks = [];
  $('#tracks-container').html('');
}

function toggleDropdownText(text){
  current_genre = text;
  $(".dropdown-toggle:first-child").html(text+' <span class="caret"></span>');
}

function setAudio(){
  as = $('audio');
  audio = audiojs.create(as)[0];
}

function addLoadMore(){
  $('.load-more').remove()
  $('<div/>', {
    class: 'load-more',
    html: "<button type='button' class='btn btn-default btn-lg'><span class='glyphicon glyphicon-refresh' aria-hidden='true'></span> Load More</button>"
  }).appendTo('#tracks-container');
}