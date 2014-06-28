RoboRacer.Socket = Class.extend({
  initialize: function(accessToken, gameId) {
    var url =
      window.location.protocol +
      "//" +
      window.location.hostname +
      ":8080";

    var connection = io(url);
    connection.on("connect", function() {
      connection.emit("authenticate", accessToken);
    }.bind(this));

    connection.on("disconnect", function() {
      console.log("disconnected");
    }.bind(this));

    connection.on("authenticated", function() {
      connection.emit("join", gameId);
    });
  }
});
