RoboRacer.Models.Player = Backbone.Model.extend({
  idAttribute: "_id",
  urlRoot: "/api/players",

  initialize: function() {
    this.set('hand', new RoboRacer.Collections.Hand());
    this.set('program', new RoboRacer.Collections.Program());
  }

});
