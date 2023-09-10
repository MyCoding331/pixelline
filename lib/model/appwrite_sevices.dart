import 'package:appwrite/appwrite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('6490223d4ceb25b1b8f8')
    .setSelfSigned(status: true);
const url = 'https://slxftlarogkbsdtwepdn.supabase.co';
const anonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNseGZ0bGFyb2drYnNkdHdlcGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTAwMDkwODYsImV4cCI6MjAwNTU4NTA4Nn0.wgjry4nM5bBmxsBLyhxbSa6yIjeoyxDvyLmCW9_lU5U';
final Account account = Account(client);
final String uniqueId = ID.unique();
final Databases database = Databases(client);
final Avatars avatars = Avatars(client);
final Storage storage = Storage(client);
// Subscribe to files channel
final Realtime realtime = Realtime(client);

final superbase = SupabaseClient(url, anonKey);
