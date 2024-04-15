import 'dart:typed_data';

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:nfc_manager/nfc_manager.dart';

class TestID extends StatefulWidget {
  TestID({super.key});

  @override
  State<TestID> createState() => _TestIDState();
}

class _TestIDState extends State<TestID> {
  bool isDarkMode = false;
  Color pageBackgroundColor = Color.fromRGBO(198, 218, 231, 1);
  Color appBarBackgroundColor = Color.fromRGBO(77, 95, 128, 100);

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      pageBackgroundColor = isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1);
      appBarBackgroundColor = isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100);
    });
  }

  @override
  void initState() {
    super.initState();
    getDarkModeValue();
  }

ValueNotifier<dynamic> result = ValueNotifier(null);

@override 
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: FutureBuilder<bool>(
        future: NfcManager.instance.isAvailable(),
        builder: (context, ss) => ss.data != true
        ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
        : Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
          children: [
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.all(4),
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(border: Border.all()),
                child: SingleChildScrollView(
                  child: ValueListenableBuilder<dynamic>(
                    valueListenable: result,
                    builder: (context, value, _) =>
                    Text('${value ?? ''}'),
                    ),
                  ),
                ),
              ),
            Flexible(
              flex: 3,
              child: GridView.count(
                padding: EdgeInsets.all(4),
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                children: [
                  ElevatedButton(
                    child: Text('Tag Read'), onPressed: _tagRead),
                  ElevatedButton(onPressed: _ndefWrite, child: Text('Ndef Write')),
                  ElevatedButton(onPressed: _ndefWriteLock, child: Text('Ndef Write Lock')),
                  ],
              ),),
          ],
        ),
      ),
    ),
  );
}

void _tagRead() {
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    // grab this data and store it as a json in firebase
    result.value = tag.data;
    NfcManager.instance.stopSession();
  });
}

void _ndefWrite() {
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    // grab the user's data from firebase and format it as NDEF
    // might use NFCA since my card has that, _tagRead grabs an NFCA value from my card
    var ndef = Ndef.from(tag);
    if (ndef == null || !ndef.isWritable) {
      result.value = 'Tag is not ndef writeable';
      NfcManager.instance.stopSession(errorMessage: result.value);
      return;
    }
    NdefMessage message = NdefMessage([
      NdefRecord.createText('Hello World'),
      NdefRecord.createUri(Uri.parse('https://flutter.dev')),
      NdefRecord.createMime('text/plain', Uint8List.fromList('mydata'.codeUnits)),
      NdefRecord.createExternal('com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
    
    ]);
    
    try {
      await ndef.write(message);
      result.value = 'Success to "Ndef Write"';
      NfcManager.instance.stopSession();
    } catch (e) {
      result.value = e;
      NfcManager.instance.stopSession(errorMessage: result.value.toString());
      return;
    }
  });
}

void _ndefWriteLock() {

  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}