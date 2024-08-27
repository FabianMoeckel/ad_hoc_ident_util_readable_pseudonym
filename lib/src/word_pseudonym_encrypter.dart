import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_util_readable_pseudonym/ad_hoc_ident_util_readable_pseudonym.dart';
import 'package:unique_names_generator/unique_names_generator.dart';

/// Translates an AdHocIdentity's identifier to a human readable pseudonym.
///
/// Uses a [PseudonymStorage] to store created pseudonyms and respond with the
/// same pseudonym for known [AdHocIdentity]s.
class WordPseudonymEncrypter implements AdHocIdentityEncrypter {
  static final _defaultConfig = Config(
    dictionaries: [adjectives, colors, animals],
    length: 3,
    seperator: ' ',
    style: Style.capital,
  );

  /// The wrapped [AdHocIdentityEncrypter] providing a secure [AdHocIdentity].
  final AdHocIdentityEncrypter innerEncrypter;
  final UniqueNamesGenerator _generator;

  /// The [PseudonymStorage] used to store created pseudonyms and retrieve
  /// existing ones.
  ///
  /// If an [AdHocIdentity] is processed, a new pseudonym is created if it the
  /// identity is not yet known. The newly created pseudonym is stored in the
  /// [PseudonymStorage]. Before creating a new pseudonym, the storage is
  /// checked for an existing pseudonym. If a pseudonym is found, it is
  /// returned instead of creating a new one.
  final PseudonymStorage storage;

  /// Creates a [WordPseudonymEncrypter] wrapping the [innerEncrypter].
  ///
  /// The [PseudonymStorage] is used to store created pseudonyms and retrieve
  /// existing ones. The [generatorConfig] can be used to adjust the pseudonym
  /// generator.
  WordPseudonymEncrypter(
      {required this.innerEncrypter,
      required this.storage,
      Config? generatorConfig})
      : _generator = UniqueNamesGenerator(
          config: generatorConfig ?? _defaultConfig,
        );

  @override
  FutureOr<AdHocIdentity> encrypt(AdHocIdentity identity) async {
    final encryptedIdentity = await innerEncrypter.encrypt(identity);
    final existingPseudonym = await storage.get(encryptedIdentity);
    if (existingPseudonym != null) {
      return AdHocIdentity(
          type: encryptedIdentity.type, identifier: existingPseudonym);
    }

    String newPseudonym;
    bool added;
    do {
      newPseudonym = _generator.generate();
      added = await storage.set(encryptedIdentity, newPseudonym);
    } while (!added);

    return AdHocIdentity(
        type: encryptedIdentity.type, identifier: newPseudonym);
  }
}
