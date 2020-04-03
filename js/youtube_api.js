// 2. This code loads the IFrame Player API code asynchronously.
var tag = document.createElement('script');

tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

// 3. This function creates an <iframe> (and YouTube player)
//    after the API code downloads.
var player;
function onYouTubeIframeAPIReady() {
  player = new YT.Player('player', {
    playerVars: {
      'controls': 0,
      'enablejsapi': 1,
      'rel': 0, // 同じチャネルから関連動画を出す
      'cc_load_policy': 1,
      'cc_lang_pref': 'jp-JP'
    },
    // videoId: video_id,
    videoId: 'iH_YJde1yps',
    width: '100%',
    height: '100%',
    events: {
      'onReady': onPlayerReady,
      'onStateChange': onPlayerStateChange
      
    }
    
  });
  
}

// 4. The API will call this function when the video player is ready.
function onPlayerReady(event) {
  event.target.playVideo();
}

// 5. The API calls this function when the player's state changes.
//    The function indicates that when playing a video (state=1),
//    the player should play for six seconds and then stop.
var done = false;
function onPlayerStateChange(event) {
  Shiny.setInputValue("videoStatus", event.data);
}
function stopVideo() {
  player.stopVideo();
}