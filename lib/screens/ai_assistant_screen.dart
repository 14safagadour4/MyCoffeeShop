import 'package:flutter/material.dart';

class AiAssistantScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;
  final String? clientId;
  final Map<String, List<String>> clientHistory;

  const AiAssistantScreen({super.key, 
    required this.onSelect,
    this.clientId,
    required this.clientHistory,
  });

  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  String? flavor;
  String? type;
  bool recommendReady = false;
  List<Map<String, dynamic>> recommendations = [];

  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Espresso', 'price': 2.5},
    {'name': 'Cappuccino', 'price': 3.0},
    {'name': 'Iced Latte', 'price': 3.5},
    {'name': 'Croissant', 'price': 1.5},
    {'name': 'Thé Vert', 'price': 2.0},
    {'name': 'Thé Noir', 'price': 2.0},
  ];

  void generateRecommendations() {
    recommendations.clear();
    for (var item in menuItems) {
      final name = item['name'].toString();
      if (widget.clientId != null &&
          widget.clientHistory.containsKey(widget.clientId) &&
          widget.clientHistory[widget.clientId]!.contains(name)) {
        recommendations.add(item);
      } else if ((type == 'Café' &&
              (name.contains('Espresso') || name.contains('Cappuccino'))) ||
          (type == 'Boisson froide' && name.contains('Iced')) ||
          (type == 'Thé' && name.contains('Thé'))) {
        if ((flavor == 'Fort' && name.contains('Espresso')) ||
            (flavor == 'Doux' && name.contains('Cappuccino'))) {
          recommendations.add(item);
        }
      }
    }
    setState(() => recommendReady = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: recommendReady
            ? Column(
                children: [
                  Text(
                    'Suggestions pour vous :',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final item = recommendations[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['name'].toString()),
                            trailing: Text('\$${item['price']}'),
                            onTap: () {
                              widget.onSelect(item);
                              if (widget.clientId != null) {
                                if (!widget.clientHistory.containsKey(
                                  widget.clientId,
                                )) {
                                  widget.clientHistory[widget.clientId!] = [];
                                }
                                widget.clientHistory[widget.clientId!]!.add(
                                  item['name'].toString(),
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item['name']} ajouté au panier',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quel type de boisson aimez-vous ?'),
                  DropdownButton<String>(
                    value: type,
                    hint: Text('Sélectionnez le type'),
                    items: ['Café', 'Thé', 'Boisson froide']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => type = val),
                  ),
                  SizedBox(height: 20),
                  Text('Préférence de goût ?'),
                  DropdownButton<String>(
                    value: flavor,
                    hint: Text('Sélectionnez le goût'),
                    items: ['Doux', 'Fort', 'Amer']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => flavor = val),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: (type != null && flavor != null)
                          ? generateRecommendations
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text('Voir les suggestions'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
