RoboRacer.Models.Player = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/players",

  initialize: function() {
    this.set('hand', new RoboRacer.Collections.Hand());

    var program = this.get('program') || new RoboRacer.Collections.Program();
    program.meta('player', this);
    this.set('program', program);
  }

});
