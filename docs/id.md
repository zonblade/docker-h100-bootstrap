# Docker Development Workspace

Lingkungan pengembangan terkontainerisasi dengan dukungan CUDA, resource yang dapat dikonfigurasi, dan setup interaktif.

## Mulai Cepat

```bash
./create.sh   # Setup awal dan mulai
./manage.sh   # Kelola container yang berjalan
```

**Setup pertama kali:**
- `./create.sh` memandu Anda melalui penamaan container, batasan CPU/RAM, versi CUDA, pemilihan GPU
- Otomatis mendeteksi driver NVIDIA dan menyarankan versi CUDA yang kompatibel
- Container dimulai secara otomatis setelah konfigurasi

**Penggunaan harian:**
- `./manage.sh` menyediakan menu untuk start/stop/rebuild/logs/connect

## File

- `create.sh` - Script setup interaktif dengan UI berwarna
- `manage.sh` - Manajemen container dengan start/stop/rebuild/logs
- `docker-compose.yaml` - Konfigurasi container dengan substitusi variabel
- `Dockerfile.gpu` - Ubuntu 22.04 dengan CUDA dan Python 3.10
- `Dockerfile.cpu` - Ubuntu 22.04 khusus CPU dengan Python 3.10
- `.env.setup` - Template variabel environment
- `.env` - Konfigurasi yang dihasilkan (dibuat oleh create.sh)

## Konfigurasi

Variabel environment di `.env`:
```bash
GPU_NUMBER=0,1     # ID GPU atau "all" (atau "none" untuk CPU-only)
LIMIT_CPU=4        # Core CPU
LIMIT_RAM=8G       # Batas memori (suffix G/M diperlukan)
CUDA_VERSION=12.4.0  # Versi CUDA untuk Docker image
USE_GPU=yes        # "yes" atau "no" untuk akselerasi GPU
DOCKERFILE_NAME=Dockerfile.gpu  # Auto-dipilih berdasarkan pilihan GPU
```

## Volume

- `./src` → `/app/src` (kode sumber Anda)
- `./cache` → `/app/cache` (cache model ML, cache pip, dll)

## Penggunaan

1. **Pertama kali:** `./create.sh` untuk konfigurasi dan mulai
2. **Manajemen harian:** `./manage.sh` untuk menu operasi
3. **Koneksi cepat:** Opsi 6 di manage.sh atau `docker exec -it <container-name> bash`
4. **Development:** Kode Anda di `./src` ter-mount dan siap untuk diedit

**Operasi Manajemen:**
- Start/Stop container dengan konfirmasi
- Rebuild dengan build segar
- Lihat log real-time
- Monitor penggunaan CPU/memori
- Pembersihan aman khusus proyek

## Fitur

- **Pemilihan Versi CUDA Cerdas** - Mendeteksi driver NVIDIA dan menyarankan versi CUDA yang kompatibel (12.0-12.6)
- Dukungan GPU dengan pemilihan device yang dapat dikonfigurasi
- Batasan resource (CPU/RAM)
- Mode host networking
- Direktori cache persisten
- Shell bash interaktif untuk pengembangan