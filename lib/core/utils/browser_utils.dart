import 'dart:js_interop';

@JS('window.alert')
external void _jsAlert(JSString message);

@JS('window.prompt')
external JSString? _jsPrompt(JSString message);

@JS('window.confirm')
external bool _jsConfirm(JSString message);

void appAlert(String message) => _jsAlert(message.toJS);
String? appPrompt(String message) => _jsPrompt(message.toJS)?.toDart;
bool appConfirm(String message) => _jsConfirm(message.toJS);

