import 'package:flutter/material.dart';

class PaymentDetails extends StatelessWidget {
  const PaymentDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Card(
            color: Color.fromARGB(255, 216, 216, 216),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Créditos',
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Text(
                      'R\$0,00',
                      style: TextStyle(fontSize: 36),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Adicionar Créditos'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Card(
              color: Color.fromARGB(255, 216, 216, 216),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Métodos de Pagamento',
                        style: TextStyle(fontSize: 36),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Adicionar'),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
