RoboRacer.Models.Player = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/players",

  initialize: function() {
    var hand = this.get('hand') || new RoboRacer.Collections.Hand();
    hand.meta('player', this);
    this.set('hand', hand);

    var program = this.get('program') || new RoboRacer.Collections.Program();
    program.meta('player', this);
    this.set('program', program);
  }

});
