import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=62804f1a";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double priceDollar;
  late double priceEuro;
  int decimalPlace = 3;

  TextEditingController realController = TextEditingController();
  TextEditingController dollarController = TextEditingController();
  TextEditingController euroController = TextEditingController();

  void realChanged(String text) {
    if(text.isEmpty){
      dollarController.text = '';
      euroController.text = '';
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real / priceDollar).toStringAsFixed(decimalPlace);
    euroController.text = (real / priceEuro).toStringAsFixed(decimalPlace);
  }

  void dollarChanged(String text) {
    if(text.isEmpty){
      realController.text = '';
      euroController.text = '';
      return;
    }

    double dollar = double.parse(text);
    double real = dollar * priceDollar;
    double euro = real / priceEuro;

    realController.text = real.toStringAsFixed(decimalPlace);
    euroController.text = euro.toStringAsFixed(decimalPlace);

    if(text.isEmpty){

    }
  }

  void euroChanged(String text) {
    if(text.isEmpty){
      realController.text = '';
      dollarController.text = '';
      return;
    }

    double euro = double.parse(text);
    double real = euro * priceEuro;
    double dollar = real / priceDollar;

    realController.text = real.toStringAsFixed(decimalPlace);
    dollarController.text = dollar.toStringAsFixed(decimalPlace);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('\$ Conversor de Moedas \$'),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                      child: Text(
                    'Carregando Dados...',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(
                        child: Text(
                      'Erro ao carregar dados!',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    priceDollar =
                        snapshot.data!['results']['currencies']['USD']['buy'];
                    priceEuro =
                        snapshot.data!['results']['currencies']['EUR']['buy'];
                    print('Dolar: $priceDollar - Euro: $priceEuro');
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(height: 20),
                          const Icon(Icons.monetization_on,
                              size: 150, color: Colors.amber),
                          const Divider(height: 50),
                          buildTextField(
                              'Real', 'R\$', realController, realChanged),
                          const Divider(height: 50),
                          buildTextField(
                              'Dólar', 'US\$', dollarController, dollarChanged),
                          const Divider(height: 50),
                          buildTextField(
                              'Euro', '€', euroController, euroChanged),
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

buildTextField(String text, String prefix, TextEditingController controller,
    Function(String) onChanged) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: text,
      labelStyle: const TextStyle(fontSize: 25, color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 15,
    ),
  );
}
