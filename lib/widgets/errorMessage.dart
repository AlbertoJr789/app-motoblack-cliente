import 'package:flutter/material.dart';

class ErrorMessage extends StatefulWidget {
  final String msg;
  final Function tryAgainAction;

  ErrorMessage({required this.msg, required this.tryAgainAction});

  @override
  State<ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    print('_isLoading');
    print(_isLoading);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/pics/error.png',color: const Color.fromARGB(155, 255, 255, 255),width: 240,),    
          Text(
            widget.msg,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
              onPressed: !_isLoading ? () {
                setState(() {
                  _isLoading = true;
                });
                print('try again');
                widget.tryAgainAction();
                print('cabou try again');
                setState(() {
                  _isLoading = false;
                });
              } : null,
              child: !_isLoading ? const Text(
                'Tentar Novamente',
                style: TextStyle(fontSize: 18),
              ) : const Padding(
                padding: EdgeInsets.all(8.0),
                child:  CircularProgressIndicator(color: Colors.black,),
              ),
            ),
        ],
      ),
    );
  }
}
