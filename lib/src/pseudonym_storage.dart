import 'package:ad_hoc_ident/ad_hoc_ident.dart';

/// Stores created pseudonym-[AdHocIdentity] mappings
/// and ensures pseudonym uniqueness.
abstract class PseudonymStorage {
  /// Creates an in memory [PseudonymStorage].
  static MemoryPseudonymStorage memory() {
    return MemoryPseudonymStorage._internal();
  }

  /// Returns the stored pseudonym of the [identity] or null if none is found.
  Future<String?> get(AdHocIdentity identity);

  /// Tries to store a [pseudonym] for the [identity] and returns whether or not
  /// the pseudonym was set.
  ///
  /// If the [identity] already has a stored pseudonym, the existing one is not
  /// changed and false is returned. Otherwise returns true.
  Future<bool> set(AdHocIdentity identity, String pseudonym);
}

/// An in memory implementation of [PseudonymStorage].
///
/// Be aware that an in memory store is discarded when the app closes.
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

  /// Removes the pseudonym of the [identity] from the store.
  ///
  /// Returns false, if there was no pseudonym and true if a pseudonym was
  /// removed.
  Future<bool> remove(AdHocIdentity identity) async {
    final value = _mappings.remove(identity);
    if (value == null) {
      return false;
    }
    _values.remove(value);
    return true;
  }

  /// Removes the [pseudonym] from the store, if it exists for any identity.
  ///
  /// Returns false, if there was no such pseudonym and true if a pseudonym was
  /// removed.
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
