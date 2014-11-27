$(function() {
  $.get( "/tracks/jazz/1", function( data ) {
  	$( ".result" ).html( data );
	  alert( "Load was performed." );
	});
});