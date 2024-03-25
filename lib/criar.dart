import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' ;

//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' ;
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import '/Background/Widget.dart';
import 'Api/api.dart';
import 'configurar.dart';

class Inicio extends  StatefulWidget  {
  @override
  State<Inicio> createState() => _Inicio();
}
//pagina 171 pegar a listview
class _Inicio extends State<Inicio> {
  var colorwifi=Colors.black;
  var colordesconected=Colors.black;
  var colorconfig=Colors.black;
  PageController pageController = PageController();
  int currentPage = 0;
  int onClickPage = 0;
  int download=0;
 var conecta;
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  var lista = [];
  var lista1 = [];
  var prelista = [];
  var prelista1 = [];
  String principal="teste";
  String principalendereco="";
  get app => null;
  var connection1;
  var low_ble;
  late Timer _timer;
  bool conectado=false;
  String nome='';
  int contar=0;
  String rastrear='';
  String decisao="";
  FlutterBluePlus flutterBlue22 = FlutterBluePlus.instance;

  //late List<BluetoothDevice> devices;

  final yourScrollController = ScrollController();



  void initState() {
    super.initState();

    _inicio();
  }

  void onSelectPage(int pageIndex) async {
    pageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
    currentPage = pageIndex;
    if (currentPage % 2 == 0 || currentPage==3 || currentPage==4) {
      await Future.delayed(const Duration(milliseconds: 800));
    }
    onClickPage = pageIndex;
    setState(() {});
  }

  _inicio() async {
    var status = await Permission.location.request();
    if (  status.isDenied) {
      // We haven't asked for permission yet or the permission has been denied before, but not permanently.
    }


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
    var des= prefs.getString('decisao');
    if(des==null){
      setState(() {
        decisao="bluetooth";
      });
      prefs.setString('decisao',decisao);
    }
    else{
      setState(() {
        decisao=des;
      });
    }
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {

       if(decisao.contains('bluetooth')){
         //escaneando bluetooth
         try{
           if(conectado==true){
             if(connection1!=null){
               connection1.output.add(utf8.encode('f'));
               await connection1.output.allSent;
               print("enviando");
             }
           }
         }
         catch(e){
           contar++;
           if(contar>=4){
             contar=0;
             conectado=false;
           }
           print("erro no envio");
         }
       }
       if(rastrear.contains('sim')){
         await enviasinal();

       }

    });


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
    bottomNavigationBar:
        Container(
          height:90,
          color:Colors.white,
          width:MediaQuery.sizeOf(context).width,
          child:
             Row(
                children:[
                  Spacer(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      Container(
                        height:35,
                        child:
                        IconButton(
                          color:colorwifi,
                          iconSize: 30,
                          tooltip:"teste",
                          icon: const Icon(Icons.wifi),
                          onPressed: () {
                            // ...
                          },
                        ),
                      ),


                        TextButton(onPressed: () async {
                          //função do botão
                          if(
                          colorwifi==Colors.black
                          ){
                            setState(() {
                              colorwifi=Colors.blue;
                              colordesconected=Colors.black;
                              colorconfig=Colors.black;
                            });
                          }

                          // To get the list of paired devices
                          if(decisao.contains('bluetooth')){
                            try {
                              // Start scanning
                              // Start scanning
                              setState(() {
                                prelista=[];
                                prelista1=[];
                              });

                              List<BluetoothDiscoveryResult> results = <BluetoothDiscoveryResult>[];
                              var nome1='';
                              var endereco='';
                              double rssi=0;
                              int rssi1=0;
                              setState(() {
                                download=1;
                              });
                              //premodalbluetooth(context);
                              // await FlutterBluetoothSerial.instance.cancelDiscovery();



                              var streamSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
                                rssi=r.rssi.toDouble();
                                print("rssi puro:$rssi");
                                rssi=rssi + 42;
                                print("rssi:$rssi");
                                var rssi12=rssi/10;
                                // rssi=rssi/100;
                                //rssi1=rssi.round();
                                //var rssi12=pow(10,rssi);
                                //rssi12=rssi12*40;
                                //rssi12=rssi12.round();
                                endereco=r.device.address.toString();
                                nome1=r.device.name.toString()+'  '+r.device.address.toString()+ '  '+ rssi12.toString();
                                print("$nome1");

                                results.add(r);
                                //logica de rastreio
                                if(rastrear.contains('sim')){
                                  if(nome.length>2){
                                    if(nome1.contains(nome)){
                                      setState(() {
                                        principal=nome1;
                                        principalendereco=endereco;
                                      });
                                    }
                                  }
                                }
                                setState(() {
                                  prelista.add(nome1);
                                  prelista1.add(endereco);
                                });





                              });

                              streamSubscription.onDone(() {

                                setState(() {
                                  download=0;
                                  lista=prelista;
                                  lista1=prelista1;
                                });

                                // Navigator.pop(context);
                                //Modalbluetooth( context);
                                //flutterBlue.stopScan();
                                //Do something when the discovery process ends
                              });
                              //flutterBlue.stopScan();


// Stop scanning





                            } catch(e) {
                              print("Erro:$e");
                            }
                          }
                          if(decisao.contains('wifi')){
                            try {
                              setState(() {
                                download=1;
                              });
                              wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
                            } on PlatformException catch (exception) {
                              print(exception.toString());
                            }
                            var nomes;
                            setState(() {
                              prelista=[];
                              prelista1=[];
                            });
                            for (var i = 0; i < wiFiHunterResult.results.length;i++) {
                              print(wiFiHunterResult.results[i].SSID);
                              print(wiFiHunterResult.results[i].BSSID);
                              print(wiFiHunterResult.results[i].capabilities);
                              print(wiFiHunterResult.results[i].frequency);
                              print(wiFiHunterResult.results[i].level);
                              print(wiFiHunterResult.results[i].channelWidth);
                              print(wiFiHunterResult.results[i].timestamp);
                              var level1=wiFiHunterResult.results[i].level.abs();
                              var level=level1.toString();
                              nomes=wiFiHunterResult.results[i].SSID.toString() +
                                  //  ' '+wiFiHunterResult.results[i].capabilities.toString() +
                                  ' '+wiFiHunterResult.results[i].frequency.toString()+
                                  '  '+level;



                              if(rastrear.contains('sim')){
                                if(nome.length>2){
                                  if(nomes.contains(nome)){
                                    setState(() {
                                      principal=nomes;

                                    });
                                  }
                                }
                              }
                              prelista.add(nomes);
                            }
                            setState(() {
                              lista=prelista;
                              download=0;
                            });



                          }






                        }

                            , child: Text(decisao, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colorwifi))



                      ),
                    ]
                  ),
                  Spacer(),
                  Column(
                      children:[
                        Container(
                          height:35,
                          child:
                          IconButton(
                            color:colordesconected,
                            iconSize: 30,
                            tooltip:"teste",
                            icon: const Icon(Icons.disabled_visible),
                            onPressed: () {
                              // ...
                            },
                          ),
                        ),
                        Container(
                          //password


                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child:
                          TextButton(onPressed: () {
                            if(
                            colordesconected==Colors.black
                            ){
                              setState(() {
                                colorwifi=Colors.black;
                                colordesconected=Colors.blue;
                                colorconfig=Colors.black;
                              });
                            }
                            //função do botão
                            if(decisao.contains('bluetooth')){
                              if(connection1!=null){
                                connection1.finish();
                                setState(() {
                                  conectado=false;
                                });
                                Alerta().alerta1(context,'Aparelho','desconectado');
                              }
                              else{
                                Alerta().alerta1(context,'Sem','conexão');
                              }
                            }




                          }

                              , child: Text('Descon', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: colordesconected))


                          ),
                        ),

                      ]
                  ),
                  Spacer(),
                  Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        Container(
                          height:35,
                          child:
                          IconButton(
                            color:colorconfig,
                            iconSize: 30,
                            tooltip:"teste",
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              // ...
                            },
                          ),
                        ),

                        Container(
                          //password


                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child:
                          TextButton(onPressed: () async{
                            if(
                            colorconfig==Colors.black
                            ){
                              setState(() {
                                colorwifi=Colors.black;
                                colordesconected=Colors.black;
                                colorconfig=Colors.blue;
                              });
                            }
                            if(decisao.contains('bluetooth')){
                              if(connection1!=null){
                                connection1.finish();

                              }
                            }

                            //função do botão
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>Configurar()));



                          }

                              , child: Text('Config', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorconfig))


                          ),
                        ),


                        // Container(
                        //password


                        /// decoration: BoxDecoration(
                        //    color: Colors.black,
                        //   borderRadius: BorderRadius.circular(4)
                        //  ),
                        //  child:
                        // TextButton(onPressed: () async {
                        //função do botão

                        // To get the list of paired devices
                        ////try {
                        // Start scanning
                        // Start scanning
                        //   setState(() {
                        //   prelista=[];
                        //    prelista1=[];
                        //   });
                        // Start scanning
                        //  flutterBlue22.startScan(timeout: Duration(seconds: 4));
                        //  print("ate aqui foi");
                        //    var conecta="";
                        // Uuid bytes = Uuid.parse('80-30-DC-DC-81-C0');








// Listen to scan results
                        //  var subscription = flutterBlue22.scanResults.listen((results) async {
                        // do something with scan results
                        //  for (ScanResult r in results) {
                        //  print('${r.device.name} found! rssi: ${r.rssi}');
                        //   conecta=r.device.name;
                        //   if(conecta.contains("Adriel Lucas")){
                        //    await r.device.connect();

                        //  setState(() {
                        //   low_ble=r.device;


                        //   });List<BluetoothService> services = await r.device.discoverServices();
                        //   services.forEach((service) async {
                        // do something with service
                        //  var characteristics = service.characteristics;
                        //  for(BluetoothCharacteristic c in characteristics) {
                        //   List<int> value = await c.read();
                        //  print(value);
                        //   await c.write([0x12, 0x34]);
                        //  }

// Writes to a characteristic


                        //   });
                        //low_ble=r.device;
                        //print("bluetooth conectado");
                        //  }
                        //    }
                        //     });


// Stop scanning
                        //flutterBlue22.stopScan();




                        //     } catch(e) {
                        //     print("Erro:$e");
                        //   }





                        //  }

                        //  , child: Text('Blee 4.0', style: TextStyle(
                        //    fontWeight: FontWeight.bold,
                        //    fontSize: 15,
                        //     color: Colors.white.withOpacity(0.8)))


                        //  ),
                        // ),



                        ]
                  ),
                  Spacer(),
                ]
              )


        ),


  //  floatingActionButton: test4(),



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
                      SizedBox(height:65),
                      //definindo a margem superior do apk

                      Text('Rastreando '+ decisao, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.8))),
                      SizedBox(height:10),
                      Container(
                        //password

                        //width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                        ),

                            ),


                      SizedBox(
                        height:5,
                      ),
                      download==1?
                          Container(
                            width:50,
                            height:50,
                              child:
                              CircularProgressIndicator(color:Colors.green)

                          ):Container(),
                      SizedBox(height:10),
                      InkWell(
                        onTap:() async {
                          if(decisao.contains('bluetooth')){
                            if(principalendereco.length>=4){

                              try{
                                var address=principalendereco;
                                BluetoothConnection connection = await BluetoothConnection.toAddress(address);
                                setState(() {
                                  connection1=connection;
                                  conectado=true;
                                });
                                //Navigator.pop(context);

                                Alerta().alerta1(context,'funcionou','conectado');

                                print('Connected to the device');
                              }
                              catch(e){
                                print('erro');
                                Alerta().alerta1(context,'Erro',e.toString());

                              }

                            }
                          }

                        },
                        child:

                              Container(
                                 // height:40,
                                  width:MediaQuery.of(context).size.width*8/10,
                                  color:Colors.black12.withOpacity(0.05),
                                  child: Text(principal, style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black.withOpacity(0.8)))
                              ),



                      ),
                      SizedBox(
                        height:25,
                      ),
                      Center(
                        child:
                        IconButton(
                          tooltip:"liga",
                          color: Colors.black,
                          iconSize: 60,
                          onPressed:() async {
                            if(decisao.contains('bluetooth')){
                              if(connection1!=null){
                                setState(() {
                                  conectado=true;
                                });
                                connection1.output.add(utf8.encode('f'));
                                await connection1.output.allSent;
                              }
                              else{
                                try{
                                  // List<BluetoothService> services = await low_ble.discoverServices();
                                  // services.forEach((service) async {
                                  // do something with service
                                  // var characteristics = service.characteristics;
                                  //for(BluetoothCharacteristic c in characteristics) {
                                  //  List<int> value = await c.read();
                                  // print(value);
                                  // await c.write([0x12, 0x34]);
                                  //  }

// Writes to a characteristic

                                  // });

                                }
                                catch(e){

                                }
                              }
                            }
                            if(decisao.contains('wifi')){
                              await enviasinal();
                            }




                          }, icon: const Icon(Icons.play_arrow),)
                      ),

                      SizedBox(height:20),
                      Center(
                          child:
                          IconButton(
                            tooltip:"desliga",
                            color: Colors.black,
                            iconSize: 60,
                            onPressed:() async {
                              if(decisao.contains('bluetooth')){

                                if(connection1!=null){
                                  setState(() {
                                    conectado=false;
                                  });
                                  connection1.output.add(utf8.encode('d'));
                                  await connection1.output.allSent;
                                }
                              }
                              if(decisao.contains('wifi')){
                                await enviasinaldesliga();
                              }


                            }, icon: const Icon(Icons.stop),)
                      ),
                      SizedBox(height:20),
                  Scrollbar(
                      thumbVisibility: true,
                      controller: yourScrollController,
                      child:
                      Column(
                          children:[
                            Container(
                              width:MediaQuery.of(context).size.width*8/10,
                              height:MediaQuery.of(context).size.height*40/100,
                              color:Colors.black12.withOpacity(0.05),
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
                                        if(decisao.contains('bluetooth')){
                                          try{
                                            var address=lista1[i];
                                            BluetoothConnection connection = await BluetoothConnection.toAddress(address);
                                            setState(() {
                                              connection1=connection;
                                              conectado=true;
                                            });
                                            // Navigator.pop(context);
                                            Alerta().alerta1(context,'funcionou','conectado');

                                            print('Connected to the device');
                                          }
                                          catch(e){
                                            print('erro');
                                            Alerta().alerta1(context,'Erro',e.toString());

                                          }
                                        }




                                      },


                                          child: Text(' '+lista[i].toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black
                                                      .withOpacity(1)))

                                      ),);


                                },),


                            ),

                          ]
                      )
                  )
                  //












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
                     conectado=true;
                   });
                   //Navigator.pop(context);
                   //Alerta().alerta1(context,'funcionou','conectado');

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
    Center(
      child:
      Container(
          width:100,
          height:100,
          child:CircularProgressIndicator(color:Colors.green)


      ),
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











