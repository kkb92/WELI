// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

void installNavigationGuard() {
  html.window.onBeforeUnload.listen((event) {
    event.preventDefault();

    // In neueren Dart-Versionen ist returnValue nicht mehr statisch auf Event definiert.
    // Dynamisch gesetzt kompiliert es trotzdem für Browser, die es für die Warnung benötigen.
    try {
      (event as dynamic).returnValue = '';
    } catch (_) {
      // Manche Browser ignorieren eigene Before-Unload-Texte.
    }
  });
}