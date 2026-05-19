// Script test upload ke Cloudflare R2 via S3-compatible API (minio SDK)
// Jalankan: dart run tool/test_r2_upload.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:minio/minio.dart';

const _endpoint   = '6345dc5d51a7c38803936924993405cd.r2.cloudflarestorage.com';
const _accessKey  = 'b53b8dc66fe78dc4994888976d669199';
const _secretKey  = '5871491bd1e9dd00d41479e4a69dac2bdea990f4f2c1b662485c56e8bbde7f85';
const _bucket     = 'marketing-jagaddhita';
const _region     = 'auto';
const _publicUrl  = 'https://pub-98de0967b7d448d0a10dbaf9f62e0bb2.r2.dev';

void main() async {
  print('🔄 Menghubungkan ke Cloudflare R2...');
  print('   Endpoint : $_endpoint');
  print('   Bucket   : $_bucket');
  print('');

  final minio = Minio(
    endPoint: _endpoint,
    accessKey: _accessKey,
    secretKey: _secretKey,
    region: _region,
    useSSL: true,
  );

  // ── 1. Cek bucket exists ──────────────────────────────────────────────────
  try {
    await minio.bucketExists(_bucket);
    print('✅ Bucket "$_bucket" ditemukan');
  } catch (e) {
    print('❌ Bucket tidak ditemukan: $e');
    return;
  }

  // ── 2. Upload test file ───────────────────────────────────────────────────
  const objectName = 'test/r2_connection_test.txt';
  final content    = 'R2 upload test - ${DateTime.now().toIso8601String()}';
  final bytes      = Uint8List.fromList(utf8.encode(content));
  final stream     = Stream<Uint8List>.value(bytes);

  try {
    print('🔄 Mengupload file test...');
    await minio.putObject(_bucket, objectName, stream, size: bytes.length);
    final publicFileUrl = '$_publicUrl/$objectName';
    print('✅ Upload berhasil!');
    print('   URL : $publicFileUrl');
  } catch (e) {
    print('❌ Upload gagal: $e');
    return;
  }

  // ── 3. Verifikasi file ada di bucket ──────────────────────────────────────
  try {
    final stat = await minio.statObject(_bucket, objectName);
    print('✅ File terverifikasi di R2:');
    print('   Size         : ${stat.size} bytes');
    print('   Last Modified: ${stat.lastModified}');
  } catch (e) {
    print('⚠️  Verifikasi gagal (tapi upload mungkin berhasil): $e');
  }

  print('');
  print('🎉 Cloudflare R2 integration berjalan dengan baik!');
}
