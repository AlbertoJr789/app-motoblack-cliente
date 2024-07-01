import 'package:flutter/material.dart';

class ErrorMessage extends StatefulWidget {
  final String msg;
  final Function? tryAgainAction;
  final Icon? icon;

  ErrorMessage({required this.msg,this.tryAgainAction,this.icon});

  @override
  State<ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(widget.icon == null)
            Image.asset('assets/pics/error.png',color: const Color.fromARGB(155, 255, 255, 255),width: 240,),    
          if(widget.icon != null)
             widget.icon!,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.msg,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20,),
          if(widget.tryAgainAction != null)
            ElevatedButton(
                onPressed: !_isLoading ? () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await widget.tryAgainAction!();
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
