<div align="center">

<img src="assets/icon/app_icon.png" width="110" alt="TrailTrack icon"/>

# TrailTrack

**산과 도시를 잇는 3D 운동 기록 앱** — Flutter × CesiumJS

GPS로 걷기·달리기·등산·트레일러닝·자전거를 기록하고,
DEM 지형이 살아있는 3D 지도 위에서 나의 경로를 다시 달려보세요.

[![Flutter](https://img.shields.io/badge/Flutter-3.44+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![CesiumJS](https://img.shields.io/badge/CesiumJS-1.143-48b284)](https://cesium.com/platform/cesiumjs/)
[![Platform](https://img.shields.io/badge/Platform-Android%208%2B-3DDC84?logo=android&logoColor=white)](#)
[![Tests](https://img.shields.io/badge/tests-79%20passing-brightgreen)](#-검증)

</div>

---

## ✨ 무엇이 특별한가

대부분의 운동 앱은 평평한 2D 지도에 선을 긋습니다. TrailTrack은 **CesiumJS + Cesium World Terrain(DEM)** 위에 경로를 그립니다 — 산의 능선, 계곡의 깊이가 그대로 보이는 3D 지형 위에서, 방금 오른 등산로를 20배속으로 다시 내려다볼 수 있습니다.

| | |
|---|---|
| 🛰️ **정밀 GPS 기록** | 운동 유형별 필터 프로파일(속도 상한·정확도·샘플링)로 GPS 튐을 걸러낸 깨끗한 경로. 화면을 꺼도 포그라운드 서비스가 기록을 지속 |
| 🗺️ **3D 지형 지도** | 2D/3D 전환, 위성·일반 지도, 경로선·마커가 지형 표면에 밀착(terrain-draped). 토큰 없이는 오프라인 이미지로 자동 폴백 |
| ▶️ **3D 경로 리플레이** | 기록한 경로를 지형 위에서 애니메이션 재생. 5·10·20배속, 카메라 팔로우 |
| 📊 **통계 & 차트** | 거리·시간·페이스·속도·고도·누적상승 + **칼로리**(유형별 MET × 몸무게 × 시간, 속도 보정). 거리-고도/시간-속도 차트와 단위 포함 터치 툴팁 |
| 📸 **지오태그 사진** | 기록 중 촬영 → GPS 위치 자동 매칭 → 지도 마커 + 근접 클러스터링(개수 배지). 기기 갤러리 동시 저장, 사진별 메모 |
| ☁️ **Google Drive 백업** | 전체/경량(사진 제외) 백업, 스트리밍 ZIP(대용량도 메모리 안전), 병합/교체 복원, 보관 개수 관리. `drive.file` 최소 권한 — 앱이 만든 파일만 접근 |
| 🛟 **크래시 복구** | 앱이 죽어도 기록은 남습니다. 재실행 시 이어하기 / 저장 / 삭제 선택 |

## 🏗️ 기술 스택

| 영역 | 선택 |
|------|------|
| 프레임워크 | Flutter (stable 3.44+) / Dart 3.12 |
| 상태 관리 | Riverpod (`flutter_riverpod` 3.x) |
| 라우팅 | `go_router` |
| 로컬 DB | Drift + SQLite (버전 마이그레이션 포함) |
| 지도 | CesiumJS 1.143 (vendored, 오프라인 동작) in `flutter_inappwebview` |
| 위치 | `geolocator` — 자체 포그라운드 서비스로 화면 꺼짐 기록 |
| 카메라 | `camera` + `image` (썸네일) · `gal` (기기 갤러리 내보내기) |
| 차트 | `fl_chart` |
| 백업 | Google Drive API v3 (`googleapis`, `google_sign_in` 7.x), 스트리밍 ZIP (`archive`) |
| 설정 | `flutter_dotenv` (`.env`), UUID 식별자 |

### Flutter ↔ CesiumJS 브릿지

지도는 WebView 안의 CesiumJS가 그리고, Flutter와는 **JSON 메시지 브릿지**로만 대화합니다. 렌더링은 `requestRenderMode`(변경 시에만 프레임)로 절전하고, 경로·마커는 DEM 높이를 샘플링해 지형 표면에 얹습니다.

```
Flutter (Dart)                        WebView (CesiumJS)
┌──────────────────┐  SET_TRACK_POINTS  ┌───────────────────┐
│ RecordingScreen  │ ─────────────────▶ │ map-controller.js │
│ DetailScreen     │  APPEND / REPLAY   │ route-player.js   │
│ CesiumMapCtrl    │ ◀───────────────── │ photo-markers.js  │
└──────────────────┘  MAP_READY / PICK  └───────────────────┘
```

전체 메시지 계약은 [`docs/CESIUM_BRIDGE.md`](docs/CESIUM_BRIDGE.md) 참고.

## 🚀 시작하기

### 사전 요구사항

- Flutter stable 3.44+ (Android 툴체인 포함)
- Android 8.0+ (minSdk 26) 기기 또는 에뮬레이터

> **AGP 버전 주의** — 프로젝트는 **AGP 8.7.3 + Gradle 8.11.1 + Kotlin 2.1.0**에 고정되어 있습니다. AGP 9.x는 `getDefaultProguardFile('proguard-android.txt')` 지원을 제거했는데 현 stable `flutter_inappwebview`가 이를 사용합니다.

### 1. 패키지 설치 & 시크릿 설정

```bash
flutter pub get
cp .env.example .env   # CESIUM_ION_TOKEN 등을 채워 넣기
```

`.env`는 git-ignore되며 런타임에 번들 에셋으로 로드됩니다. 토큰이 없어도 앱은 부팅됩니다 — 지형/위성 이미지가 오프라인 기본 레이어로 대체될 뿐입니다.

### 2. Cesium ion 토큰 (3D 지형용)

1. <https://ion.cesium.com/> 무료 가입
2. **Access Tokens**에서 토큰 복사 (*Cesium World Terrain*, *Bing Maps Aerial* 에셋 활성)
3. `.env`에 `CESIUM_ION_TOKEN=...` 입력

### 3. CesiumJS 런타임 vendoring (필수, 1회)

CDN 의존 없이 완전 오프라인으로 동작하도록 CesiumJS 빌드(~23 MB)를 로컬에 vendoring합니다. **git에는 포함되지 않으므로** 클론 후 반드시 실행하세요:

```bash
curl -L -o cesium.tgz https://registry.npmjs.org/cesium/-/cesium-1.143.0.tgz
mkdir -p assets/cesium/cesium
tar --force-local -xzf cesium.tgz -C assets/cesium/cesium \
    --strip-components=3 package/Build/Cesium

# pubspec.yaml의 에셋 디렉터리 목록 동기화 확인
dart run tool/gen_cesium_assets.dart --check
```

> Flutter는 에셋 하위 폴더를 재귀 포함하지 않아 모든 Cesium 폴더가 `pubspec.yaml`에 명시됩니다. 생성기가 그 목록을 검증/재생성합니다.

### 4. Google Drive 백업 (선택)

Google Cloud Console에서 OAuth 클라이언트(Android + Web) 2개를 만들고 Web 클라이언트 ID를 `.env`의 `GOOGLE_DRIVE_SERVER_CLIENT_ID`에 넣습니다. 단계별 가이드: [`GOOGLE_DRIVE_BACKUP.md`](GOOGLE_DRIVE_BACKUP.md)

### 5. 빌드 & 실행

```bash
flutter run                     # 디버그 실행
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

## ✅ 검증

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze                 # 0 issues
flutter test                    # 79 tests passing
```

단위 테스트(통계·칼로리·GPS 검증·포맷터), 통합 테스트(DB·백업 라운드트립·기록 컨트롤러), 위젯 스모크 테스트를 포함합니다. 실기기 전용 동작(실제 GPS, 화면 꺼짐 기록, 카메라, Drive 실연동)은 [`TEST_PLAN.md`](TEST_PLAN.md)의 온디바이스 체크리스트로 확인합니다.

## 📚 문서

| 문서 | 내용 |
|------|------|
| [`ARCHITECTURE.md`](ARCHITECTURE.md) | 모듈 경계, 데이터 흐름, GPS/기록 파이프라인 |
| [`DATABASE.md`](DATABASE.md) | Drift 스키마, 인덱스, 마이그레이션 |
| [`docs/CESIUM_BRIDGE.md`](docs/CESIUM_BRIDGE.md) | Flutter ↔ CesiumJS JSON 메시지 계약 |
| [`GOOGLE_DRIVE_BACKUP.md`](GOOGLE_DRIVE_BACKUP.md) | 백업 ZIP 포맷, OAuth 설정, 복원 모드 |
| [`TEST_PLAN.md`](TEST_PLAN.md) | 자동 + 온디바이스 수동 테스트 절차 |
| [`ROADMAP.md`](ROADMAP.md) | 마일스톤과 명시적으로 미룬(post-MVP) 기능 |

## 📄 라이선스

CesiumJS는 Apache-2.0 라이선스입니다(vendored 디렉터리 참조). 애플리케이션 코드는 MVP 기준 as-is로 제공됩니다.
