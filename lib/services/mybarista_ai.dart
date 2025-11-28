// lib/services/mybarista_ai.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyBaristaAI {
  // 🔑 Clé API Groq depuis .env
  static final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  // 🧠 Modèle Groq CORRIGÉ (utilisez un modèle valide)
  static final String _model =
      'llama-3.1-8b-instant'; // Modèle valide et gratuit

  // 🌐 ENDPOINT OFFICIEL GROQ
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  // === PROMPT SYSTEME ===
  static const String _systemPrompt = '''
Tu es *MyBarista Assistant*, l'assistant intelligent du Coffee Shop.

🎯 Ton rôle :
- Conseiller les clients selon leurs goûts.
- Recommander des boissons, desserts ou snacks.
- Proposer des combos (café + dessert, froid + snack, etc.).
- Répondre UNIQUEMENT sur les produits du menu MyBarista.
- Être chaleureux, utile et précis.
- Toujours terminer avec une recommandation personnalisée.

📋 Menu Complet :

☕ CAFÉS CLASSIQUES
Espresso - 5.0 TND
Cappuccino - 5.5 TND
Latte - 6.5 TND
Flat White - 6.0 TND
Americano - 5.0 TND
Macchiato - 5.8 TND
Mocha - 7.0 TND
Caramel Latte - 6.5 TND
Vanilla Latte - 6.5 TND
Café Turc - 5.2 TND
Affogato - 6.8 TND
Irish Coffee - 8.5 TND

🥤 BOISSONS FRAÎCHES
Iced Coffee - 7.0 TND
Mocha Frappe - 7.8 TND
Chocolat Chaud - 5.0 TND
Iced Latte - 6.5 TND
Caramel Frappe - 6.5 TND
Matcha Latte - 7.8 TND
Jus d'Orange Frais - 6.8 TND
Limonade Maison - 6.0 TND
Milkshake Vanille - 7.5 TND
Smoothie Fraise - 7.8 TND
Iced Tea Pêche - 6.5 TND

🍰 DOUCEURS
Croissant - 2.5 TND
Muffin - 3.5 TND
Cheesecake - 9.5 TND
Brownie - 4.0 TND
Tiramisu - 8.0 TND
Pancakes - 8.5 TND
Crème Brûlée - 5.5 TND
Cookie Chocolat - 4.2 TND
Gaufre Nutella - 8.5 TND
Donut Fraise - 4.5 TND
Cake au Citron - 5.8 TND

🥪 PLATS & SNACKS SALÉS
Sandwich Jambon - 6.0 TND
Bagel Saumon - 12.5 TND
Wrap Poulet - 6.5 TND
Salade César - 6.2 TND
Burrito - 6.8 TND
Croque Monsieur - 6.2 TND
Quiche Lorraine - 6.5 TND
Tarte aux Légumes - 5.8 TND
Hot Dog - 5.2 TND
''';

  /// === ENVOI DU MESSAGE ===
  static Future<String> sendMessage(String userMessage) async {
    if (_apiKey.isEmpty) {
      return "❌ Clé GROQ introuvable. Vérifie ton fichier .env.";
    }

    try {
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      };

      final body = {
        "model": _model,
        "messages": [
          {"role": "system", "content": _systemPrompt},
          {"role": "user", "content": userMessage}
        ],
        "temperature": 0.7,
        "max_tokens": 300,
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print("❌ GROQ ERROR: ${response.statusCode} - ${response.body}");
        return "❌ Erreur API: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);
      final content =
          data["choices"]?[0]?["message"]?["content"]?.toString() ?? "";

      return content.isEmpty ? "❌ Réponse vide." : content;
    } catch (e) {
      print("❌ Exception: $e");
      return "❌ Impossible de contacter l'assistant: $e";
    }
  }
}
