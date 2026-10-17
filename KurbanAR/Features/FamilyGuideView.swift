import SwiftUI

struct FamilyGuideView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Belajar bersama") {
                    Text("Pilih SD untuk cerita singkat atau SMP untuk penjelasan tambahan. Pilihan ini disimpan di perangkat, tanpa meminta nama atau tanggal lahir.")
                    Text("Bacakan, dengarkan bersama, dan beri ruang untuk bertanya. Setiap anak boleh merasa penasaran, sedih, atau memilih tidak mengamati.")
                }
                Section("Saat berkunjung di Hari Kurban") {
                    Label("Ikuti batas area dan arahan panitia.",systemImage:"person.2.fill")
                    Label("Jangan mengajak anak memegang alat tajam atau mendekati hewan yang sedang ditangani.",systemImage:"hand.raised.fill")
                    Label("Menyiapkan kartu ucapan atau belajar pencatatan dapat menjadi kegiatan alternatif, di area yang diizinkan.",systemImage:"heart.text.clipboard")
                    Text("Aplikasi menjelaskan penyembelihan dengan kata-kata dan simbol saja. Penjelasan tambahan dapat dilewati; penghargaan belajar tidak berubah.")
                }
                Section("Privasi & kamera") {
                    Text("Tidak ada akun, iklan, chat, pembelian, papan peringkat, atau analitik. Pilihan belajar, bintang, dan lencana disimpan di perangkat.")
                    Text("Kamera hanya digunakan ketika mode AR dimulai. Gambar tidak direkam atau dikirim oleh aplikasi. Narasi memakai pembaca suara sistem, bukan layanan AI atau unggahan rekaman.")
                    Text("Dampingi anak saat memakai AR. Pilih tempat lapang dan jangan berjalan sambil terpaku pada layar.")
                }
                Section("Tentang materi · Prototipe 0.3") {
                    Text("Konten perlu ditinjau oleh pendidik, ahli agama, dan tenaga kesehatan hewan sebelum rilis. Model dan permainan tidak menilai kelayakan hewan atau mengajarkan teknik penyembelihan.")
                    Text("Rujukan pendamping: Kementerian Agama tentang makna Iduladha dan pengaturan distribusi; Kementerian Pertanian tentang kesejahteraan hewan. Daftar tautan lengkap tersedia di dokumentasi proyek.")
                }
            }.navigationTitle("Untuk pendamping").navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Selesai") { dismiss() } }.tint(Palette.green)
        }
    }
}
