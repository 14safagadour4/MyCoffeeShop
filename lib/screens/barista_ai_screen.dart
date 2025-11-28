import 'package:flutter/material.dart';
import 'dart:math';
import '../data/barista_knowledge.dart';

class BaristaAIScreen extends StatefulWidget {
  final String clientId;
  final String tableId;
  final Function(Map<String, dynamic>) onAddToCart;

  const BaristaAIScreen({
    super.key,
    required this.clientId,
    required this.tableId,
    required this.onAddToCart,
  });

  @override
  State<BaristaAIScreen> createState() => _BaristaAIScreenState();
}

class _BaristaAIScreenState extends State<BaristaAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  List<Map<String, dynamic>> messages = [];

  // ---------------------
  // 🔥 NLP — détecter goût
  // ---------------------
  String detectTaste(String text) {
    text = text.toLowerCase();

    if (text.contains("sucré") ||
        text.contains("sucre") ||
        text.contains("sweet")) {
      return "sweet";
    }
    if (text.contains("fort") ||
        text.contains("corsé") ||
        text.contains("espresso")) {
      return "strong";
    }
    if (text.contains("crémeux") ||
        text.contains("milk") ||
        text.contains("latte")) {
      return "creamy";
    }
    if (text.contains("frais") ||
        text.contains("glacé") ||
        text.contains("cold")) {
      return "fresh";
    }
    if (text.contains("healthy") ||
        text.contains("sain") ||
        text.contains("light")) {
      return "healthy";
    }

    return "unknown";
  }

  // ---------------------
  // 🔥 Sélectionner item depuis Knowledge
  // ---------------------
  Map<String, dynamic> getSuggestion(String taste) {
    final data = BaristaKnowledge.data;

    // Si goût détecté
    if (data["tasteAnalysis"][taste] != null) {
      List list = data["tasteAnalysis"][taste];
      String chosenName = list[_random.nextInt(list.length)];

      // rechercher produit complet
      for (var cat in data["categories"].values) {
        for (var item in cat) {
          if (item["name"] == chosenName) {
            return item;
          }
        }
      }
    }

    // 🔥 fallback: choisir random
    final all = <Map<String, dynamic>>[];
    for (var cat in data["categories"].values) {
      for (var item in cat) {
        all.add(item);
      }
    }
    return all[_random.nextInt(all.length)];
  }

  // ---------------------
  // 🔥 Generate AI response
  // ---------------------
  void generateAIResponse(String userText) {
    final taste = detectTaste(userText);
    final suggestion = getSuggestion(taste);

    final aiResponses = BaristaKnowledge.data["aiResponses"]["suggestion"];
    final randomIntro = aiResponses[_random.nextInt(aiResponses.length)];

    final productName = suggestion["name"] ?? "Produit";
    final productPrice = suggestion["price"] ?? 0;

    setState(() {
      messages.add({"role": "ai", "text": "$randomIntro **$productName** ☕"});

      messages.add({
        "role": "ai_button",
        "product_name": productName,
        "product_price": productPrice,
        "text": "Ajouter $productName"
      });
    });

    autoScroll();
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
    });

    _controller.clear();
    generateAIResponse(text);
  }

  void autoScroll() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------------
  // 🔥 UI bubble builder
  // ---------------------
  Widget buildMessage(Map<String, dynamic> msg) {
    final role = msg['role'];

    if (role == "user") {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.brown[300],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(msg["text"], style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    if (role == "ai") {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.brown[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            msg["text"],
            style: TextStyle(color: Colors.brown[800]),
          ),
        ),
      );
    }

    if (role == "ai_button") {
      final name = msg["product_name"];
      final price = msg["product_price"];

      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 12, top: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              widget.onAddToCart({"name": name, "price": price});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$name ajouté au panier 🛒")),
              );
            },
            child: Text(msg["text"]),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ---------------------
  // 🔥 BUILD
  // ---------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E8D3),
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        title: Text("Barista AI • Table ${widget.tableId}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, i) => buildMessage(messages[i]),
            ),
          ),

          // ---- Input box ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Dis quelque chose…",
                      border: InputBorder.none,
                    ),
                    onSubmitted: addUserMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.brown),
                  onPressed: () => addUserMessage(_controller.text),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
