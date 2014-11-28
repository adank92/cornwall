$(function() {
	// Dom ready call
	setBindings();
  fetchTracks();
});

function fetchTracks() {
	// Fetches tracks from the backend
	var limit = calculateTotalTracks();
	$.get( "/tracks/jazz/0/"+limit, function( data ) {
  	$.each(data, function(key, track){
  		$('<div/>', {
			    class: 'super',
			    href: track.permalink,
			    style: 'background-image: url('+track.artwork+');'
			}).appendTo('#tracks-container');
			$('.super').wrap("<a href='#'></a>");
  	});
	}, "json" );
}

function setBindings(){
	// Sets bindings for tracks
	$( document ).on( "click", ".super", function(){
  	ToneDen.player.getInstanceByDom("#player").update({
  		urls: [
            $(this).attr('href')
        ]
  	});
  	ToneDen.player.getInstanceByDom("#player").play();
  });
}

function calculateTotalTracks(){
	// Returns amount of tracks that fits in the screen
	// Taking into account player's size and scrollbar's as well.
	var tracks_height = Math.ceil(($(document).height() - 60) / 160);
	var tracks_width = Math.floor(($('body').innerWidth() - 20) / 160);
	return (tracks_height * tracks_width) - 1;
}

// ToneDen Player Code
(function() {

    var script = document.createElement("script");

    script.type = "text/javascript";
    script.async = true;
    script.src = "//sd.toneden.io/production/toneden.loader.js"

    var entry = document.getElementsByTagName("script")[0];
    entry.parentNode.insertBefore(script, entry);
}());

ToneDenReady = window.ToneDenReady || [];
ToneDenReady.push(function() {
    ToneDen.player.create({
        dom: "#player",
        mini: true,
        feed: true,
        urls: [
            "http://soundcloud.com/diplo/avicii-you-make-me-diplo-ookay"
        ]
    });
});