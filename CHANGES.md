# 프론트엔드 변경 사항 정리 (origin/grpark 브랜치 대비)

> 작성일: 2026-05-31

---

## 1. AI 기업 추천 반영 (기업 추천 화면)

### 변경 목적
백엔드에서 Claude AI 기반 기업 추천이 추가되면서,
DB에 없는 AI 추천 기업을 안전하게 렌더링하도록 처리했습니다.

### 변경 내용

**① AI 추천 기업 안전 처리 (`company_screen.dart`)**
- `companyId`가 `null`인 AI 추천 기업 클릭 시 상세화면 이동 차단 (크래시 방지)
- AI 추천 기업에 **보라색 "AI 추천" 배지** 표시
- AI 추천 기업은 "상세보기 >" 텍스트 숨김

```dart
final isAiOnly = companyId == null;

onTap: isAiOnly ? null : () => Navigator.push(...),

if (isAiOnly) Container(
  child: Text('AI 추천', style: TextStyle(color: Colors.purple)),
)
```

**② 기업 상세 화면 개선 (`company_detail_screen.dart`)**
- 로딩/에러 상태 UI 추가
- `careerUrl` 파라미터 추가 (상위에서 전달받아 fallback으로 사용)
- 기업 로고 이미지 표시 연동

### 관련 파일
- `lib/features/company/screens/company_screen.dart`
- `lib/features/company/screens/company_detail_screen.dart`
- `lib/features/company/utils/` ✨ 신규 (로고 유틸)

---

## 2. 뱃지 획득 팝업 (퀘스트 화면)

### 변경 목적
백엔드 퀘스트 완료 응답에 `newBadges` 필드가 추가되면서,
뱃지 획득 시 축하 팝업을 보여주도록 구현했습니다.

### 변경 내용

**퀘스트 완료 흐름 변경 (`home_screen.dart`)**
- 기존: 퀘스트 완료 → 스낵바 표시
- 변경: 뱃지 획득 시 → **뱃지 획득 팝업 다이얼로그** 표시 / 없으면 기존 스낵바

**`_BadgeAwardDialog` 위젯 추가 (`home_screen.dart`)**
- 획득한 뱃지 목록, 이모지, 이름, 획득 XP 표시
- 확인 버튼으로 닫기

**`completeQuest()` 반환값 변경 (`home_provider.dart`)**
- `Future<void>` → `Future<List<String>>` (획득 뱃지 이름 목록 반환)
- 뱃지 획득 시 `badgesProvider` 자동 갱신

**`updateQuestStatus()` 반환값 변경 (`home_repository.dart`)**
- `Future<void>` → `Future<List<String>>`
- 응답의 `newBadges` 필드 파싱하여 반환

### 관련 파일
- `lib/features/home/screens/home_screen.dart`
- `lib/features/home/providers/home_provider.dart`
- `lib/features/home/repositories/home_repository.dart`

---

## 3. 뱃지 컬렉션 화면 개선 (업적 화면)

### 변경 목적
뱃지 API 응답 구조 변경에 맞춰 뱃지 목록을 올바르게 파싱하고,
전체 뱃지(잠금 포함)를 시각적으로 표시하도록 개선했습니다.

### 변경 내용

**`achievement_screen.dart`**
- `ConsumerWidget` → `ConsumerStatefulWidget` 변경
  - `initState`에서 화면 진입 시마다 뱃지 목록 자동 새로고침
- 뱃지 목록 파싱 수정: `data['badges']` 배열을 올바르게 추출
- **획득한 뱃지 → 이모지 표시 / 미획득 뱃지 → 🔒 표시**
- 획득/전체 카운트 표시 (`N / 11개 획득`)
- 획득 뱃지 먼저, 미획득 뱃지 뒤에 정렬
- 뱃지 이름에서 이모지 자동 추출 (첫 글자)
- 뱃지 터치 시 툴팁으로 설명 표시

**`profile_repository.dart`**
- `fetchBadges()` 응답 파싱 수정
  - 기존: `response.data['data']` 전체를 리스트로 사용 (오류)
  - 변경: `response.data['data']['badges']` 배열 추출

### 관련 파일
- `lib/features/profile/screens/achievement_screen.dart`
- `lib/features/profile/repositories/profile_repository.dart`

---

## 4. 일정 화면 개선 (일정 화면)

### 변경 목적
서류 카테고리만 저장 가능하던 문제 수정 및 D-day 표시 오류 수정.

### 변경 내용

**카테고리 전체 저장 가능 (`schedule_screen.dart`)**
- 기존: `document`가 아니면 저장 차단하는 코드 존재
- 변경: 차단 코드 제거 → 면접/시험/기타 모두 저장 가능

**D-day 표시 수정 (`schedule_screen.dart`)**
- 기존: `'D-${event['dDay']}'` 문자열 직접 조합 → null이면 `D-?` 표시
- 변경: `_formatDDay()` 함수로 처리
  - `0` → `D-Day`
  - 양수 → `D-N`
  - 음수(지난 일정) → `종료`
  - null → `D-?`

**타입 한글 변환 (`schedule_screen.dart`)**
- 기존: `document`, `interview` 영문 그대로 표시
- 변경: `_typeToKorean()` 함수로 한글 변환
  - `document` → `서류`
  - `interview` → `면접`
  - `exam` → `시험`
  - `etc` → `기타`

**API 파싱 수정 (`schedule_repository.dart`)**
- 백엔드 응답 `dday`(소문자) → `dDay`(camelCase) 필드명 불일치 대응
- `event['dday'] ?? event['dDay']` 순서로 fallback 처리

### 관련 파일
- `lib/features/schedule/screens/schedule_screen.dart`
- `lib/features/schedule/repositories/schedule_repository.dart`

---

## 5. 패키지 추가 (pubspec.yaml)

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `characters` | ^1.3.0 | 이모지 포함 문자열에서 첫 글자(문자소) 안전하게 추출 |
