# Analisis Penataan Folder & Modularitas Struktur Fitur

Dokumen ini menganalisis struktur folder fitur saat ini di bawah `lib/src/features` dan memberikan rekomendasi penataan berkas Dart ke subfolder yang lebih terorganisir untuk meningkatkan modularitas, kepatuhan terhadap prinsip DRY, kemudahan pemeliharaan, serta skalabilitas proyek.

---

## 📂 Analisis Berkas & Rencana Penataan

### 1. Fitur Admin (`lib/src/features/admin`)

Saat ini ada banyak berkas widget yang diletakkan langsung di root `admin/widgets/` sehingga mempersulit navigasi komponen.

#### Rencana Pemindahan Berkas
| Berkas Asal | Berkas Tujuan | Deskripsi / Alasan |
|-------------|---------------|--------------------|
| `widgets/admin_product_card.dart` | `widgets/product/admin_product_card.dart` | Mengelompokkan widget terkait produk ke folder khusus `product/`. |
| `widgets/admin_product_empty_state.dart` | `widgets/product/admin_product_empty_state.dart` | Mengelompokkan widget terkait produk ke folder khusus `product/`. |
| `widgets/admin_user_card.dart` | `widgets/user/admin_user_card.dart` | Membuat folder `user/` baru untuk mengelompokkan widget manajemen pengguna. |
| `widgets/admin_user_card_components.dart` | `widgets/user/admin_user_card_components.dart` | Mengelompokkan komponen card user bersama widget utamanya. |
| `widgets/admin_top_agents_list.dart` | `widgets/dashboard/admin_top_agents_list.dart` | Membuat folder `dashboard/` admin untuk memisahkan widget visual ringkasan dasbor. |
| `widgets/admin_recent_transactions_list.dart` | `widgets/dashboard/admin_recent_transactions_list.dart` | Widget ringkasan transaksi terbaru milik dasbor admin. |
| `widgets/admin_pending_claims_card.dart` | `widgets/dashboard/admin_pending_claims_card.dart` | Widget ringkasan klaim tertunda milik dasbor admin. |
| `widgets/admin_total_agents_card.dart` | `widgets/dashboard/admin_total_agents_card.dart` | Widget ringkasan total agen milik dasbor admin. |
| `widgets/transaction_card.dart` | `widgets/transaction/transaction_card.dart` | Membuat folder `transaction/` baru untuk memisahkan widget terkait transaksi admin. |
| `widgets/transaction_detail_modal.dart` | `widgets/transaction/transaction_detail_modal.dart` | Modal detail transaksi diletakkan bersama komponen transaksi lainnya. |

---

### 2. Fitur Penjualan (`lib/src/features/sales`)

Berkas widget di bawah `sales/widgets/` dan `sales/history/widgets/` masih dapat dirapikan ke dalam sub-kategori fungsional.

#### Rencana Pemindahan Berkas
| Berkas Asal | Berkas Tujuan | Deskripsi / Alasan |
|-------------|---------------|--------------------|
| `widgets/product_picker_field.dart` | `widgets/product_picker/product_picker_field.dart` | Memasukkan field utama ke folder modular `product_picker/` bersama widget anaknya. |
| `widgets/sales_entry_shared_widgets.dart` | `widgets/sales_entry/sales_entry_shared_widgets.dart` | Memasukkan berkas pembantu input ke subfolder `sales_entry/`. |
| `widgets/markup_input_field.dart` | `widgets/sales_entry/markup_input_field.dart` | Memasukkan input markup penjualan ke subfolder `sales_entry/`. |
| `widgets/transaction_proof_input.dart` | `widgets/sales_entry/transaction_proof_input.dart` | Memasukkan input bukti transaksi ke subfolder `sales_entry/`. |
| `widgets/faktur_printable_sheet.dart` | `widgets/faktur/faktur_printable_sheet.dart` | Membuat folder `faktur/` baru untuk mengelompokkan lembar cetak faktur. |
| `widgets/faktur_view.dart` | `widgets/faktur/faktur_view.dart` | Widget pratinjau faktur dikelompokkan ke folder `faktur/`. |
| `widgets/slanted_clipper.dart` | `widgets/faktur/slanted_clipper.dart` | Clipper dekoratif faktur dikelompokkan ke folder `faktur/`. |
| `history/widgets/sale_detail_sheet.dart` | `history/widgets/detail/sale_detail_sheet.dart` | Memindahkan sheet detail transaksi ke subfolder `detail/` yang sudah ada. |
| `history/widgets/sale_card.dart` | `history/widgets/shared/sale_card.dart` | Mengelompokkan card item penjualan ke folder shared history. |
| `history/widgets/pelunasan_dialog.dart` | `history/widgets/shared/pelunasan_dialog.dart` | Mengelompokkan dialog aksi pelunasan ke folder shared history. |
| `history/widgets/sales_claim_card.dart` | `history/widgets/shared/sales_claim_card.dart` | Mengelompokkan card history klaim dana ke folder shared history. |

---

### 3. Fitur Halaman Utama (`lib/src/features/home`)

Dasbor marketing memiliki banyak widget penunjang navigasi dan informasi statis di level root widget.

#### Rencana Pemindahan Berkas
| Berkas Asal | Berkas Tujuan | Deskripsi / Alasan |
|-------------|---------------|--------------------|
| `widgets/top_marketers_list.dart` | `widgets/dashboard/top_marketers_list.dart` | Memindahkan list peringkat marketing ke subfolder `dashboard/`. |
| `widgets/recent_sales_list.dart` | `widgets/dashboard/recent_sales_list.dart` | Memindahkan ringkasan aktivitas penjualan terkini ke `dashboard/`. |
| `widgets/home_header.dart` | `widgets/dashboard/home_header.dart` | Header sambutan diletakkan di `dashboard/`. |
| `widgets/home_latest_info.dart` | `widgets/dashboard/home_latest_info.dart` | Widget papan pengumuman/informasi diletakkan di `dashboard/`. |
| `widgets/wallet_card.dart` | `widgets/dashboard/wallet_card.dart` | Ringkasan kartu saldo diletakkan di `dashboard/`. |
| `widgets/marketing_category_card.dart` | `widgets/dashboard/marketing_category_card.dart` | Indikator tingkatan reseller diletakkan di `dashboard/`. |
| `widgets/admin_fab_menu.dart` | `widgets/navigation/admin_fab_menu.dart` | Membuat folder `navigation/` untuk mengelompokkan pengalih navigasi. |
| `widgets/marketing_fab_menu.dart` | `widgets/navigation/marketing_fab_menu.dart` | Memindahkan menu FAB melayang ke folder `navigation/`. |
| `widgets/main_bottom_nav_bar.dart` | `widgets/navigation/main_bottom_nav_bar.dart` | Bilah navigasi bawah diletakkan di folder `navigation/`. |

---

### 4. Fitur Link Bio (`lib/src/features/link_bio`)

Halaman tautan bio memiliki beberapa dialog dan widget admin yang bisa dikategorikan lebih rapi.

#### Rencana Pemindahan Berkas
| Berkas Asal | Berkas Tujuan | Deskripsi / Alasan |
|-------------|---------------|--------------------|
| `add_edit_link_dialog.dart` | `widgets/dialogs/add_edit_link_dialog.dart` | Memindahkan form dialog utama ke folder widget dialog. |
| `widgets/link_bio_admin_widgets.dart` | `widgets/admin/link_bio_admin_widgets.dart` | Membuat folder `admin/` untuk widget konfigurasi pemilik bio. |
| `widgets/link_bio_social_form.dart` | `widgets/admin/link_bio_social_form.dart` | Form sosial media admin dimasukkan ke folder `admin/`. |
| `widgets/social_media_text_field.dart` | `widgets/admin/social_media_text_field.dart` | Kolom input sosial media admin dimasukkan ke folder `admin/`. |
| `widgets/link_bio_header_card.dart` | `widgets/admin/link_bio_header_card.dart` | Card layout admin dimasukkan ke folder `admin/`. |
| `widgets/link_bio_custom_link_card.dart` | `widgets/admin/link_bio_custom_link_card.dart` | Komponen edit tautan admin dimasukkan ke folder `admin/`. |
| `widgets/link_bio_profile_header.dart` | `widgets/preview/link_bio_profile_header.dart` | Membuat folder `preview/` untuk komponen halaman publik bio. |
| `widgets/link_bio_book_catalog_section.dart` | `widgets/preview/link_bio_book_catalog_section.dart` | Galeri katalog buku publik bio dimasukkan ke folder `preview/`. |
| `widgets/link_bio_custom_links_section.dart` | `widgets/preview/link_bio_custom_links_section.dart` | Daftar tautan publik bio dimasukkan ke folder `preview/`. |
| `widgets/digital_business_card/digital_business_card.dart` | `widgets/digital_business_card/digital_business_card_preview.dart` | Ubah nama berkas agar lebih deskriptif (menghindari nama class ganda). |
