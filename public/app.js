/**
 * Created with JetBrains RubyMine.
 * User: nate
 * Date: 5/30/12
 * Time: 9:12 PM
 * To change this template use File | Settings | File Templates.
 */
var Task = Backbone.Model.extend({});

var TaskStore = Backbone.Collection.extend({
   model: Task,
    url: '/tasks'
});

var Tasks = new TaskStore;

_.templateSettings = {interpolate : /\{\{(.+?)\}\}/g};

var TaskView = Backbone.View.extend({
   tagName: 'li',
    template:_.template($("#task-template").html()),
    events: {
        'click .taskView': 'editTask',
        'keypress .edit'  : 'updateOnEnter',
        'blur .edit'      : 'close',
        'click .icon-ok': 'completeTask'
    },

    initialize: function(){
        this.model.bind('change', this.render, this);
        this.model.bind('destroy', this.remove, this);
    },

    render: function(){
        this.$el.html(this.template(this.model.toJSON()));
        this.input = this.$('.edit');
        if(this.model.toJSON().completed)
            this.$el.addClass('completed');

        return this;
    } ,

    editTask: function(){
        this.$el.addClass('editing');
        this.input.focus();
    },

    close: function() {
        var value = this.input.val();
        if (!value) this.clear();
        this.model.save({description: value, time_type: 0, completed: false});
        this.$el.removeClass("editing");
        this.$el.removeClass('completed');
    },

    completeTask: function() {
      this.model.save({completed: true});
        this.$el.addClass('completed');
    },

    updateOnEnter: function(e) {
        if (e.keyCode == 13) this.close();
    }
});

var AppView = Backbone.View.extend({
   el: $('#taskContainer'),

   initialize: function(){
       Tasks.bind('add', this.addOne, this);
       Tasks.bind('reset', this.addAll, this);
       Tasks.bind('all', this.render, this);

       Tasks.fetch();
   },

   render: function(){

   },

    addOne: function(task){
        var view = new TaskView({model: task});
        this.$("#task-list").append(view.render().el);

    } ,

    addAll: function(){
        Tasks.each(this.addOne);
    }
});

var App= new AppView;

($('#signout').bind('click', function(){
    $.ajax({
        url: '/signout',
        method: 'post',
        success : window.location = '/'
    });
})).(jQuery);