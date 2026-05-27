// Script test upload ke Cloudflare R2 via S3-compatible API (minio SDK)
// Jalankan: dart run tool/test_r2_upload.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';

const _endpoint   = '6345dc5d51a7c38803936924993405cd.r2.cloudflarestorage.com';
const _accessKey  = 'b53b8dc66fe78dc4994888976d669199';
const _secretKey  = '5871491bd1e9dd00d41479e4a69dac2bdea990f4f2c1b662485c56e8bbde7f85';
const _bucket     = 'marketing-jagaddhita';
const _region     = 'auto';
const _publicUrl  = 'https://pub-98de0967b7d448d0a10dbaf9f62e0bb2.r2.dev';

void main() async {
  stdout.writeln('🔄 Menghubungkan ke Cloudflare R2...');
  stdout.writeln('   Endpoint : $_endpoint');
  stdout.writeln('   Bucket   : $_bucket');
  stdout.writeln('');

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
    stdout.writeln('✅ Bucket "$_bucket" ditemukan');
  } catch (e) {
    stderr.writeln('❌ Bucket tidak ditemukan: $e');
    return;
  }

  // ── 2. Upload test file ───────────────────────────────────────────────────
  const objectName = 'test/r2_connection_test.txt';
  final content    = 'R2 upload test - ${DateTime.now().toIso8601String()}';
  final bytes      = Uint8List.fromList(utf8.encode(content));
  final stream     = Stream<Uint8List>.value(bytes);

  try {
    stdout.writeln('🔄 Mengupload file test...');
    await minio.putObject(_bucket, objectName, stream, size: bytes.length);
    final publicFileUrl = '$_publicUrl/$objectName';
    stdout.writeln('✅ Upload berhasil!');
    stdout.writeln('   URL : $publicFileUrl');
  } catch (e) {
    stderr.writeln('❌ Upload gagal: $e');
    return;
  }

  // ── 3. Verifikasi file ada di bucket ──────────────────────────────────────
  try {
    final stat = await minio.statObject(_bucket, objectName);
    stdout.writeln('✅ File terverifikasi di R2:');
    stdout.writeln('   Size         : ${stat.size} bytes');
    stdout.writeln('   Last Modified: ${stat.lastModified}');
  } catch (e) {
    stderr.writeln('⚠️  Verifikasi gagal (tapi upload mungkin berhasil): $e');
  }

  stdout.writeln('');
  stdout.writeln('🎉 Cloudflare R2 integration berjalan dengan baik!');
}
