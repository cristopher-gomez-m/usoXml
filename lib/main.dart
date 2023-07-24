import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Recipe {
  final String name;
  final String url;
  final String difficulty;
  final String time;
  final String calories;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.name,
    required this.url,
    required this.difficulty,
    required this.time,
    required this.calories,
    required this.ingredients,
    required this.steps,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text('XML Parsing Example'),
        ),
        body: FutureBuilder<List<XmlDocument>>(
          future: Future.wait([
            loadXmlAsset('comida.xml'),
            loadXmlAsset('Planta.xml'),
            loadXmlAsset('receta.xml'),
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<XmlDocument> xmlList = snapshot.data!;
              return displayXmlData(xmlList);
            } else if (snapshot.hasError) {
              return Text('Error loading XML');
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<XmlDocument> loadXmlAsset([String? fileName]) async {
    final xmlString = await rootBundle.loadString('assets/$fileName');
    return XmlDocument.parse(xmlString);
  }

  Widget displayXmlData(List<XmlDocument> xml) {
    final foodNodes = xml[0].findAllElements('food');
    final plantsNodes = xml[1].findAllElements('PLANT');
    final recipeNodes = xml[2].findAllElements('receta');
    final List<Recipe> recipes = [];
    final List<Widget> foodWidgets = [];
    
    for (final foodNode in foodNodes) {
      final name = foodNode.findElements('name').single.text;
      final price = foodNode.findElements('price').single.text;
      final description = foodNode.findElements('description').single.text;
      final calories = foodNode.findElements('calories').single.text;
      // Get the image URL from the XML
      final imageUrl = foodNode.findElements('image').single.text;
      foodWidgets.add(
        ListTile(
          title: Text(name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(imageUrl),
              Text('Price: $price'),
              Text('Description: $description'),
              Text('Calories: $calories'),
            ],
          ),
        ),
      );
    }

for (final plantsNode in plantsNodes){
  final nameCommon = plantsNode.findElements('COMMON').single.text;
  final nameBotanical = plantsNode.findElements('BOTANICAL').single.text;
  final zone = plantsNode.findElements('ZONE').single.text;
  final light = plantsNode.findElements('LIGHT').single.text;
  final price = plantsNode.findElements('PRICE').single.text;
  final availability = plantsNode.findElements('AVAILABILITY').single.text;
   final imageUrl = plantsNode.findElements('image').single.text;
        foodWidgets.add(
        ListTile(
          title: Text(nameCommon),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(imageUrl),
              Text('Name Botanical: $nameBotanical'),
              Text('zone: $zone'),
              Text('light: $light'),
              Text('price: $price'),
              Text('availability: $availability'),
            ],
          ),
        ),
      );
}

    for (final recipeNode in recipeNodes) {
      final name = recipeNode.findElements('nombre').single.text;
      final url = recipeNode.findElements('image').single.text;
      final difficulty = recipeNode.findElements('dificultad').single.text;
      final time = recipeNode.findElements('tiempo').single.text;
      final calories = recipeNode.findElements('calorias').single.text;

      // Extracting ingredients data
      final ingredientsNodes = recipeNode.findElements('ingredientes').single;
      final ingredientsList = ingredientsNodes
          .findElements('ingrediente')
          .map((ingredientNode) =>
              '${ingredientNode.getAttribute('cantidad')} de ${ingredientNode.getAttribute('nombre')}')
          .toList();
      // Extracting steps data
      final stepsNodes = recipeNode.findElements('pasos').single;
      final stepsList = stepsNodes
          .findElements('paso')
          .map((stepNode) =>
              'Paso ${stepNode.getAttribute('orden')}: ${stepNode.text}')
          .toList();

      final recipe = Recipe(
        name: name,
        url: url,
        difficulty: difficulty,
        time: time,
        calories: calories,
        ingredients: ingredientsList,
        steps: stepsList,
      );
      recipes.add(recipe);
    }

  recipes.map((recipe) =>
    foodWidgets.add( 
      ListTile(
        title: Text(recipe.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.url),
            Text('Dificultad: ${recipe.difficulty}'),
            Text('Tiempo: ${recipe.time}'),
            Text('Calorias: ${recipe.calories}'),
            Text('Ingredientes:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.ingredients.map((ingredient) => Text(ingredient)).toList(),
            ),
            Text('Pasos:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.steps.map((step) => Text(step)).toList(),
            ),
          ],
        ),
      )
  )).toList();

    return ListView(
      children: foodWidgets,
    );
  }
}
