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
})   ;

var tasks = new TaskStore;


var TaskView = Backbone.View.extend({
    events: {"click #create" : "handleNewTask"},
    handleNewTask: function(){
        var inputField = $('input[name=newTask]');
        tasks.create({description: inputField.val()});
    },
    render: function(){
        var data = tasks.map(function(task){return task.get('description') + '\r\n'});
        var result = data.reduce(function(memo, str){return memo + str}, '');
        $('#taskList').text(result);
        return this;
}
});

tasks.bind('add', function(task){
    tasks.fetch({success: function(){view.render();}});
})

var view = new TaskView({el: $('#taskArea')});

$('#fetch').click(function(){
    tasks.fetch({success: function(){view.render();}});
});