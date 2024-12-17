import 'package:hive/hive.dart';

class Message{
 final String messageid;
  final String chatid;
  final Role role;// enum type
  // get messages from gemini API so use string Buffer
  final StringBuffer message;
  final List<String> imageUrls;
  final DateTime timeSent;
@override
String toString() {
  return message.toString();
}

  //constructor
  Message({
  required this.messageid,
  required this.chatid,
  required this.role,
  required this.message,
  required this.imageUrls,
  required this.timeSent
});

//serialize to Map for hive

Map<String, dynamic> toMap()
{
  return{
    'messageId' : messageid,
    'chatId' : chatid,
    'role' : role.index,
    'message' : message.toString(),
    'imageUrls' : imageUrls,
    'timeSent' : timeSent.toIso8601String(),
  };
}

//fDEserialize from map for hive
factory Message.fromMap(Map<String,dynamic> map){
  return Message(
    messageid: map['messageId'] ?? '',
    chatid: map['chatId'] ?? '',
    role:Role.values[map['role'] as int],
    message: StringBuffer(map['message'] ?? ''),
    imageUrls: List<String>.from(map['imageUrls'] ?? ''),
    timeSent: DateTime.parse(map['timeSent'] ?? DateTime.now().toIso8601String()),
  );
}

//copy with
Message copywith({
  String? messageid,
  String? chatid,
  Role? role,
  StringBuffer? message,
  List<String>? imageUrls,
  DateTime? timeSent
}){
  return Message(
    messageid: messageid ?? this.messageid,
    chatid: chatid ?? this.chatid,
    role: role ?? this.role,
    message: message ?? this.message,
    imageUrls: imageUrls ?? this.imageUrls,
    timeSent: timeSent ?? this.timeSent
  );
}


@override
bool operator == (Object other){
  if (identical(this, other)) return true;

  return other is Message &&
  other.messageid== messageid ;

} 

@override
  int get hashCode{
    return messageid.hashCode;
  }
}

enum Role{
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
}
class RoleAdapter extends TypeAdapter<Role> {
  @override
  final int typeId = 1; // Ensure this is a unique ID for the Role type.

  @override
  Role read(BinaryReader reader) {
    final index = reader.readByte();
    // Check if index is invalid (e.g., -1, which may represent null)
     if (index < 0 || index >= Role.values.length) {
      throw HiveError('Invalid Role index: $index');
    }
    // if (index == -1) {
    //   return Role.user;  // Default to 'user' role if the value is null
    // }
    return Role.values[index];
  }

  @override
  void write(BinaryWriter writer, Role obj) {
    // If the value is null, write -1 to represent it as null
    // ignore: unnecessary_null_comparison
    writer.writeByte(obj == null ? -1 : obj.index);
  }
}