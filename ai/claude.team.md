# CLAUDE.md (Team Version)

> 이 파일은 repo 루트에 git 커밋해서 팀 전체가 공유한다.
> 개인 오버라이드는 `.claude.local.md` (gitignore) 에 작성.
> 규칙이 많을수록 Claude가 무시한다 — 핵심만 유지할 것.

---

## Project Identity

```yaml
project_name:   ""
description:    ""
phase:          ""     # planning | dev | staging | prod
hackathon:      true
team_size:      ""
deadline:       ""
```

---

## Team Conventions (Claude 전원 동일 적용)

### Language
- 설명: 한국어
- 코드 & 주석: English

### API Design
- **REST (JSON)** only
- Response envelope:
  ```json
  { "data": {}, "error": null }
  { "data": null, "error": { "code": "ERR_CODE", "message": "..." } }
  ```
- HTTP status 표준 준수

### Error Handling
```
Go   : fmt.Errorf("%w", err) wrapping, panic 금지
Java : RuntimeException 계열, checked exception 금지
Node : async/await + try/catch, unhandled rejection 금지
```

### Dependency Management
```
Go   : go modules
Java : Gradle
Node : npm
```

### Logging
```
fmt.Println / console.log 수준 (해커톤 — 시간 없음)
```

---

## Domain Ownership

> 도메인 경계 = 팀원 간 작업 분리선.
> 담당 도메인 외 코드는 PR 없이 직접 수정 금지.

```yaml
domains:
  - name:  ""       # e.g. auth
    owner: ""       # e.g. @username
    scope: ""       # e.g. login, logout, token refresh

  - name:  ""
    owner: ""
    scope: ""

  - name:  ""
    owner: ""
    scope: ""
```

**Claude는 현재 작업 도메인 외 파일을 임의로 수정하지 말 것.**

---

## Project Structure

```
repo-root/
├─ CLAUDE.md              ← 이 파일 (팀 공유, git 커밋)
├─ .claude.local.md       ← 개인 오버라이드 (gitignore)
├─ services/
│   ├─ domain-a/          ← Go: cmd/, internal/, pkg/
│   └─ domain-b/          ← Java: controller/service/repository
├─ infra/
│   ├─ docker-compose.yml
│   └─ k8s/
└─ docs/
    ├─ api-spec.md         ← Phase 1에서 팀 전체 확정
    └─ schema.md           ← Phase 1에서 팀 전체 확정
```

---

## Hard Rules

```
NEVER hardcode secrets, .env values, API keys
NEVER push directly to main
NEVER modify another team member's domain without PR
NEVER change api-spec.md or schema.md without team sync
```

---

## Git Workflow

```
Branches : feature/{domain}/{description}
           fix/{domain}/{description}
           chore/{description}

Flow     : branch → implement → PR → review → merge
           main 직접 push: PROHIBITED
```

Commit:
```
feat(auth): add JWT refresh token rotation
fix(user): correct email validation regex
chore: update docker-compose ports
```

---

## Development Flow

**Phase 1 (팀 전체, 구현 전):**
```
1. 전체 API Spec 확정  → docs/api-spec.md
2. 전체 DB 스키마 확정 → docs/schema.md
3. 도메인 소유권 배분
```
→ Phase 1 없이 구현 시작 금지. Claude도 마찬가지.

**Phase 2 (도메인별 병렬):**
```
4. 테스트 먼저 (TDD)
5. 구현
6. PR → 도메인 오너 리뷰
```

**Phase 3 (통합):**
```
7. 엔드포인트 연결
8. E2E 검증
9. 배포
```

---

## Testing

```
Go   : go test ./...  (table-driven)
Java : JUnit 5 + Mockito
Node : Jest / Vitest

해커톤 현실: 최소한 핵심 비즈니스 로직 단위 테스트만이라도
```

---

## Linting (PostToolUse Hook)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "*.go",
        "command": "gofmt -w $CLAUDE_TOOL_FILE && golangci-lint run $CLAUDE_TOOL_FILE"
      }
    ]
  }
}
```

---

## Response Format

```
### Context Check
도메인 + 현재 작업

### Implementation
// [Flow] → [Flow] → [Flow]
코드 (English comments)

### API Spec  ← 신규/변경 시만
- Endpoint / Method:
- Request:
- Response:
- Errors:

### Next Action
다음 작업 + 커밋 제안
```

---

## Build & Run

```yaml
run:   ""     # e.g. docker compose up -d
test:  ""     # e.g. go test ./...
build: ""     # e.g. go build ./cmd/server

ports:
  api:   ""
  db:    ""
  cache: ""
```

---

## What Claude Gets Wrong

- [ ] _(실수 발생 시 팀 전체가 여기 기록)_

---

*Last updated: 2026-05*
