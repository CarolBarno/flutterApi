import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:apitest/models/task.dart';


class DetailTaskScreen extends StatefulWidget {
  final int id;
  DetailTaskScreen({this.id}) : super();
  @override
  _DetailTaskScreenState createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail task'),
      ),
      body: FutureBuilder(
        future: fetchTaskById(http.Client(), widget.id),
        builder: (context, snapshot){
          if(snapshot.hasError) print(snapshot.error);
          if(snapshot.hasData){
            return DetailTask(task: snapshot.data);
          } else{
            return Center(child: CircularProgressIndicator());
          }
        }
      ), 
    );
  }
}

class DetailTask extends StatefulWidget {
  final Task task;
  DetailTask({Key key, this.task}) : super(key: key);
  @override
  _DetailTaskState createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
  Task task = new Task();
  bool isLoadedTask = false;

  @override
  Widget build(BuildContext context) {
    if(isLoadedTask == false){
      setState(() {
        this.task = Task.fromTask(widget.task);
        this.isLoadedTask = true;
      });
    }
    final TextField _txtTaskName = new TextField(
      decoration: InputDecoration(
        hintText: 'Enter task name',
        contentPadding: EdgeInsets.all(10.0),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black))
      ),
      autocorrect: false,
      controller: TextEditingController(text: this.task.name),
      textAlign: TextAlign.left,
      onChanged: (text){
        setState(() {
          this.task.name = text;
        });
      },
    );
    final Text _txtFinished = Text('Finished:', style: TextStyle(fontSize: 16.0));
    final Checkbox _cbFinished = Checkbox(
      value: this.task.finished,
      onChanged: (bool value){
        setState(() {
          this.task.finished = value;
        });
      }
      );
      final _btnSave = RaisedButton(
        child: Text('save'),
        color: Theme.of(context).accentColor,
        elevation: 4.0,
        onPressed: () async{
          //update existing task
          Map<String, dynamic> params = Map<String, dynamic>();
          params['id'] = this.task.id.toString();
          params['name'] = this.task.name;
          params['isfinished'] = this.task.finished ? '1' : '0';
          params['todoid'] = this.task.todoId.toString();
          await updateTask(http.Client(), params);
          Navigator.pop(context);
        }
      );
      final _btnDelete = RaisedButton(
        child: Text('delete'),
        color: Colors.redAccent,
        onPressed: () async {
          //delete a task
          await deleteTask(http.Client(), this.task.id);
          Navigator.pop(context); //navigate back 
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text('Confimation'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Are you sure you want to delete this?')
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('yes'),
                    onPressed: () async {
                      await deleteTask(http.Client(), this.task.id);
                      await Navigator.pop(context); //quit dialog
                      Navigator.pop(context); //quit to previous screen
                    },
                  ),
                  new FlatButton(
                    child: new Text('no'),
                    onPressed: () async {
                      Navigator.pop(context); //quit to previous screen
                    },
                  ),
                ],
              );
            }
          );
        },
      );
      final _column = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _txtTaskName,
          Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _txtFinished,
                _cbFinished
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(child: _btnSave),
              Expanded(child: _btnDelete)
            ],
          )
        ],
      );
       return Container(
         margin: EdgeInsets.all(10.0),
         child: _column,
       );
  }
}