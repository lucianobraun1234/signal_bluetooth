import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';



import '/Background/Widget.dart';
import 'configurar.dart';

class Inicio extends  StatefulWidget  {
  @override
  State<Inicio> createState() => _Inicio();
}
//pagina 171 pegar a listview
class _Inicio extends State<Inicio> {


  var lista = [];
  var lista1 = [];

  get app => null;
  var connection1;
  String nome='';
  String rastrear='';

  late List<BluetoothDevice> devices;

  final yourScrollController = ScrollController();

  get flutterBlue => null;


  void initState() {
    super.initState();

    _asyncMethod();
  }

  _asyncMethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //prefs.setString('credenciais',resultado2);
    var cima1 = prefs.getString('nome');
    var baixo1 = prefs.getString('rastrear');
    var esquerda1 = prefs.getString('esquerda');
    var direita1 = prefs.getString('direita');
    if (cima1 != null) {
      nome = cima1;
    }
    else {
      nome = '';
    }
    if (baixo1 != null) {
      rastrear= baixo1;
    }
    else {
      rastrear = '';
    }

  }



  _start(){
    return Container();
  }



  @override
  Widget build(BuildContext context) {


    return Stack(children: [
      //BackgroundImage1(),
     // BackgroundImage(),

      Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,

        //backgroundColor: Colors.white,
        body:
        Container(

            child:
            SingleChildScrollView(

              child:
              Center(

                child:
                Column(
                    children: [
                      SizedBox(height:100),
                      //definindo a margem superior do apk

                      Container(
                        //password

                        //width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child:
                            Row(
                              children:[
                                SizedBox(width:40),
                                Container(
                                  //password


                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child:
                                  TextButton(onPressed: () async{
                                    if(connection1!=null){
                                      connection1.finish();

                                    }
                                    //função do botão
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>Configurar()));



                                  }

                                      , child: Text('Config', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8)))


                                  ),
                                ),
                                SizedBox(width:50),
                                Container(
                                  //password


                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child:
                                  TextButton(onPressed: () async {
                                    //função do botão

                                    // To get the list of paired devices
                                    try {
                                      // Start scanning
                                      // Start scanning
                                      setState(() {
                                        lista=[];
                                        lista1=[];
                                      });
                                      List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
                                      var nome1='';
                                      var endereco='';
                                      double rssi=0;
                                      int rssi1=0;
                                      premodalbluetooth(context);

                                      void startDiscovery() {
                                        var streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
                                          rssi=r.rssi.toDouble();
                                          rssi=rssi + 35;
                                          rssi=rssi/10;
                                          rssi1=rssi.round();
                                         endereco=r.device.address.toString();
                                          nome1=r.device.name.toString()+'  '+r.device.address.toString()+ '  '+ rssi1.toString();

                                          results.add(r);
                                          //logica de rastreio
                                          if(rastrear.contains('sim')){
                                            if(nome.length>2){
                                              if(nome1.contains(nome)){
                                                lista.add(nome1);
                                                lista1.add(endereco);
                                              }
                                            }
                                          }
                                          else{
                                            lista.add(nome1);
                                            lista1.add(endereco);
                                          }


                                        });

                                        streamSubscription.onDone(() {
                                          flutterBlue.stopScan();
                                          Navigator.pop(context);
                                          Modalbluetooth( context);
                                          //Do something when the discovery process ends
                                        });
                                      }
// Stop scanning





                                    } catch(e) {
                                      print("Erro:$e");
                                    }





                                  }

                                      , child: Text('Bluetooth', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white.withOpacity(0.8)))


                                  ),
                                ),
                                SizedBox(width:50),
                                Container(
                                  //password


                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child:
                                  TextButton(onPressed: () {
                                    //função do botão
                                    if(connection1!=null){
                                      connection1.finish();
                                      Alerta().alerta1(context,'Aparelho','desconectado');
                                    }
                                    else{
                                      Alerta().alerta1(context,'Sem','conexão');
                                    }



                                  }

                                      , child: Text('Descon', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white.withOpacity(0.8)))


                                  ),
                                ),

                              ]
                            ),),


                      SizedBox(
                        height:50,
                      ),
                      Center(
                        child:
                        IconButton(
                          tooltip:"liga",
                          color: Colors.black,
                          iconSize: 100,
                          onPressed:() async {
                            if(connection1!=null){
                              connection1.output.add(utf8.encode('l'));
                              await connection1.output.allSent;
                            }



                          }, icon: const Icon(Icons.on_device_training),)
                      ),

                      SizedBox(height:20),
                      Center(
                          child:
                          IconButton(
                            tooltip:"desliga",
                            color: Colors.black,
                            iconSize: 100,
                            onPressed:() async {
                              if(connection1!=null){
                                connection1.output.add(utf8.encode('d'));
                                await connection1.output.allSent;
                              }


                            }, icon: const Icon(Icons.offline_pin_rounded),)
                      ),












                    ]
                ),),)
        ),)

      ,
      WillPopScope(
          onWillPop: () async {

            print('Press again Back Button exit');

            // showAlertDialog(context);

            // print('sign out');
            //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>Timer2()));

            return true;

          },
          child: Container(
            alignment: Alignment.center,
            child: Text(''),
          ))
    ]);
  }
  Modalbluetooth(BuildContext context)
  async {
    // Start scanning

    // configura o button
    Widget okButton =
    Scrollbar(
        thumbVisibility: true,
        controller: yourScrollController,
        child:
      Column(
          children:[
            Container(
                width:MediaQuery.of(context).size.width*8/10,
                height:MediaQuery.of(context).size.height/3,
              child:ListView.builder(
        // scrollDirection: Axis.horizontal,
                controller: yourScrollController,
                 scrollDirection: Axis.vertical,
            itemCount: lista.length,
           itemBuilder: (context, i) {
             return
             Container(
               child:
               TextButton(onPressed: () async {
                 //função do botão

                 try{
                   var address=lista1[i];
                   BluetoothConnection connection = await BluetoothConnection.toAddress(address);
                   setState(() {
                     connection1=connection;
                   });
                   Navigator.pop(context);
                   Alerta().alerta1(context,'funcionou','conectado');

                   print('Connected to the device');
                 }
                 catch(e){
                   print('erro');
                   Alerta().alerta1(context,'Erro',e.toString());

                 }


               },


                   child: Text('conectar ao  '+lista[i].toString(),
                       style: TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 16,
                           color: Colors.black
                               .withOpacity(1)))

             ),);


           },),


            ),
            Row(
                children:[
                  TextButton(
                    child: Text("Fechar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]
            )

          ]
      )
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text(" "),
      content: Text(" "),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  premodalbluetooth(BuildContext context)
  async {
    // Start scanning

    // configura o button
    Widget okButton =
    Scrollbar(
        thumbVisibility: true,
        controller: yourScrollController,
        child:
        Column(
            children:[
              Container(
                width:MediaQuery.of(context).size.width/3,
                height:MediaQuery.of(context).size.height/3,
                child:CircularProgressIndicator(color:Colors.green)


              ),


            ]
        )
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text(" "),
      content: Text(" "),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }


}

class Alerta{

  void alerta1(BuildContext context,String titulo,String mensagem)
  {
    // configura o button

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [

      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

}











