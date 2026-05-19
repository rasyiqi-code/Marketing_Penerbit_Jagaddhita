import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/product_model.dart';

class DataSeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedDemoData() async {
    final batch = _firestore.batch();

    // 1. Seed Products for House 1 (Penerbit Jagaddhita - Buku Anak, PAUD & Panduan Guru)
    final r1Products = [
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Gambar Lucu Mika',
        category: 'Buku Cerita Anak',
        price: 17500,
        description: 'Buku cerita anak berwarna yang berkisah tentang kreativitas Mika menggambar kesehariannya.',
        copywriting: 'Ajarkan kreativitas tak terbatas untuk si kecil lewat kisah Mika!',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Biji Merah Luna',
        category: 'Buku Cerita Anak',
        price: 17500,
        description: 'Kisah edukasi lingkungan tentang petualangan biji merah bernama Luna tumbuh menjadi pohon besar.',
        copywriting: 'Tanamkan cinta alam dan kesabaran sejak dini melalui petualangan Luna.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Apa Itu?',
        category: 'Buku Cerita Anak',
        price: 19000,
        description: 'Buku teka-teki interaktif melatih rasa ingin tahu dan daya analisis balita.',
        copywriting: 'Picu rasa penasaran cerdas buah hati Anda dengan buku tebak-tebakan seru ini!',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Namaku Kali',
        category: 'Buku Cerita Anak',
        price: 19000,
        description: 'Mengenalkan ekosistem sungai dan pentingnya menjaga kebersihan sungai bagi kehidupan.',
        copywriting: 'Bersama Kali si Sungai jernih, belajar menjaga kelestarian air bersih.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Naik-naik ke Puncak Bukit',
        category: 'Buku Cerita Anak',
        price: 19000,
        description: 'Petualangan seru mendaki bukit hijau mengenalkan berbagai macam vegetasi dan udara bersih.',
        copywriting: 'Petualangan seru mendaki bukit tanpa keluar rumah!',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Bandeng sang Penghuni Rawa',
        category: 'Buku Cerita Anak',
        price: 18400,
        description: 'Mengenal budidaya ikan bandeng dan peternakan payau lokal dengan bahasa anak yang sederhana.',
        copywriting: 'Kisah unik si ikan gesit penguasa perairan payau.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Kue Labu Andini',
        category: 'Buku Cerita Anak',
        price: 18100,
        description: 'Belajar berbagi dan bekerja sama membuat makanan lezat dari hasil kebun sendiri.',
        copywriting: 'Berbagi itu indah dan lezat, layaknya kue labu hangat buatan Andini.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku Cerita: Bertualang ke Kebun Binatang',
        category: 'Buku Cerita Anak',
        price: 18100,
        description: 'Mengenal fauna eksotis Indonesia terlindungi dengan ilustrasi penuh warna yang hidup.',
        copywriting: 'Keliling kebun binatang dan kenali satwa langka nusantara!',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Panduan Guru: Pembelajaran Fase Fondasi',
        category: 'Buku Panduan Guru',
        price: 59400,
        description: 'Buku panduan kurikulum merdeka PAUD untuk mendesain pembelajaran bermakna fase fondasi.',
        copywriting: 'Panduan utama guru PAUD mewujudkan pembelajaran holistik kurikulum merdeka.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Panduan Guru: Jati Diri',
        category: 'Buku Panduan Guru',
        price: 54400,
        description: 'Buku panduan mengasah karakter dasar, emosi positif, dan kecintaan tanah air bagi anak usia dini.',
        copywriting: 'Bentuk jati diri emas dan budi pekerti luhur sejak usia dini.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Panduan Guru: Dasar Literasi & STEAM',
        category: 'Buku Panduan Guru',
        price: 65100,
        description: 'Metodologi praktis mengenalkan sains, matematika, teknologi, seni, dan bahasa melalui bermain.',
        copywriting: 'Mengembangkan daya pikir kritis anak PAUD melalui sains dan seni yang menyenangkan.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Panduan Guru: Projek Penguatan Profil Pelajar Pancasila',
        category: 'Buku Panduan Guru',
        price: 60100,
        description: 'Contoh modul projek dan panduan implementasi P5 praktis pada satuan PAUD dan TK.',
        copywriting: 'Wujudkan projek pelajar pancasila yang menyenangkan dan inspiratif.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Paket 1: Paket Hemat 20 Buku Cerita Pilihan',
        category: 'Paket Buku',
        price: 376500,
        description: 'Bundling hemat berisi 20 judul cerita anak pilihan untuk koleksi pojok baca kelas PAUD/TK.',
        copywriting: 'Lengkapi perpustakaan sekolah/rumah dengan pojok baca super hemat!',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Paket 2: Paket Lengkap 32 Buku Cerita & Kreativitas',
        category: 'Paket Buku',
        price: 603000,
        description: 'Bundling lengkap 32 buku cerita anak berkarakter ditambah buku panduan aktivitas anak didik.',
        copywriting: 'Paket lengkap paling digemari untuk program literasi sekolah aktif.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Paket 3: Paket Super Literasi 50 Buku Anak',
        category: 'Paket Buku',
        price: 898900,
        description: 'Bundling super lengkap berisi seluruh 50 judul buku cerita anak terbitan Jagaddhita Media Pustaka.',
        copywriting: 'Koleksi mahakarya literasi terbaik terlengkap untuk perpustakaan sekolah unggulan.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku SIBI: Pendidikan Pancasila SD Kelas I',
        category: 'Buku SIBI Kemendikbud',
        price: 28000,
        description: 'Buku teks utama SIBI (Sistem Informasi Buku Indonesia) resmi dari Kemendikbudristek untuk mata pelajaran Pendidikan Pancasila Kelas 1 SD.',
        copywriting: 'Pendidikan karakter Pancasila kurikulum merdeka resmi untuk buah hati kelas 1.',
      ),
      ProductModel(
        id: _firestore.collection('products').doc().id,
        houseType: 1,
        name: 'Buku SIBI: Bahasa Indonesia SD Kelas II',
        category: 'Buku SIBI Kemendikbud',
        price: 32000,
        description: 'Buku teks utama SIBI resmi Kemendikbudristek pelajaran Bahasa Indonesia SD Kelas 2.',
        copywriting: 'Asah keterampilan membaca dan berbahasa indonesia dengan modul standar nasional.',
      ),
    ];


    for (var p in r1Products) {
      final docRef = _firestore.collection('products').doc(p.id);
      batch.set(docRef, p.toMap());
    }

    await batch.commit();
  }

  Future<void> clearAllData() async {
    // 1. Delete all products
    final products = await _firestore.collection('products').get();
    final batch = _firestore.batch();
    for (var doc in products.docs) {
      batch.delete(doc.reference);
    }

    // 2. Delete all sales
    final sales = await _firestore.collection('sales').get();
    for (var doc in sales.docs) {
      batch.delete(doc.reference);
    }

    // 3. Delete all claims
    final claims = await _firestore.collection('claims').get();
    for (var doc in claims.docs) {
      batch.delete(doc.reference);
    }

    // 4. Delete wallet history
    final history = await _firestore.collection('wallet_history').get();
    for (var doc in history.docs) {
      batch.delete(doc.reference);
    }

    // 5. Delete all notifications
    final notifications = await _firestore.collection('notifications').get();
    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    // 6. Reset User Balances & Stats
    final users = await _firestore.collection('users').get();
    for (var doc in users.docs) {
      batch.update(doc.reference, {
        'commission_balance': 0,
        'markup_balance': 0,
        'pulsa_balance': 0,
        'total_sales_count': 0,
        'total_commission_earned': 0,
        'total_pulsa_earned': 0,
      });
    }

    await batch.commit();
  }
}
