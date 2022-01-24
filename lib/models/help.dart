import 'dart:convert';

class Help {
  final String nomor;
  final String namaHelp;

  Help({
    required this.nomor,
    required this.namaHelp,
  });

  factory Help.fromJson(Map<String, dynamic> json) {
    return Help(
      nomor: json['id'],
      namaHelp: json['namahelp'],
    );
  }
}

FileModel fileModelFromJson(String str) => FileModel.fromJson(json.decode(str));

String fileModelToJson(FileModel data) => json.encode(data.toJson());

class FileModel {
  FileModel({
    this.fileName,
    this.url,
    this.progress,
  });

  String? fileName;
  String? url;
  double? progress;

  factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
        fileName: json["fileName"] == null ? null : json["fileName"],
        url: json["url"] == null ? null : json["url"],
        progress: json["progress"] == null ? null : json["progress"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName == null ? null : fileName,
        "url": url == null ? null : url,
        "progress": progress == null ? null : progress,
      };
}
