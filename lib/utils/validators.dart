class Validators {
  static String? requiredField(String? value, {String label = 'Dit veld'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is verplicht.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail is verplicht.';
    if (!value.contains('@')) return 'Geef een geldig e-mailadres in.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Wachtwoord moet minstens 6 tekens hebben.';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return 'Geef een geldig bedrag in.';
    if (parsed < 0) return 'Prijs kan niet negatief zijn.';
    return null;
  }
}
