import 'package:ad_hoc_ident/ad_hoc_ident.dart';

abstract class PseudonymStorage {
  static MemoryPseudonymStorage memory() {
    return MemoryPseudonymStorage._internal();
  }

  Future<String?> get(AdHocIdentity identity);

  Future<bool> set(AdHocIdentity identity, String pseudonym);
}

class MemoryPseudonymStorage implements PseudonymStorage {
  final Set<String> _values = {};
  final Map<AdHocIdentity, String> _mappings = {};

  MemoryPseudonymStorage._internal();

  @override
  Future<String?> get(AdHocIdentity identity) async {
    return _mappings[identity];
  }

  @override
  Future<bool> set(AdHocIdentity identity, String pseudonym) async {
    final added = _values.add(pseudonym);
    if (!added) {
      return false;
    }
    _mappings[identity] = pseudonym;
    return true;
  }

  Future<bool> remove(AdHocIdentity identity) async {
    final value = _mappings.remove(identity);
    if (value == null) {
      return false;
    }
    _values.remove(value);
    return true;
  }

  Future<bool> removeByValue(String pseudonym) async {
    final removed = _values.remove(pseudonym);
    if (!removed) {
      return false;
    }
    _mappings.removeWhere(
      (key, strVal) => strVal == pseudonym,
    );
    return true;
  }
}
