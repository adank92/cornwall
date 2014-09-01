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
    keyEnabled: true,
  });

  get_tracks({});

  $(myPlaylist.cssSelector.jPlayer).bind($.jPlayer.event.play, 
  function(event) {
    if(myPlaylist.current >= (myPlaylist.playlist.length - 2)){
      var ids = [];
      $.each(myPlaylist.playlist, function(index,track){
        ids.push(track.id);
      });
      get_tracks(ids);
    }
  });

  function get_tracks(ids){
    $.ajax({
      url : "/tracks",
      type: "GET",
      data : {used_ids : ids},
      success: function(data, textStatus, jqXHR) {
        data = JSON.parse(data);
        $.each(data, function(index,track){
          myPlaylist.add(track);
        });
        },
        error: function (jqXHR, textStatus, errorThrown) {}
    });
  }
});