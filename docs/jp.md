# Docker開発ワークスペース

CUDA対応、設定可能なリソース、インタラクティブセットアップを備えたコンテナ化された開発環境。

## クイックスタート

```bash
./create.sh   # 初期セットアップと開始
./manage.sh   # 実行中のコンテナ管理
```

**初回セットアップ:**
- `./create.sh` でコンテナ名、CPU/RAM制限、CUDAバージョン、GPU選択をガイド
- NVIDIAドライバを自動検出し、互換性のあるCUDAバージョンを提案
- 設定後、コンテナが自動的に開始されます

**日常使用:**
- `./manage.sh` で開始/停止/リビルド/ログ/接続のメニューを提供

## ファイル

- `create.sh` - カラフルなUIを備えたインタラクティブセットアップスクリプト
- `manage.sh` - 開始/停止/リビルド/ログによるコンテナ管理
- `docker-compose.yaml` - 変数置換によるコンテナ設定
- `Dockerfile.gpu` - Python 3.10を備えたCUDA対応Ubuntu 22.04
- `Dockerfile.cpu` - Python 3.10を備えたCPU専用Ubuntu 22.04
- `.env.setup` - 環境変数テンプレート
- `.env` - 生成された設定（create.shによって作成）

## 設定

`.env`の環境変数:
```bash
GPU_NUMBER=0,1     # GPU ID または "all"（CPU専用の場合は "none"）
LIMIT_CPU=4        # CPUコア数
LIMIT_RAM=8G       # メモリ制限（G/M接尾辞必須）
CUDA_VERSION=12.4.0  # DockerイメージのCUDAバージョン
USE_GPU=yes        # GPU加速の "yes" または "no"
DOCKERFILE_NAME=Dockerfile.gpu  # GPU選択に基づいて自動選択
```

## ボリューム

- `./src` → `/app/src` （ソースコード）
- `./cache` → `/app/cache` （MLモデルキャッシュ、pipキャッシュなど）

## 使用方法

1. **初回:** `./create.sh` で設定と開始
2. **日常管理:** `./manage.sh` で操作メニュー
3. **クイック接続:** manage.shのオプション6または `docker exec -it <container-name> bash`
4. **開発:** `./src`のコードがマウントされ、編集可能

**管理操作:**
- 確認付きでコンテナの開始/停止
- フレッシュビルドでリビルド
- リアルタイムログ表示
- CPU/メモリ使用量監視
- 安全なプロジェクト専用クリーンアップ

## 機能

- **スマートCUDAバージョン選択** - NVIDIAドライバを検出し、互換性のあるCUDAバージョンを提案（12.0-12.6）
- 設定可能なデバイス選択によるGPU対応
- リソース制限（CPU/RAM）
- ホストネットワーキングモード
- 永続キャッシュディレクトリ
- 開発用インタラクティブbashシェル