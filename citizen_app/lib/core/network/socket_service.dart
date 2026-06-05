import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;
  bool isConnected = false;
  final ValueNotifier<bool> connectionNotifier = ValueNotifier<bool>(false);

  void init(String token) {
    if (socket != null && isConnected) return;

    // Retrieve socket URL from ApiConstants.baseUrl
    // Base URL is typically e.g. "http://127.0.0.1:5000/api/" -> we want "http://127.0.0.1:5000"
    final String socketUrl = ApiConstants.baseUrl.replaceAll('/api/', '');
    debugPrint('Initializing socket connection to: $socketUrl');

    socket = IO.io(socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .build()
    );

    socket!.onConnect((_) {
      debugPrint('Socket connected successfully');
      isConnected = true;
      connectionNotifier.value = true;
    });

    socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
      isConnected = false;
      connectionNotifier.value = false;
    });

    socket!.onConnectError((err) {
      debugPrint('Socket Connect Error: $err');
      isConnected = false;
      connectionNotifier.value = false;
    });

    socket!.connect();
  }

  void joinRoom(String complaintId) {
    if (socket == null) {
      debugPrint('Cannot join room: Socket is not initialized');
      return;
    }
    socket!.emit('joinRoom', {'complaintId': complaintId});
    debugPrint('Emitted joinRoom for: $complaintId');
  }

  void leaveRoom(String complaintId) {
    if (socket == null) return;
    socket!.emit('leaveRoom', {'complaintId': complaintId});
    debugPrint('Emitted leaveRoom for: $complaintId');
  }

  void sendMessage(String complaintId, String userId, String content) {
    if (socket == null) {
      debugPrint('Cannot send message: Socket is not initialized');
      return;
    }
    socket!.emit('sendMessage', {
      'complaintId': complaintId,
      'userId': userId,
      'content': content,
    });
    debugPrint('Emitted sendMessage to room $complaintId');
  }

  void listenToMessages(Function(dynamic) onNewMessage) {
    if (socket == null) return;
    socket!.off('newMessage'); // Ensure we don't duplicate listeners
    socket!.on('newMessage', (data) {
      debugPrint('Socket received newMessage event: $data');
      onNewMessage(data);
    });
  }

  void stopListeningToMessages() {
    if (socket == null) return;
    socket!.off('newMessage');
  }

  void disconnect() {
    if (socket != null) {
      socket!.disconnect();
      socket = null;
      isConnected = false;
      connectionNotifier.value = false;
      debugPrint('Socket disconnected manually');
    }
  }
}
