import '../models/item_model.dart';

class ParsedReceipt {
  String storeName;
  List<ItemModel> items;
  double? total;
  DateTime? date;

  ParsedReceipt({required this.storeName, required this.items, this.total, this.date});
}

/// Heuristic receipt parser — tune untuk format struk yang kamu pakai.
class ReceiptParser {
  static ParsedReceipt parse(String rawText) {
    final lines = rawText.split(RegExp(r'\r?\n')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    String store = '';
    List<ItemModel> items = [];
    double? total;
    DateTime? date;

    if (lines.isNotEmpty) store = lines[0];
    if (store.isEmpty && lines.length > 1) store = lines[1];

    final dateRe = RegExp(r"(\d{1,2}[\-/]\d{1,2}[\-/]\d{2,4})|(\d{4}[\-/]\d{1,2}[\-/]\d{1,2})");
    for (var l in lines) {
      final m = dateRe.firstMatch(l);
      if (m != null) {
        try {
          final d = DateTime.tryParse(m.group(0)!.replaceAll('/', '-'));
          if (d != null) { date = d; break; }
        } catch (_) {}
      }
    }

    final totalRe = RegExp(r"(total|subtotal|jumlah)[:\s]*[Rp\s]*([0-9.,]+)", caseSensitive: false);
    for (var l in lines.reversed) {
      final m = totalRe.firstMatch(l);
      if (m != null) {
        final numStr = m.group(2)!.replaceAll(RegExp(r'[^0-9.]'), '');
        total = double.tryParse(numStr.replaceAll(',', ''));
        if (total != null) break;
      }
    }

    if (total == null) {
      for (var l in lines.reversed) {
        final numOnly = RegExp(r"[0-9.,]{3,}");
        final m = numOnly.firstMatch(l.replaceAll('.', ''));
        if (m != null) {
          final s = m.group(0)!.replaceAll(',', '');
          final val = double.tryParse(s);
          if (val != null && val > 10) {
            total = val; break;
          }
        }
      }
    }

    final itemLineRe = RegExp(r"(.+)\s+(\d+)x?\s+([0-9.,]+)");
    for (var l in lines) {
      final m = itemLineRe.firstMatch(l);
      if (m != null) {
        final name = m.group(1)!.trim();
        final qty = int.tryParse(m.group(2)!) ?? 1;
        final price = double.tryParse(m.group(3)!.replaceAll(',', '')) ?? 0.0;
        items.add(ItemModel(name: name, quantity: qty, unitPrice: price));
        continue;
      }
      final m2 = RegExp(r"(.+)\s+([0-9.,]+)\s*\$?").firstMatch(l);
      if (m2 != null) {
        final left = m2.group(1)!.trim();
        final numStr = m2.group(2)!.replaceAll(',', '');
        final val = double.tryParse(numStr);
        if (val != null && left.length > 1 && left.length < 40) {
          items.add(ItemModel(name: left, quantity: 1, unitPrice: val));
        }
      }
    }

    if (items.isEmpty && total != null) {
      items.add(ItemModel(name: 'Belanja', quantity: 1, unitPrice: total));
    }

    return ParsedReceipt(storeName: store, items: items, total: total, date: date);
  }
}
