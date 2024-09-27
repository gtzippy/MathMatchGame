import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}
List<int> assignedNumbers = [];
class Area {
  int index;
  String name;
  Color color;
  int value;
  Area({this.index= -1, this.name= "Area", this.color= Colors.blue, this.value = -1});
}

class Compliment {
  late Area numberOne;
  late Area numberTwo;
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => new _State();

}

bool firstClicked = false;
var size = 14;
class _State extends State<MyApp> {

  late int _location;
  List<Area> _areas = [];
  Area? _firstArea = null;
  late int _previousIndex;
  bool _hold = false;
  final player = AudioPlayer();

  Future _showAlert(BuildContext context, String message) async {
    return showDialog(
      context: context,
      //this will force you to click the button to get rid of the notification
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
            title: new Text(message),
            actions: [
              new TextButton(onPressed: reset, child: new Text("New Game?"))
            ]);
      },
    );
  }

  void reset() async {
    Navigator.pop(context);
    List<int> assignedNumbers = [];
    List<int> assignedValues = [];
    var rng = new Random();
    var rnv = new Random();
    setState(() {
      for (int i = 0; i < size; i++) {
        _areas[i].color = Colors.blue;
        int randomNumber;
        do{
          randomNumber = rng.nextInt(8) + 1;
        } while (assignedNumbers.where((num) => num == randomNumber).length >= 2);
        assignedNumbers.add(randomNumber);
        _areas[i].name = '${randomNumber}';
        int randomValue;
        randomValue = rnv.nextInt(size);
        // do{
        if(assignedValues.length<size) {

            while (assignedValues.contains(randomValue)) {
              randomValue = rnv.nextInt(size);
            }
            assignedValues.add(randomValue);

          _areas[i].value = (randomValue==size-1 ? 5: randomValue);
        }
      }
    });

  }

  int countOccurrences(List<int> numbers, int target) {
    int count = 0;

    for (int number in numbers) {
      if (number == target) {
        count++;
      }
    }

    return count;
  }


  @override
  void initState(){
    _areas = [];
    List<int> assignedNumbers = [];
    List<int> assignedValues = [];
    var rng = new Random();
    var rnv = new Random();
    for(int i = 0; i < size; i++){
      int randomNumber;
      do{
        randomNumber = rng.nextInt(8) + 1;
      } while (assignedNumbers.where((num) => num == randomNumber).length >= 2);
      assignedNumbers.add(randomNumber);
      int randomValue;
      // d
        randomValue = rnv.nextInt(size);
        while(assignedValues.contains(randomValue)){
          randomValue = rnv.nextInt(size);
        }
        assignedValues.add(randomValue);

      // } while (assignedValues.length < 11);
      //assignedValues.add(randomValue);
      _areas.add(new Area (index: i, name: '${randomNumber}', value: (randomValue== size-1 ? ((size/2)-1).floor() : randomValue))) ;
    }


    _location = rng.nextInt(_areas.length);
  }



  Widget _generate(int index){
    return new GridTile(
        child: new Container(
            padding: new EdgeInsets.all(5.0),
            child: new ElevatedButton(
              onPressed: () => _onPressed(index),
              //color: _areas[index].color,
              child: Text(_areas[index].value.toString(), style: TextStyle(fontSize: 20.0,)), //new Text(_areas[index].name, textAlign: TextAlign.center,),
              //icon: new Expanded(child: Image.asset('imagges/blue-cup-hi.png')),
              style: ElevatedButton.styleFrom(backgroundColor: _areas[index].color,),
            )
        )
    );
  }

  Color getColor(String name){
    return Colors.white;
  }

  //check if 1 has already been clicked
  void _onPressed(int index) {
    if(_hold){
      return;
    }
    player.play(DeviceFileSource('/assets/buttonPress.mp3'));
    if(_areas[index].color!=Colors.yellow && _areas[index].color!=Colors.white) {
      if (_firstArea == null) {
        _firstArea = _areas[index];
        _previousIndex = _areas.indexOf(_firstArea!);
        //_firstArea?.color = Colors.red;
        setState(() {
          _firstArea?.color = getColor(_areas[index].name);
        });
      }
      else {
        if (_firstArea != _areas[index] &&
            // _firstArea?.name == _areas[index].name) {
            _firstArea!.value + _areas[index].value == size-2) {
          print(_areas[index].name);
          setState(() {
            _firstArea?.color = Colors.yellow;
            _areas[index].color = Colors.yellow;
          });
        }
        else {
          setState(() {
            _areas[index].color =_areas[index].color=getColor(_areas[index].name);
          });
          _hold = true;
          Future<void>.delayed(Duration(seconds: 1), () {
            setState((){

              _areas[index].color = Colors.blue;
              //int previousIndex = _areas.indexOf(_firstArea!);
              //_firstArea?.color = Colors.blue;
              _areas[_previousIndex].color = Colors.blue;
              _hold = false;
            });
          });
          //sleep(Duration(seconds: 1));
          // _areas[index].color = Colors.blue;
          // setState(() {
          //   _firstArea?.color = Colors.blue;
          // });
        }
        print(_firstArea?.color.toString());
        _firstArea = null;
      }
      bool done = true;
      int notYellow = size;
      for (int i = 0; i < size; i++) {
        if (_areas[i].color == Colors.yellow) {
          notYellow--;
        }
        if (_areas[i].color != Colors.yellow) {
          done = false;
        }
      }
      if(notYellow < 2){
        _showAlert(context, "You Win!");
      }
      // if (done) {
      //   _showAlert(context, "You Win!");
      // }
    }
  }

  //final player = AudioCache();

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Click 2 numbers that add to ${size-2}'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
            child: new GridView.count(
              crossAxisCount: 4,
              children: new List<Widget>.generate(size, _generate),
            )
        ),
      ),
    );
  }
}