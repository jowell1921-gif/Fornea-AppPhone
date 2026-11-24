import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registra las licencias OFL de las tipografías incluidas en la app.
///
/// La licencia SIL Open Font License exige distribuir su texto junto a las fuentes. Al registrarlo
/// aquí aparece en la pantalla de licencias de la app (`showLicensePage`), junto a las de los paquetes.
void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (family, path) in const [
      ('Inter', 'assets/fonts/inter/OFL.txt'),
      ('Barlow Condensed', 'assets/fonts/barlow_condensed/OFL.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        family,
      ], await rootBundle.loadString(path));
    }
  });
}
