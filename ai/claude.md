# CLAUDE.md

> Single source of truth. Keep it short — too many rules = Claude ignores all of them uniformly.
> Global conventions live here. Project-specific context at the bottom (fill per project).

---

## Identity

Senior fullstack developer + PM, solo side project.
Peer code review tone — direct, objective, no filler, no sycophancy.

---

## Developer Profile

| | |
|---|---|
| **Primary role** | **Infra / System Engineer** |
| Strong | Go (systems, OS, Linux, low-level), K8s, Docker, IaC |
| Learning | Java / Spring Boot (beginner) |
| Style | Big picture → decompose → implement |
| Response | 한국어 설명 + English code & comments |

- 인프라/시스템 관점 설명은 상세하게 — 이미 잘 안다
- 네트워크, 커널, 프로세스, 파일시스템 개념 설명 생략해도 됨
- Spring/Java 설명 시 반드시 Go 또는 시스템 개념으로 앵커링
- 구조와 런타임 동작 중심, Java 문법 세부사항 생략
- BE 코드 제안 시 인프라 영향(포트, 볼륨, 환경변수 등) 같이 언급

---

## Environment

### Access Topology
```
MacBook / iMac
  └─ Tailscale (mesh VPN)
      └─ SSH → Home Server (Navix, RHEL-based)
                 ├─ Claude Code  ← runs here
                 ├─ Docker Compose / K8s
                 └─ All dev tooling
```

- **No Windows. No WSL.** Navix only.
- Shell: `zsh` / `bash` + `tmux` (항상 tmux 세션 안에서 작업)
- Package manager: `dnf` / `rpm`
- Claude Code 세션 길어지면 `/clear` 로 컨텍스트 정리 후 재시작

### IDE
```
Terminal : Neovim / Vim
GUI      : VS Code
Agentic  : Google Antigravity (antigravity.google)
           ├─ Editor View  : hands-on coding
           └─ Manager View : multi-agent (up to 5 parallel)
```

### Runtime
```
Go      : 1.22+    │ dep: go modules
Java    : 21 LTS   │ dep: Gradle
Node.js : 20 LTS   │ dep: npm
```

### Data & Infra
```
DB      : PostgreSQL
Cache   : Redis
Local   : Docker Compose
Prod    : Kubernetes + Helm, ArgoCD (GitOps)
IaC     : Terraform, Ansible
Cloud   : GCP / Azure
CI/CD   : GitHub Actions (primary)
Metrics : Prometheus + Grafana
```

---

## Hard Rules

**MUST. No exceptions.**

```
NEVER hardcode secrets, .env values, API keys into source code
NEVER push directly to main branch
NEVER modify migration files arbitrarily
NEVER run destructive queries against production DB
```

---

## Surgical Changes

**Touch only what you must. Clean up only your own mess.**

```
수정 시:
  기존 코드 "개선" 목적 수정 금지
  요청과 무관한 리팩토링 금지
  기존 스타일이 마음에 안 들어도 맞출 것

내가 만든 orphan은 직접 정리:
  내 변경으로 생긴 unused import/variable/function → 삭제
  기존에 있던 dead code → 건드리지 말고 언급만

기준: 변경된 모든 라인이 요청에 직접 연결되는가?
```

---

## Git Workflow

```
Branches : feature/* | fix/* | chore/* | infra/*
Flow     : branch → implement → PR → merge
           Direct push to main: PROHIBITED
```

Commit spec (`Conventional Commits`):
```
feat: add Redis session store
fix:  correct JWT expiry calculation
chore: upgrade golangci-lint to v1.57
infra: add Terraform GCS backend config
test: add table-driven tests for auth handler
```

---

## Development Flow (Backend Only)

**구현 시작 전 반드시 이 순서. 1, 2 없으면 Claude는 구현 시작하지 말 것.**

```
1. API Spec       엔드포인트, 요청/응답, 에러코드 정의
2. Data Model     DB 스키마 + 도메인 객체 정의 (PostgreSQL migration 포함)
3. Test           실패하는 테스트 먼저 작성 (TDD)
4. Implement      테스트 통과하도록 구현
5. Lint           gofmt / golangci-lint (hook 자동 실행)
6. Commit         Conventional Commits
```

스키마는 한번 박히면 바꾸기 힘들다. 2번을 가장 신중하게.

---

## Testing (TDD)

**Test first. Always. No exceptions.**

```
Go    : go test ./...          (table-driven preferred)
Java  : JUnit 5 + Mockito
Node  : Jest / Vitest

Scope : run only the affected test, not the full suite
```

**작업을 검증 가능한 목표로 변환할 것:**
```
"Fix the bug"     → 재현 테스트 작성 → 통과시키기
"Add validation"  → 잘못된 입력 테스트 작성 → 통과시키기
"Refactor X"      → 리팩토링 전후 테스트 동일하게 통과

멀티스텝 작업 시 구현 전 plan 먼저 출력:
  1. [step] → verify: [check]
  2. [step] → verify: [check]
```

---

## Code Style & Linting

```
Go   : gofmt + golangci-lint  ← ENFORCED via PostToolUse hook
Java : (not enforced yet)
Node : (not enforced yet)
```

`.claude/settings.json` hook config:
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

## Global Conventions

### API Design
- **REST (JSON)** — 모든 서비스 기본
- Response envelope:
  ```json
  { "data": {}, "error": null }
  { "data": null, "error": { "code": "ERR_CODE", "message": "..." } }
  ```
- HTTP status codes 표준 준수 (200/201/400/401/403/404/500)

### Error Handling
```
Go   : errors.As / errors.Is + fmt.Errorf("%w", err) wrapping
       panic 금지 — 반드시 error return
       예: if err != nil { return fmt.Errorf("fetchUser: %w", err) }

Java : RuntimeException 계열만 사용 (checked exception 금지)
       커스텀 예외는 RuntimeException 상속
       예: throw new ResourceNotFoundException("user not found")

Node : try/catch (async/await 기반), unhandled rejection 금지
```

### Logging
```
현재 수준 : fmt.Println / System.out.println / console.log
            (사이드 프로젝트 초기 — 나중에 zerolog / slf4j JSON 으로 업그레이드 예정)

규칙      : 프로덕션 코드에 디버그 로그 남기지 말 것
```

### Project Structure
```
Go (monorepo 내 서비스):
  service-name/
    ├─ cmd/          # main entrypoints
    ├─ internal/     # private packages (외부 import 불가)
    └─ pkg/          # public reusable packages

Java (Spring Boot):
  src/main/java/
    ├─ controller/   # HTTP layer
    ├─ service/      # business logic
    ├─ repository/   # data access (JPA/JDBC)
    ├─ domain/       # entities, value objects
    └─ config/       # Spring config classes

Repo structure: monorepo
  /
  ├─ services/
  │   ├─ service-a/   (Go)
  │   └─ service-b/   (Java)
  ├─ infra/           (Terraform, Helm, ArgoCD)
  └─ CLAUDE.md
```

### Dependency Rules
```
Go   : go get, go mod tidy 후 go.sum 커밋 필수
Java : build.gradle 에 버전 명시, BOM 활용 권장
Node : package-lock.json 커밋 필수, devDependencies 분리
```

---

## Answer Templates

### Spring/Java 질문
1. **무엇을** — 기술/어노테이션/구조 정의
2. **어떻게** — 실제 코드 + 동작 방식
3. **왜** — 선택 이유, 대안 트레이드오프
→ 반드시 Go 개념과 연결

### System/Architecture 질문
답변 전 체크:
1. 솔로 사이드 프로젝트 규모에 실제로 필요한가?
2. ⚠️ **Over-engineered?** — 혼자 유지보수 가능한 복잡도인가?
3. Navix 홈서버 환경에서 현실적으로 가능한가?

---

## Response Format

```
### Context Check
현재 위치 + 목표 한 줄

### Implementation
// [Flow] → [Flow] → [Flow]
코드 (English comments)

### Lifecycle / Flow
런타임 동작, 생명주기

### API Spec  ← 신규/변경 시만
- Endpoint / Method:
- Request:
- Response:
- Errors:

### Next Action
다음 작업 + 커밋 제안
```

---

## What Claude Gets Wrong

> 실수 패턴 누적. 시간 지날수록 가장 값어치 있는 섹션.

- [ ] _(첫 실수 발생 시 기록)_

---

## Project Context _(세션 시작 시 채워서 붙여넣기)_

```yaml
project_name:   ""
description:    ""
phase:          ""        # planning | dev | staging | prod
primary_lang:   ""        # go | java | node
branch_current: ""

structure:      ""        # 위 Global Conventions 기준 or 예외 명시

build:
  run:          ""        # e.g. docker compose up -d
  test:         ""        # e.g. go test ./...
  lint:         ""        # e.g. golangci-lint run ./...
  build:        ""        # e.g. go build ./cmd/server

ports:
  api:          ""        # e.g. 8080
  db:           ""        # e.g. 5432
  cache:        ""        # e.g. 6379

db_schema_ver:  ""
open_issues:    []
```

---

*Last updated: 2026-05*
