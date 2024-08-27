import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_util_readable_pseudonym/ad_hoc_ident_util_readable_pseudonym.dart';
import 'package:unique_names_generator/unique_names_generator.dart';

class WordPseudonymEncrypter implements AdHocIdentityEncrypter {
  static final _defaultConfig = Config(
    dictionaries: [adjectives, colors, animals],
    length: 3,
    seperator: ' ',
    style: Style.capital,
  );

  final AdHocIdentityEncrypter innerEncrypter;
  final UniqueNamesGenerator _generator;
  final PseudonymStorage storage;

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
