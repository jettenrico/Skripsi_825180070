class AbsensiSales {
  final String namaUser;
  final String filephoto;
  final String tanggalabsen;
  final String jam;

  AbsensiSales(
      {required this.namaUser,
      required this.filephoto,
      required this.tanggalabsen,
      required this.jam});

  factory AbsensiSales.fromJson(Map<String, dynamic> json) {
    return AbsensiSales(
      namaUser: json['user_fullname'],
      filephoto: json['file_photo'],
      tanggalabsen: json['date_in'],
      jam: json['jam'],
    );
  }
}
