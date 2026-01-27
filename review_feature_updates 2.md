# 리뷰 기능 및 Firestore 로직 수정 사항 (2026-01-26)

## 1. Firestore 트랜잭션 오류 수정
- **파일**: `lib/screens/write_review_screen.dart`
- **문제**: Firestore 트랜잭션 내에서 읽기(`get`) 작업보다 쓰기(`set`) 작업이 먼저 수행되어 `invalid-transaction` 오류가 발생함.
- **수정**: 트랜잭션의 순서를 **읽기 우선(Read-before-Write)** 원칙에 따라 정비소 정보를 먼저 읽어온 후 리뷰 데이터를 쓰도록 수정하였습니다.

## 2. 정비소 별점 기본값 변경
- **파일**: 
  - `lib/models/service_center.dart`
  - `lib/screens/write_review_screen.dart`
- **문제**: 리뷰 데이터가 없는 정비소에도 기본적으로 `4.5`점이 표시되어 실제 데이터를 확인하기 어려움.
- **수정**: 기본 별점(Default Rating) 정보를 `4.5`에서 `0.0`으로 변경하여 데이터가 없는 상태임을 명확히 표시하도록 개선하였습니다.

## 3. 리뷰 데이터 저장 방식 최적화
- **파일**: `lib/screens/write_review_screen.dart`
- **내용**: 
  - 사용자가 동일한 정비소를 여러 번 방문할 수 있음을 고려하여, 한 개인이 여러 개의 리뷰를 달 수 있도록 **자동 생성 문서 ID**를 사용하도록 변경했습니다.
  - 대신, 추후 관리를 위해 리뷰 문서의 필드 내에 사용자의 UID(`userId`)를 포함하도록 수정하였습니다.
  - **Firestore 경로**: `service_centers / {shopId} / reviews / {auto_generated_id}`

## 4. 리뷰 시 별점 및 개수 동기화
- **파일**: `lib/screens/write_review_screen.dart`
- **내용**: 트랜잭션 내에서 새로운 리뷰가 등록될 때마다 해당 정비소 문서의 전체 평균 별점(`rating`)과 리뷰 개수(`reviewCount`)가 실시간으로 계산되어 업데이트되도록 로직을 보강하였습니다.
