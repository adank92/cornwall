var as;
var audio;
var tracks;

$(function() {
	// Dom ready call
  as = $('audio');
  audio = audiojs.create(as, {
          createPlayer: {
            markup: '\
              <div class="play-pause"> \
                <p class="play"></p> \
                <p class="pause"></p> \
                <p class="loading"></p> \
                <p class="error"></p> \
              </div> \
              <div class="scrubber"> \
                <div class="progress"></div> \
                <div class="loaded"></div> \
              </div> \
              <div class="time"> \
                <em class="played">00:00</em>/<strong class="duration">00:00</strong> \
              </div> \
              <div class="error-message"></div>',
            playPauseClass: 'play-pause',
            scrubberClass: 'scrubber',
            progressClass: 'progress',
            loaderClass: 'loaded',
            timeClass: 'time',
            durationClass: 'duration',
            playedClass: 'played',
            errorMessageClass: 'error-message',
            playingClass: 'playing',
            loadingClass: 'loading',
            errorClass: 'error'
          }})[0];

	setBindings();
  fetchTracks();
});

function fetchTracks() {
	// Fetches tracks from the backend
	var limit = calculateTotalTracks();
	$.get( "/tracks/jazz/0/"+limit, function( data ) {
    tracks = data;
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
	}, "json" );
}

function setBindings(){
	// Sets bindings for tracks
  $( document ).on( "click", "#tracks-container a", function (e){
    e.preventDefault();
    playTrack($(this));
  })
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
	return (tracks_height * tracks_width) - 1;
}