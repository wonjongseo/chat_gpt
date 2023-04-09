import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:flutter/material.dart';

class ModelsProvider extends ChangeNotifier {
  List<ModelsModel> modelsList = [];
  String currentModel = 'gpt-3.5-turbo';

  List<ModelsModel> get getModelsList => modelsList;
  String get getCurrentModel => currentModel;

  void setCurrentModel(String newModel) {
    currentModel = newModel;
    notifyListeners();
  }

  Future<List<ModelsModel>> getAllModels() async {
    modelsList = await ApiService.getModels();

    return modelsList;
  }
}
