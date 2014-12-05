var as;
var audio;
var genres;
var current_genre;
var tracks = [];
var total_tracks = 0;

$(function() {
	// Dom ready call
  setAudio();
	setBindings();
  fetchGenres();
});

function fetchGenres(){
  // Fetches genres from sinatra and appends them to the dropdown-menu
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
  // Bindings for ajax calls
  $( document )
  .bind("ajaxSend", showSpinner)
  .bind("ajaxComplete", onAjaxComplete)
  .bind("ajaxStop", hideSpinner)
  .bind("ajaxError", hideSpinner);

	// Binding for tracks
  $( document ).on( "click", "#tracks-container a", function (e){
    e.preventDefault();
    playTrack($(this));
  })

  // Binding for the dropdown-menu
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
  // Fetches tracks from the backend and appends them to the app
  var limit = calculateTotalTracks() + offset;
  $.get( "/tracks/"+genre+"/"+offset+"/"+limit, function( data ) {
    tracks = $.extend({},tracks,data);
    $.each(data, function(key, track){
      var background_img = $('<img/>', {
          class: 'super',
          src: track.artwork
      });
      var link = $('<a/>', {
          href: '#',
          'track-id': key,
          html: background_img
      });
      $('<li/>', {
        class: 'is-loading',
        html: link
      }).appendTo('#tracks-container');
    });

    addLoadMore();
  }, "json" );
}

function playTrack(track_case){
  // Plays the track based on the jquery object
  $("#tracks-container img").removeClass('playing_track');
  var track = tracks[track_case.attr('track-id')];
  $('.track-info .title').html(track.title);
  $('.track-info .artist').html(track.artist);
  $('.soundcloud-link').attr('href', track.permalink);
  audio.load(track.mp3);
  audio.play();
  track_case.children().addClass('playing_track');
}

function playFirstTrack(){
  // Play first track on the list
  var track_case = $("#tracks-container a").first();
  playTrack(track_case);
}

function calculateTotalTracks(){
	// Returns amount of tracks that fits in the screen
	if(!total_tracks){
    // index offset -1
    var substract = 1;
    // Taking into account player's size and scrollbar's as well.
    var tracks_height = Math.ceil(($(document).height() - 60) / 160);
    var tracks_width = Math.floor(($('body').innerWidth() - 20) / 160);

    total_tracks = (tracks_height * tracks_width) - substract;

    // First load implies one track less due to the load-more button
    alert(total_tracks);
    return total_tracks -1;
  }

  alert(total_tracks);
  return total_tracks;
}

function clearTracks(){
  // Clear tracks from the app
  tracks = [];
  $('#tracks-container').html('');
}

function toggleDropdownText(text){
  // Change dropdown text based on selection
  current_genre = text;
  $(".dropdown-toggle:first-child").html(text+' <span class="caret"></span>');
}

function setAudio(){
  // Creates AudioJS object
  as = $('audio');
  audio = audiojs.create(as)[0];
}

function addLoadMore(){
  // Removes and ads a load-more button
  $('.load-more').remove()
  $('<div/>', {
    class: 'load-more',
    html: "<button type='button' class='btn btn-default btn-lg'> \
            <span class='glyphicon glyphicon-refresh' aria-hidden='true'></span> Load More \
           </button>"
  }).appendTo('#tracks-container');
}

function onProgress( imgLoad, image ) {
  // triggered after each item is loaded
  // change class if the image is loaded or broken
  var $item = $( image.img ).closest('li');
  $item.removeClass('is-loading');
  if ( !image.isLoaded ) {
    $item.addClass('is-broken');
  }
}

function onAjaxComplete(){
  hideSpinner();
  $('#tracks-container').imagesLoaded().progress( onProgress );
}

function showSpinner(){
  $( ".spinner-overlay" ).fadeIn( "slow", function() {});
}

function hideSpinner(){
  $( ".spinner-overlay" ).fadeOut( "slow", function() {});
}