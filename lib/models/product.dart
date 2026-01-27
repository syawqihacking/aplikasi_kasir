class Product {
  final int? id;
  final String sku;
  final String name;
  final String category;
  final String brand;
  final int buyPrice;
  final int sellPrice;
  final int stock;
  final int minStock;
  final int warrantyDays;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.brand,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.minStock,
    required this.warrantyDays,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'sku': sku,
        'name': name,
        'category': category,
        'brand': brand,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'stock': stock,
        'min_stock': minStock,
        'warranty_days': warrantyDays,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        sku: map['sku'],
        name: map['name'],
        category: map['category'],
        brand: map['brand'],
        buyPrice: map['buy_price'],
        sellPrice: map['sell_price'],
        stock: map['stock'],
        minStock: map['min_stock'],
        warrantyDays: map['warranty_days'],
      );
}