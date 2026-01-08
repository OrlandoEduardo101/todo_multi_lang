import 'package:vaden/vaden.dart';

@DTO()
class StatusResponse {
  const StatusResponse({required this.message});
  final String message;

  Map<String, dynamic> toJson() => {'message': message};
}
