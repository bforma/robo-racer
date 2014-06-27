var Class = function() {
  this.initialize && this.initialize.apply(this, arguments);
};
Class.extend = Backbone.Model.extend;
_.extend(Class.prototype, Backbone.Events);
