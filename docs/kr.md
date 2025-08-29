# Docker 개발 워크스페이스

CUDA 지원, 구성 가능한 리소스, 대화형 설정을 갖춘 컨테이너화된 개발 환경입니다.

## 빠른 시작

```bash
./create.sh   # 초기 설정 및 시작
./manage.sh   # 실행 중인 컨테이너 관리
```

**첫 설정:**
- `./create.sh`로 컨테이너 이름, CPU/RAM 제한, CUDA 버전, GPU 선택 가이드
- NVIDIA 드라이버를 자동 감지하고 호환되는 CUDA 버전 제안
- 구성 후 컨테이너가 자동으로 시작됩니다

**일상 사용:**
- `./manage.sh`로 시작/중지/재빌드/로그/연결 메뉴 제공

## 파일

- `create.sh` - 컬러풀한 UI를 갖춘 대화형 설정 스크립트
- `manage.sh` - 시작/중지/재빌드/로그로 컨테이너 관리
- `docker-compose.yaml` - 변수 치환을 통한 컨테이너 구성
- `Dockerfile.gpu` - Python 3.10이 포함된 CUDA 지원 Ubuntu 22.04
- `Dockerfile.cpu` - Python 3.10이 포함된 CPU 전용 Ubuntu 22.04
- `.env.setup` - 환경 변수 템플릿
- `.env` - 생성된 구성 (create.sh에 의해 생성)

## 구성

`.env`의 환경 변수:
```bash
GPU_NUMBER=0,1     # GPU ID 또는 "all" (CPU 전용의 경우 "none")
LIMIT_CPU=4        # CPU 코어 수
LIMIT_RAM=8G       # 메모리 제한 (G/M 접미사 필요)
CUDA_VERSION=12.4.0  # Docker 이미지의 CUDA 버전
USE_GPU=yes        # GPU 가속을 위한 "yes" 또는 "no"
DOCKERFILE_NAME=Dockerfile.gpu  # GPU 선택에 따라 자동 선택
```

## 볼륨

- `./src` → `/app/src` (소스 코드)
- `./cache` → `/app/cache` (ML 모델 캐시, pip 캐시 등)

## 사용법

1. **첫 번째:** `./create.sh`로 구성 및 시작
2. **일상 관리:** `./manage.sh`로 작업 메뉴
3. **빠른 연결:** manage.sh의 옵션 6 또는 `docker exec -it <container-name> bash`
4. **개발:** `./src`의 코드가 마운트되어 편집 가능

**관리 작업:**
- 확인과 함께 컨테이너 시작/중지
- 새로운 빌드로 재빌드
- 실시간 로그 보기
- CPU/메모리 사용량 모니터링
- 안전한 프로젝트 전용 정리

## 기능

- **스마트 CUDA 버전 선택** - NVIDIA 드라이버를 감지하고 호환되는 CUDA 버전 제안 (12.0-12.6)
- 구성 가능한 장치 선택으로 GPU 지원
- 리소스 제한 (CPU/RAM)
- 호스트 네트워킹 모드
- 지속적인 캐시 디렉토리
- 개발용 대화형 bash 셸