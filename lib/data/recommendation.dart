double hitungTakaranPupuk(double luasMeter, int dosisPerHa) {
  double luasHa = luasMeter / 10000;
  return double.parse((luasHa * dosisPerHa).toStringAsFixed(2));
}

Map<String, Map<int, String>> ureaRecommendation = {
  'N23': {5: '75', 6: '100', 7: '125', 8: '150'},
  'N34': {5: '50', 6: '75', 7: '100', 8: '125'},
  'N45': {5: '0', 6: '0 atau 50', 7: '50', 8: '50'},
};

String getUreaRecommendation(String nilaiWarna, int gkg, double luasMeter) {
  final rekomendasi = ureaRecommendation[nilaiWarna]?[gkg];

  if (rekomendasi == null) return "Rekomendasi tidak tersedia.";

  if (rekomendasi.contains("atau")) {
    return "$rekomendasi kg/ha — Silakan konsultasi ke penyuluh pertanian.";
  }

  final perHa = int.tryParse(rekomendasi);
  if (perHa == null) return "Data tidak valid.";

  final total = hitungTakaranPupuk(luasMeter, perHa);
  return "Pupuk urea $total kg/ha";
}
