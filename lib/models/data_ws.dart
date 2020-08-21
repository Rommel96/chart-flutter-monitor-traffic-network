class Message {
  final int down;
  final int up;

  Message(this.down, this.up);

  static fromJson(Map json) {
    return Message(json["downBytes"], json["upBytes"]);
  }
}

const URL_SERVER = "ws://x.x.x.x:port";
