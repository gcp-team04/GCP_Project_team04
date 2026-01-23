# 이미지 업로드 및 Firestore 저장 로직 수정 결과

사용자의 요청에 따라 Firebase Storage 이미지 네이밍 규칙을 수정하고 Firestore 데이터 저장 구조를 개선했습니다.

## 주요 변경 사항

### 1. Firebase Storage 이미지 네이밍 규칙 수정
- **기존**: `uid_날짜_번호_타임스탬프.jpg`
- **변경**: `uid_날짜_번호.jpg` (타임스탬프 제거)

### 2. Firestore 저장 로직 구조 변경
- **조건부 저장**: `users/{uid}` 문서가 이미 존재하는 경우에만 데이터를 저장합니다.
- **서브컬렉션 활용**: `users/{uid}/estimate_history` 서브컬렉션에 문서를 추가합니다.
- **문서 ID**: 이미지 파일명(`uid_날짜_번호.jpg`)과 동일한 ID를 사용하여 매칭이 용이하도록 했습니다.
- **데이터 필드 보강**:
    - `imageUploadUrl`: 업로드된 실제 이미지 다운로드 URL을 저장합니다.
    - `status`: `'pending'` 상태를 추가하여 처리 과정을 추적할 수 있도록 했습니다.

## 코드 변경 내역
render_diffs(file:///c:/Users/joo1m/flutter_projects/GCP_Project_team04/lib/services/storage_service.dart)

## 확인 방법
- 앱에서 사진을 업로드한 후 Firebase Console의 Storage에서 파일명이 `uid_날짜_번호.jpg` 인지 확인하세요.
- Firestore의 `users` 컬렉션 내 해당 유저 문서 아래에 `estimate_history` 서브컬렉션과 데이터가 생성되었는지 확인하세요.
