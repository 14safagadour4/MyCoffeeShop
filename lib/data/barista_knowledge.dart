class BaristaKnowledge {
  static final Map<String, dynamic> data = {
    "categories": {
      "Coffees": [
        {
          "name": "Espresso",
          "profile": "fort, intense, amer",
          "recommendedFor": ["réveil", "amateurs de café fort", "après repas"],
          "temperature": "chaud",
          "sweetLevel": "non sucré",
          "flavors": ["amer", "corsé"]
        },
        {
          "name": "Cappuccino",
          "profile": "équilibré, crémeux",
          "recommendedFor": ["petit déjeuner", "goût doux"],
          "temperature": "chaud",
          "sweetLevel": "moyen",
          "flavors": ["lait", "mousse", "léger café"]
        },
        {
          "name": "Latte",
          "profile": "doux, très lacté",
          "recommendedFor": ["débutants", "sucré", "goût léger"],
          "temperature": "chaud",
          "flavors": ["lait", "vanille selon variantes"]
        },
        {
          "name": "Flat White",
          "profile": "café doux mais intense",
          "recommendedFor": ["fans de cappuccino", "texture fine"],
          "temperature": "chaud",
        },
        {
          "name": "Mocha",
          "profile": "chocolaté, sucré",
          "recommendedFor": ["choco lovers", "boisson dessert"],
          "temperature": "chaud",
          "flavors": ["chocolat", "café"]
        },
      ],

      "Drinks": [
        {
          "name": "Iced Coffee",
          "profile": "frais, café froid",
          "recommendedFor": ["été", "rafraîchissement"],
          "temperature": "froid",
        },
        {
          "name": "Hot Chocolate",
          "profile": "chocolaté, sucré",
          "recommendedFor": ["enfant", "douceur"],
          "temperature": "chaud"
        },
        {
          "name": "Matcha Latte",
          "profile": "herbal, smooth",
          "recommendedFor": ["healthy", "anti-oxydants"],
          "temperature": "chaud ou froid"
        },
        {
          "name": "Smoothie Fraise",
          "profile": "fruité, sucré",
          "recommendedFor": ["sport", "vitamines"],
          "temperature": "froid"
        },
      ],

      "Desserts": [
        {
          "name": "Croissant",
          "profile": "beurré, léger",
          "recommendedFor": ["matin", "goûter"],
        },
        {
          "name": "Cheesecake",
          "profile": "crémeux, sucré",
          "recommendedFor": ["dessert", "cravings sugar"],
        },
        {
          "name": "Brownie",
          "profile": "sucré, chocolat",
          "recommendedFor": ["amateurs chocolat"],
        },
      ],

      "Goods Eat": [
        {
          "name": "Sandwich Jambon",
          "profile": "rapide, salé",
          "recommendedFor": ["déjeuner", "snack"],
        },
        {
          "name": "Wrap Poulet",
          "profile": "léger, protéiné",
          "recommendedFor": ["sport", "repas rapide"],
        },
        {
          "name": "Salade César",
          "profile": "léger, healthy",
          "recommendedFor": ["fitness"],
        },
      ]
    },

    // 🔥 Analyse du goût du client
    "tasteAnalysis": {
      "sweet": ["Latte", "Mocha", "Milkshake Vanille", "Cheesecake"],
      "strong": ["Espresso", "Americano", "Turkish Coffee"],
      "creamy": ["Cappuccino", "Latte", "Flat White"],
      "fresh": ["Iced Coffee", "Iced Latte", "Lemonade", "Smoothie"],
      "healthy": ["Matcha Latte", "Fresh Orange Juice", "Salade César"],
    },

    // 👇 Règles d’intelligence
    "rules": {
      "ifUserSays": {
        "j'ai chaud": "proposer boissons froides",
        "j'ai froid": "proposer boissons chaudes",
        "je veux quelque chose de sucré": "proposer desserts / lattes sucrés",
        "je veux quelque chose de fort": "proposer espresso / turkish coffee",
        "je veux manger": "proposer sandwich / salade / wrap",
        "je veux juste boire": "proposer café ou boisson froide",
        "je suis stressé": "proposer latte / tisane / matcha",
      }
    },

    // ⭐ Réponses naturelles prêtes
    "aiResponses": {
      "suggestion": [
        "Je te recommande fortement : ",
        "Je pense que tu vas adorer : ",
        "Selon ton goût, voici le meilleur choix : ",
        "Après analyse, je te propose : "
      ],
      "askTaste": [
        "Tu préfères sucré, fort, crémeux ou frais ?",
        "Quel type de boisson tu aimes ?",
        "Tu veux une recommandation personnalisée ?"
      ],
    },
  };
}
