class OrderList {
  final String orderNumber;
  final String tglTransaksi;
  final String status;
  final String pickup;
  final String lat;
  final String long;

  OrderList(
      {required this.orderNumber,
      required this.tglTransaksi,
      required this.status,
      required this.pickup,
      required this.lat,
      required this.long});

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      orderNumber: json['order_number'],
      tglTransaksi: json['order_date'],
      status: json['order_status_id'],
      pickup: json['ispickup'],
      lat: json['latitude'],
      long: json['longitude'],
    );
  }
}

class OrderListSales {
  final String orderNumber;
  final String tglTransaksi;
  final String status;
  final String buktibayar;
  final String pickup;
  final String lat;
  final String long;
  final String detailalamat;

  OrderListSales(
      {required this.orderNumber,
      required this.tglTransaksi,
      required this.status,
      required this.buktibayar,
      required this.pickup,
      required this.lat,
      required this.long,
      required this.detailalamat});

  factory OrderListSales.fromJson(Map<String, dynamic> json) {
    return OrderListSales(
        orderNumber: json['order_number'],
        tglTransaksi: json['order_date'],
        status: json['order_status_id'],
        buktibayar: json['buktibayar'],
        pickup: json['ispickup'],
        lat: json['latitude'],
        long: json['longitude'],
        detailalamat: json['detail_alamat']);
  }
}

class PenerimaanOrder {
  final String orderNumber;
  final String tglTransaksi;
  final String status;

  PenerimaanOrder({
    required this.orderNumber,
    required this.tglTransaksi,
    required this.status,
  });

  factory PenerimaanOrder.fromJson(Map<String, dynamic> json) {
    return PenerimaanOrder(
      orderNumber: json['purchase_number'],
      tglTransaksi: json['purchase_order_date'],
      status: json['purchase_status_id'],
    );
  }
}

class TransactionLog {
  final String transNumber;
  final String tglTransaksi;
  final String value;
  final String purchaseNumber;
  final String tipeTrans;
  final String customer;
  final String sales;

  TransactionLog(
      {required this.transNumber,
      required this.tglTransaksi,
      required this.value,
      required this.purchaseNumber,
      required this.tipeTrans,
      required this.customer,
      required this.sales});

  factory TransactionLog.fromJson(Map<String, dynamic> json) {
    return TransactionLog(
      transNumber: json['trans_number'],
      tglTransaksi: json['tanggaltransaksi'],
      value: json['trans_total_price'],
      purchaseNumber: json['purchase_number'],
      tipeTrans: json['transaksi'],
      customer: json['customer'],
      sales: json['sales'],
    );
  }
}
