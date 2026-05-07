# CLAUDE.md (Project)

> 이 파일은 프로젝트 루트에 위치한다.
> ~/.claude/CLAUDE.md (전역 규칙) 와 함께 자동 로드된다.
> 전역 규칙은 여기서 반복하지 않는다 — 여기엔 프로젝트 특화 내용만.

---

## Project Context

```yaml
project_name:   youth-policy
description:    대한민국 청년 정책 정리 및 검색 서비스
phase:          dev
primary_lang:   go
branch_current: feature/auth-login
```

---

## Stack

```
Framework  : Gin (github.com/gin-gonic/gin)
Auth       : golang-jwt/jwt v5
Migration  : golang-migrate
ORM        : database/sql + pgx (raw query 기반)
```

---

## Build & Run

```yaml
run:   docker compose up -d
test:  go test ./...
lint:  golangci-lint run ./...
build: go build ./cmd/server

ports:
  api:   8080
  db:    5432
  cache: 6379
```

---

## Project Structure

```
youth-policy/
├─ cmd/
│   ├─ server/main.go        # API 서버 엔트리포인트
│   └─ crawler/main.go       # 크롤러 (1회성 실행)
├─ internal/
│   ├─ auth/
│   │   ├─ handler.go
│   │   ├─ service.go
│   │   └─ repository.go
│   ├─ policy/
│   │   ├─ handler.go
│   │   ├─ service.go
│   │   └─ repository.go
│   ├─ bookmark/
│   │   ├─ handler.go
│   │   ├─ service.go
│   │   └─ repository.go
│   ├─ category/
│   │   ├─ handler.go
│   │   └─ repository.go
│   ├─ middleware/
│   │   └─ auth.go           # JWT 검증 미들웨어
│   └─ db/
│       └─ postgres.go
├─ migrations/
├─ docs/
│   ├─ api-spec.md           # 확정된 API 명세 (수정 신중하게)
│   └─ schema.md             # 확정된 DB 스키마 (수정 신중하게)
├─ docker-compose.yml
├─ Dockerfile
└─ CLAUDE.md                 # 이 파일
```

---

## Domain 구현 순서

```
1. ✅ skeleton      main.go, router, DB 연결, 미들웨어 구조
2. ✅ docker        docker-compose (postgres + redis + app)
3. ✅ migration     스키마 생성
4. ✅ category      GET /categories
5. 🔄 auth          register → login → refresh → me  ← 현재 작업
6. ⬜ policy        GET /policies, GET /policies/:id
7. ⬜ bookmark      POST/DELETE/GET /bookmarks
8. ⬜ crawler       데모 전날 데이터 투입
```

> 상태: ✅ 완료 / 🔄 진행중 / ⬜ 미시작
> 세션 시작 시 현재 도메인과 상태 업데이트할 것

---

## DB Schema 요약

```
categories  id, name, slug
policies    id, title, description, target, benefit,
            deadline, category_id, source_url, source_name,
            is_active, crawled_at, created_at
users       id, email, password_hash, name, birth_year,
            region, created_at
bookmarks   id, user_id, policy_id, created_at
            UNIQUE (user_id, policy_id)
```

전체 스키마 → docs/schema.md
전체 API    → docs/api-spec.md

---

## 주요 결정 사항 (변경 시 팀 싱크 필요)

```
검색     ILIKE '%keyword%' on title + description (형태소 X)
태그     MVP 제외
어드민   없음 — 정책 데이터는 크롤러로만 투입
크롤러   실시간 X, 데모 전날 1회 실행
인프라   Docker Compose 단일 서버 (K8s 없음)
```

---

## 현재 세션 작업

```
도메인  : auth
단계    : Step 5 구현 중
브랜치  : feature/auth-login
다음    : POST /auth/register 테스트 통과 후 login으로
```

> 세션 시작할 때 이 블록 업데이트해서 붙여넣기
