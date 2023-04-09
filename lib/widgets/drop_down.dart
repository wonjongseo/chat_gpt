import 'package:chat_gpt/constants/constant.dart';
import 'package:chat_gpt/models/models_model.dart';
import 'package:chat_gpt/providers/models_provider.dart';
import 'package:chat_gpt/services/api_service.dart';
import 'package:chat_gpt/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelDropDownWidget extends StatefulWidget {
  const ModelDropDownWidget({super.key});

  @override
  State<ModelDropDownWidget> createState() => _ModelDropDownWidgetState();
}

class _ModelDropDownWidgetState extends State<ModelDropDownWidget> {
  String? currentModel;

  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelsProvider>(context, listen: false);
    return FutureBuilder<List<ModelsModel>>(
      future: modelProvider.getAllModels(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: TextWidget(label: snapshot.error.toString()),
          );
        }
        return snapshot.data == null || snapshot.data!.isEmpty
            ? const SizedBox.shrink()
            : FittedBox(
                child: DropdownButton(
                  items: List<DropdownMenuItem<String>>.generate(
                    snapshot.data!.length,
                    (index) => DropdownMenuItem(
                      value: snapshot.data![index].id,
                      child: TextWidget(
                        label: snapshot.data![index].id,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  dropdownColor: scaffoldBackgroundColor,
                  iconEnabledColor: Colors.white,
                  value: modelProvider.getCurrentModel,
                  onChanged: (value) {
                    setState(() {
                      modelProvider.setCurrentModel(value.toString());
                    });
                  },
                ),
              );
      },
    );
  }
}
