RoboRacer.Models.Register = Backbone.Model.extend({
  isEmpty: function() {
    return this.get('instruction_card') === undefined;
  }
});
