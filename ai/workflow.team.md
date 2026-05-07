# workflow.team.md

> 해커톤 / 팀 프로젝트 개발 워크플로우
> CLAUDE.team.md 와 함께 사용
> 시간이 없다 — 설계에 30%, 구현에 70%

---

## D-1 또는 시작 직후 — 팀 세팅 (1~2시간)

### Step 1. repo 세팅
```
[팀장] GitHub repo 생성
       CLAUDE.team.md → repo 루트에 커밋
       .gitignore에 .claude.local.md 추가
       branch protection: main 직접 push 금지

[팀원 전체] clone + 각자 환경 세팅
            cp .claude.local.md.example .claude.local.md
            (개인 IDE, 단축키, 선호 설정 등)
```

### Step 2. 도메인 소유권 배분
```
[팀 전체] 화이트보드 or 문서로 도메인 나누기
          Auth    → @팀원A
          User    → @팀원B
          Post    → @팀원C
          Infra   → @팀원D  (가장 인프라 잘 아는 사람)

[팀장] CLAUDE.team.md의 Domain Ownership 섹션 채우기
       커밋: chore: assign domain ownership
```

---

## Phase 1 — 설계 (팀 전체, 1~2시간 안에 끝냄)

> 이 단계 없이 구현 시작하면 나중에 스키마 충돌로 다 날린다.

### Step 3. 전체 API Spec 확정
```
[팀 전체 + Claude] 한 자리에서 (or 공유 화면)

[팀장] Claude에게: "우리 서비스 기능 목록이야. 전체 API Spec 잡아줘"

[Claude] 전체 엔드포인트 초안 제안

[팀 전체] 리뷰, 수정, 확정
          → docs/api-spec.md 커밋
          feat(docs): add initial API spec
```

### Step 4. DB 스키마 확정
```
[팀 전체 + Claude] API Spec 기반으로 스키마 설계

[Claude] 테이블 구조 제안

[팀 전체] 리뷰, 수정, 확정  ← 여기서 이견 있으면 반드시 해결
          → docs/schema.md 커밋
          → migration 파일 초안 생성
          feat(docs): add DB schema and initial migration
```

> Phase 1 완료 선언 후 병렬 구현 시작
> 이후 api-spec.md / schema.md 변경은 팀 동의 필수

---

## Phase 2 — 병렬 구현 (도메인별 독립)

### Step 5. 각자 브랜치 생성
```
[팀원 각자]
git checkout -b feature/{domain}/initial-setup

각자의 Claude Code 세션 시작:
  tmux new-session -s {domain}
  claude
  → CLAUDE.team.md + 본인 도메인 컨텍스트 붙여넣기
```

### Step 6. 도메인 구현 (각자 진행)
```
[팀원 각자 + 각자의 Claude]

1. 테스트 먼저 작성 (TDD)
2. 구현
3. lint 자동 실행 (PostToolUse hook)
4. 커밋

커밋 단위: 기능 하나 완성될 때마다
feat(auth): add login endpoint
feat(auth): add JWT refresh rotation
fix(auth): correct token expiry handling
```

### Step 7. 진행상황 공유 (30분~1시간 주기)
```
[팀 전체] 짧게 싱크
  - 각 도메인 진행률
  - 스키마 변경 필요 여부  ← 생기면 팀 전체 합의 후 처리
  - 블로커 공유
```

### Step 8. PR & 리뷰
```
[팀원] 도메인 기능 완성 시 PR 생성
       제목: feat(auth): implement login/logout/refresh

[도메인 오너 or 팀장] 리뷰
  Claude 활용:
  "이 PR 코드 리뷰해줘. CLAUDE.team.md 컨벤션 기준으로"

[팀원] 수정 → merge
```

---

## Phase 3 — 통합 (마감 2~3시간 전)

### Step 9. 통합 브랜치 생성
```
[팀장]
git checkout -b feature/integration
각 도메인 브랜치 merge
```

### Step 10. 연결 & 충돌 해결
```
[팀장 + Claude] 라우터, 미들웨어 통합
               도메인 간 의존성 연결

[팀 전체] 충돌 해결 (스키마 충돌이 가장 흔함)
```

### Step 11. E2E 검증
```
[팀 전체]
docker compose up -d
주요 플로우 수동 테스트:
  - 회원가입 → 로그인 → 핵심 기능 → 로그아웃

Claude 활용: "이 에러 원인 찾아줘" (디버깅)
```

### Step 12. 배포 & 발표 준비
```
[인프라 담당] 배포 처리 (Claude 맡기지 않음)
[팀 전체] 발표 자료, 데모 시나리오 준비
```

---

## 팀 Claude 사용 규칙

```
각자의 Claude는 각자의 도메인에서만 작업
타 도메인 파일 수정 필요 시 → 해당 팀원에게 먼저 얘기
공통 파일(main, config, docker-compose) 수정 → 팀 싱크 후

충돌 방지:
  같은 파일 동시 수정 금지
  schema.md, api-spec.md는 팀장만 수정
```

---

## 파일 위치 정리

```
repo-root/
├─ CLAUDE.md              ← CLAUDE.team.md 내용 (팀 공유)
├─ .claude.local.md       ← 개인 설정 (gitignore)
├─ docs/
│   ├─ api-spec.md        ← Phase 1 산출물 (불변)
│   └─ schema.md          ← Phase 1 산출물 (불변)
└─ services/
    ├─ auth/              ← @팀원A
    ├─ user/              ← @팀원B
    └─ post/              ← @팀원C
```

---

## 해커톤 현실 체크

```
시간 없으면 이것만 지키자:
  ✅ Phase 1 (설계) 반드시 끝내고 구현 시작
  ✅ 도메인 소유권 명확히
  ✅ main 직접 push 금지
  ✅ secrets 코드에 박지 말기

이건 포기해도 됨:
  ❌ 풀 TDD (핵심 로직만)
  ❌ 완벽한 에러 핸들링
  ❌ 100% lint 통과
```
