var ModelMixin = {
  componentDidMount: function() {
    this.__syncedModels = [];
    this.getBackboneModels().forEach(this.__subscribe, this);
  },

  componentDidUpdate: function() {
    var models = this.getBackboneModels();
    var added = _.difference(models, this.__syncedModels);
    var removed = _.difference(this.__syncedModels, models);
    removed.forEach(this.__unsubscribe, this);
    this.__syncedModels = _(this.__syncedModels).difference(removed);
    added.forEach(this.__subscribe, this);
  },

  componentWillUnmount: function() {
    // Ensure that we clean up any dangling references when the component is
    // destroyed.
    this.__syncedModels.forEach(this.__unsubscribe, this);
    this.__syncedModels = [];
  },

  __subscribe: function(model) {
    if (!~this.__syncedModels.indexOf(model)) {
      var updater = _.debounce(this.forceUpdate.bind(this, null), 10);
      model.on('add change remove reset sort', updater, this);
      this.__syncedModels.push(model);
    }
  },

  __unsubscribe: function(model) {
    model.off(null, null, this);
  }
};
