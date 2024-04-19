import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    debugShowCheckedModeBanner: false, // Remove debug banner
  ));
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Adding a delay before navigating to MyApp
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.green, // Change background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Assuming 'a.jpg' is in the 'assets' folder
            SizedBox(height: 20),
            Text(
              'Welcome to PokemonGO TGC',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Change text color
            ),
            SizedBox(height: 10),
            Text(
              'by Loveleen Kaur',
              style: TextStyle(fontSize: 18, color: Colors.white), // Change text color
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pokemon Cards'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Menu'),
              ),
              ListTile(
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle navigation to home page if needed
                },
              ),
              ListTile(
                title: Text('Search'),
                onTap: () {
                  // Handle search action
                },
              ),
            ],
          ),
        ),
        body: PokemonList(),
      ),
    );
  }
}

class PokemonList extends StatefulWidget {
  @override
  _PokemonListState createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<dynamic> pokemonData = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    final Uri url =
    Uri.parse('https://api.pokemontcg.io/v2/cards?q=name:gardevoir');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void showPaymentSuccessfulDialog(
      String itemName, String itemImage, double marketPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item Name: $itemName"),
              SizedBox(height: 8),
              Image.network(itemImage),
              SizedBox(height: 8),
              Text("Market Price: \$${marketPrice.toStringAsFixed(2)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void navigateToPaymentScreen(String itemName, String itemImage, double marketPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(itemName, itemImage, marketPrice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pokemonData.length,
      itemBuilder: (BuildContext context, int index) {
        final pokemon = pokemonData[index];
        final marketPrice =
        pokemon['tcgplayer']['prices']['holofoil']['market'];
        return ListTile(
          leading: Image.network(pokemon['images']['small']),
          title: Text(pokemon['name']),
          subtitle:
          Text('Market Price: \$${marketPrice.toStringAsFixed(2)}'),
          trailing: ElevatedButton(
            onPressed: () {
              navigateToPaymentScreen(pokemon['name'], pokemon['images']['small'], marketPrice);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Change button color to blue
            ),
            child: Text("Buy Now"),
          ),
        );
      },
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final String itemName;
  final String itemImage;
  final double marketPrice;

  PaymentScreen(this.itemName, this.itemImage, this.marketPrice);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    // Implement payment logic here
    // For simplicity, just navigate back with payment success
    Navigator.pop(context);
    _showPaymentSuccessfulDialog();
  }

  void _showPaymentSuccessfulDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Item Name: ${widget.itemName}"),
              SizedBox(height: 8),
              Image.network(widget.itemImage),
              SizedBox(height: 8),
              Text("Market Price: \$${widget.marketPrice.toStringAsFixed(2)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Enter Payment Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.network(widget.itemImage),
            SizedBox(height: 20),
            Text("Item Name: ${widget.itemName}"),
            SizedBox(height: 20),
            Text("Market Price: \$${widget.marketPrice.toStringAsFixed(2)}"),
            SizedBox(height: 20),
            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: 'MM/YY',
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Change button color to pink
              ),
              child: Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
