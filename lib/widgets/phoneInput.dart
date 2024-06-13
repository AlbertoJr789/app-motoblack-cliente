import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final MaskTextInputFormatter maskFormatter = MaskTextInputFormatter();

  PhoneInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    String phone = '';
    String cc = '+55';
    if (controller.text.isNotEmpty) {
      //removing special chars
      String tel = controller.text;
      cc = tel.substring(0, tel.indexOf(' '));
      phone = tel.substring(tel.indexOf(' ') + 1);
      if (cc == "+55") {
        cc = "BR";
        maskFormatter.updateMask(
            mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
      }
    }

    return IntlPhoneField(
      initialCountryCode: cc,
      initialValue: phone,
      // controller: controller,
      countries: const [
        Country(
          name: "Brasil",
          nameTranslations: {
            "pt_BR": "Brasil",
          },
          flag: "🇧🇷",
          code: "BR",
          dialCode: "55",
          minLength: 11,
          maxLength: 11,
        ),
      ],
      onChanged: (newValue) {
        controller.text = '${newValue.countryCode} ${newValue.number}';
      },
      inputFormatters: [maskFormatter],
      onCountryChanged: (country) {
        if (country.code != 'BR') {
          maskFormatter.updateMask(mask: null, filter: null);
        } else {
          maskFormatter.updateMask(
              mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
        }
        controller.text =
            '+${country.dialCode} ${controller.text.substring(controller.text.indexOf(' ') + 1)}';
      },
      pickerDialogStyle: PickerDialogStyle(
        searchFieldInputDecoration: const InputDecoration(
          labelText: 'Pesquisar País',
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      validator: (p0) {
        if (maskFormatter.getMask() != null) {
          if (!maskFormatter.isFill()) {
            return 'Número inválido';
          }
        } else {
          if (!p0!.isValidNumber()) return 'Numero inválido';
        }
        return null;
      },
      disableLengthCheck: true,
    );
  }
}
