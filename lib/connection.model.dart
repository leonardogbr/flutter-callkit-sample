class Connection {
  Map<String, dynamic> webrtc;

  Connection({
    required this.webrtc,
  });

  Connection.fromJson(Map<String, dynamic> json) : webrtc = json['webrtc'];

  Map<String, dynamic> toJson() {
    return {
      'webrtc': webrtc,
    };
  }
}
