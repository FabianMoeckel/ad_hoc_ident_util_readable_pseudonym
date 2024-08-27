import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_util_readable_pseudonym/ad_hoc_ident_util_readable_pseudonym.dart';
import 'package:test/test.dart';

void main() {
  test('store and retrieve entry from pseudonym storage', () async {
    final identity = AdHocIdentity(type: "test", identifier: "testIdentifier");
    final pseudonym = "unknown moose";
    final storage = PseudonymStorage.memory();

    final added = await storage.set(identity, pseudonym);
    final pseudonymFoundAfterAdd = await storage.get(identity);
    final removed = await storage.remove(identity);
    final pseudonymFoundAfterRemove = await storage.get(identity);
    final addedAgain = await storage.set(identity, pseudonym);
    final pseudonymFoundAfterSecondAdd = await storage.get(identity);
    final removedByValue = await storage.removeByValue(pseudonym);
    final pseudonymFoundAfterRemoveByValue = await storage.get(identity);

    expect(added, true);
    expect(pseudonymFoundAfterAdd, pseudonym);
    expect(removed, true);
    expect(pseudonymFoundAfterRemove, null);
    expect(addedAgain, true);
    expect(pseudonymFoundAfterSecondAdd, pseudonym);
    expect(removedByValue, true);
    expect(pseudonymFoundAfterRemoveByValue, null);
  });

  test('create two different pseudonyms', () async {
    final identity1 = AdHocIdentity(type: "test", identifier: "testIdentifier");
    final identity2 =
        AdHocIdentity(type: "otherType", identifier: "otherIdentifier");
    final storage = PseudonymStorage.memory();
    final mockEncrypter = AdHocIdentityEncrypter.fromDelegate(
      (identity) async => identity,
    );
    final encrypter = WordPseudonymEncrypter(
      storage: storage,
      innerEncrypter: mockEncrypter,
    );

    final encryptedIdentity1 = await encrypter.encrypt(identity1);
    final encryptedIdentity2 = await encrypter.encrypt(identity2);

    final storedPseudonym1 = await storage.get(identity1);
    final storedPseudonym2 = await storage.get(identity2);

    expect(encryptedIdentity1.identifier, isNot(encryptedIdentity2.identifier));

    expect(encryptedIdentity1.type, identity1.type);
    expect(encryptedIdentity1.identifier, storedPseudonym1);
    expect(storedPseudonym1, isNot(identity1.identifier));

    expect(encryptedIdentity2.type, identity2.type);
    expect(encryptedIdentity2.identifier, storedPseudonym2);
    expect(storedPseudonym2, isNot(identity2.identifier));
  });

  test('recreate the same pseudonym', () async {
    final identity = AdHocIdentity(type: "test", identifier: "testIdentifier");
    final storage = PseudonymStorage.memory();
    final mockEncrypter = AdHocIdentityEncrypter.fromDelegate(
      (identity) async => identity,
    );
    final encrypter = WordPseudonymEncrypter(
      storage: storage,
      innerEncrypter: mockEncrypter,
    );

    final encryptedIdentity1 = await encrypter.encrypt(identity);
    final encryptedIdentity2 = await encrypter.encrypt(identity);

    final storedPseudonym = await storage.get(identity);

    expect(encryptedIdentity1.type, encryptedIdentity2.type);
    expect(encryptedIdentity1.identifier, encryptedIdentity2.identifier);

    expect(encryptedIdentity1.type, identity.type);
    expect(encryptedIdentity1.identifier, storedPseudonym);
    expect(storedPseudonym, isNot(identity.identifier));
  });
}
