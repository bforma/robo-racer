RoboRacer.Socket = Class.extend({
  initialize: function(gameEventListener, accessToken, gameId) {
    var url =
      window.location.protocol +
      "//" +
      window.location.hostname +
      ":8080";

    var connection = io(url);
    connection.on("connect", function() {
      connection.emit("authenticate", accessToken);
    });

    connection.on("disconnect", function() {
      console.log("disconnected", arguments);
    }.bind(this));

    connection.on("authenticated", function() {
      connection.emit("join", gameId);
    });

    connection.on("event", function(event) {
      gameEventListener.handleEvent(JSON.parse(event));
    });
  }
});
