import 'package:appwrite/appwrite.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('6490223d4ceb25b1b8f8')
    .setSelfSigned(status: true);

final Account account = Account(client);
final String uniqueId = ID.unique();
final Databases database = Databases(client);
final Avatars avatars = Avatars(client);
final Storage storage = Storage(client);
final Locale local = Locale(client);
// Subscribe to files channel
final Realtime realtime = Realtime(client);
