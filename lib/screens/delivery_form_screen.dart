import 'package:flutter/material.dart';

class DeliveryFormScreen extends StatefulWidget {
  const DeliveryFormScreen({super.key});

  @override
  State<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends State<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informations de livraison")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nom complet"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "Téléphone"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: "Adresse complète"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      "name": nameCtrl.text,
                      "phone": phoneCtrl.text,
                      "address": addressCtrl.text,
                    });
                  }
                },
                child: const Text("Valider"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
