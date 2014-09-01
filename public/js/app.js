$(document).ready(function(){
  var myPlaylist = new jPlayerPlaylist({
    jPlayer: "#jquery_jplayer_1",
    cssSelectorAncestor: "#jp_container_1"
  }, 
  [], 
  {
    swfPath: "/js/vendor/jPlayer/",
    supplied: "mp3",
    wmode: "window",
    smoothPlayBar: true,
    keyEnabled: true
  });
  call_gettracksurl_service({});
  $(myPlaylist.cssSelector.jPlayer).bind($.jPlayer.event.play, 
  function(event) {
    if(myPlaylist.current >= (myPlaylist.playlist.length - 2)){
      var ids = [];
      $.each(myPlaylist.playlist, function(index,track){
        ids.push(track.id);
      });
      call_gettracksurl_service(ids);
    }
  });
  function call_gettracksurl_service(ids){
    $.ajax({
      url : "/getTracksUrl",
      type: "POST",
      data : {used_ids : ids},
      success: function(data, textStatus, jqXHR) {
        data = JSON.parse(data);
        $.each(data, function(index,track){
          myPlaylist.add(track);
        });
        myPlaylist.play();
        },
        error: function (jqXHR, textStatus, errorThrown) {}
    });
  }
});