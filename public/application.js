/**
 * Created with JetBrains RubyMine.
 * User: nate
 * Date: 5/29/12
 * Time: 8:36 AM
 * To change this template use File | Settings | File Templates.
 */
var Task = Backbone.Model.extend({});

var TaskStore = Backbone.Collection.extend({
    model: Task,
    url: 'http://localhost:4567/tasks'
});

var tasks = new TaskStore;


var TaskView = Backbone.View.extend({
    template:_.template($("#task_template").html()),
    events: {"click #create" : "handleNewTask",
    "click li": "editTask"},
    initialize: function(){
        tasks.fetch({success: function(){view.render();}});
    },

    handleNewTask: function(){
        var inputField = $('input[name=newTask]');
        tasks.create({description: inputField.val()});
    },

    editTask: function(){
      this.$el.addclass('editing');
    },

    render: function(){
        $(this.el).html(this.template({
            t: this.collection.toJSON()
        }));

        return this;
    }
});

var view = new TaskView({collection: tasks, el: $('#taskContainer')});

tasks.bind('add', function(){
    tasks.fetch({success: function(){view.render();}});
});

setInterval(function(){tasks.fetch({success: function(){view.render();}});}, 1000);