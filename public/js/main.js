var as;
var audio;

$(function() {
	// Dom ready call
  as = audiojs.createAll();
  audio = as[0];

	setBindings();
  fetchTracks();
});

function fetchTracks() {
	// Fetches tracks from the backend
	var limit = calculateTotalTracks();
	$.get( "/tracks/jazz/0/"+limit, function( data ) {
  	$.each(data, function(key, track){
      var background_div = $('<div/>', {
          class: 'super',
          style: 'background-image: url('+track.artwork+');'
      });
  		$('<a/>', {
			    class: 'super',
			    href: '#',
			    'data-src': track.mp3,
          html: background_div
			}).appendTo('#tracks-container');
  	});
    playFirstTrack();
	}, "json" );
}

function setBindings(){
	// Sets bindings for tracks
  $( document ).on( "click", "#tracks-container a", function (e){
    e.preventDefault();
    playTrack($(this));
  })
}

function playTrack(track){
  $("#tracks-container a").removeClass('playing_track');
  var track_url = track.attr('data-src');
  audio.load(track_url)
  audio.play();
  track.addClass('playing_track');
}

function playFirstTrack(){
  var first_track = $("#tracks-container a").first();
  playTrack(first_track);
}

function calculateTotalTracks(){
	// Returns amount of tracks that fits in the screen
	// Taking into account player's size and scrollbar's as well.
	var tracks_height = Math.ceil(($(document).height() - 60) / 160);
	var tracks_width = Math.floor(($('body').innerWidth() - 20) / 160);
	return (tracks_height * tracks_width) - 1;
}