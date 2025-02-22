import 'dart:async';

import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressAutoComplete extends StatefulWidget {

  Address? position;
  final TextEditingController textController;
  final FocusNode focusNode;
  final GlobalKey<FormFieldState>? formFieldKey;
  final Function(Address) onSelected;
  final String hintText;
  final String labelText;
  final Function(String?) onValidate;

  AddressAutoComplete({
    super.key,
    this.position,
    required this.textController,
    required this.focusNode,
    this.formFieldKey,
    required this.onSelected,
    required this.onValidate,
    required this.hintText,
    required this.labelText,
  });

  @override
  State<AddressAutoComplete> createState() => _AddressAutoCompleteState();
}


class _AddressAutoCompleteState extends State<AddressAutoComplete> {

  bool _showAutocomplete = false;
  bool _searching = false;

  Timer? _debounce;

  final DestinySelectionController _destinySelectionController = DestinySelectionController();


  Future<Iterable<Address>> _getAutocompleteSuggestions(value) {
    final completer = Completer<Iterable<Address>>();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      completer
          .complete(await _destinySelectionController.getSuggestions(value));
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {

    return  LayoutBuilder(builder: (context, constraints) {
      return RawAutocomplete<Address>(
        textEditingController: widget.textController,
        focusNode: widget.focusNode,
        optionsBuilder: (controller) async {
          if (controller.text.isEmpty ||
              !_showAutocomplete) {
            return [];
          }

          _showAutocomplete = false;
          setState(() {
            _searching = true;
          });

          final suggestions =
              await _getAutocompleteSuggestions(
                  controller.text);
          
          setState(() {
            _searching = false;
          });

          return suggestions;
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<Address> onSelected,
            Iterable<Address> options) {
          final scrollController = ScrollController();
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
                elevation: 4.0,
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                          0.2,
                  width: constraints.biggest.width,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: scrollController,
                    child: ListView(
                      controller: scrollController,
                      children:
                          options.map((Address option) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 4.0),
                          child: ListTile(
                            title: Text(
                                option.formattedAddress),
                            onTap: () {
                              onSelected(option);
                              widget.onSelected(option);
                              _destinySelectionController.storeSuggestion(option);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )),
          );
        },
        fieldViewBuilder: (BuildContext ctx,
            TextEditingController ed,
            FocusNode fn,
            VoidCallback ofs) {
          return TextFormField(
            controller: ed,
            focusNode: fn,
            key: widget.formFieldKey,
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )

                  : InkWell(
                      onTap: fn.hasFocus
                          ? () {
                              widget.position = null;
                              widget.textController.text = '';
                            }
                          : null,
                          
                      child: fn.hasFocus
                          ?  Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.secondary,)
                          : Icon(Icons.search, color: Theme.of(context).colorScheme.secondary,),
                    ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black87,
                ),
              ),
            ),
            onChanged: (_) {
              _showAutocomplete = true;
            },
            validator: (value) {
              widget.onValidate(value);
            },
          );
        },
      );
    });
  }
}