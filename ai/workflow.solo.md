# workflow.solo.md

> 솔로 사이드 프로젝트 개발 워크플로우
> Claude Code + Navix 홈서버 + Tailscale SSH 환경 기준
> 이 파일은 본인이 참고하는 가이드 — Claude한테 주는 파일 아님

---

## 환경 세팅 (최초 1회)

```bash
# 1. 홈서버 SSH 접속
ssh navix-home   # Tailscale로 등록된 호스트명

# 2. tmux 세션 시작 (필수 — 끊겨도 작업 보존)
tmux new-session -s {project-name}

# 3. Claude Code 실행
cd ~/projects/{project-name}
claude

# 4. CLAUDE.md 붙여넣기 (현재 세션 블록은 비워둔 채로)
#    → Claude한테: "현재 세션 블록 채워줘, skeleton 시작하자"
#    → Claude가 첫 작업 기준으로 블록 채움
```

---

## Phase 1 — 설계 (구현 전 전부 끝냄)

### Step 1. 기능 목록 정의
```
[나] "이런 서비스 만들거야. 기능 목록:"
     - 유저 인증 (로그인, 로그아웃, 토큰 갱신)
     - 게시글 CRUD
     - 댓글

[Claude] 기능 목록 정리 + 누락 기능 제안
[나] 확정
```

### Step 2. 전체 API Spec 정의
```
[나] "전체 API Spec 초안 잡아줘"

[Claude] 전체 엔드포인트 초안 제안
         POST /auth/login
         POST /auth/logout
         GET  /posts ...

[나] 검토 → 수정 → 확정
[Claude] docs/api-spec.md 파일로 저장
```

### Step 3. DB 스키마 확정
```
[나] "API Spec 기반으로 DB 스키마 잡아줘"

[Claude] 테이블 설계 제안

[나] 꼼꼼히 검토  ← 여기서 시간 제일 많이 써도 됨
                      나중에 바꾸기 제일 힘든 부분

[Claude] docs/schema.md + migration 파일 생성
```

> Phase 1 완료 = api-spec.md + schema.md 확정
> 이후 스키마/스펙 변경은 신중하게

---

## Phase 2 — 구현 (도메인 단위 반복)

### Step 4. 도메인 선택 & 테스트 작성
```
[나] "Auth 도메인 구현하자. 테스트 먼저 작성해줘"

[Claude] 실패하는 테스트 먼저 작성
         TestLogin_Success
         TestLogin_WrongPassword
         TestLogin_UserNotFound
         TestRefreshToken_Expired
```

### Step 5. 구현
```
[Claude] 테스트 통과하도록 구현
         → PostToolUse hook: gofmt + golangci-lint 자동 실행

[나] 코드 리뷰
     "에러 핸들링 빠졌어" / "이 로직 다시 짜줘"

[Claude] 수정 반복
```

### Step 6. 커밋
```
[Claude] 커밋 메시지 + 현재 세션 블록 업데이트 제안
         feat(auth): add login endpoint with JWT refresh

[나] 확인 후 실행
git checkout -b feature/auth-login
git add .
git commit -m "feat(auth): add login endpoint with JWT refresh"
```

### Step 7. 다음 도메인으로 반복
```
Auth → Policy → Bookmark → ...
Phase 2를 도메인 수만큼 반복
```

---

## Phase 3 — 통합

### Step 8. 미들웨어 & 라우팅 연결
```
[나] "전체 라우터 연결하고 미들웨어 붙여줘"
[Claude] main.go에 전체 통합
```

### Step 9. 통합 검증
```
[나] docker compose up -d
    curl 또는 httpie로 E2E 확인
```

### Step 10. 배포
```
[나] 직접 처리 (infra는 Claude 맡기지 않음)
```

---

## 컨텍스트 관리 (/clear)

### /clear가 필요한 증상
```
- 아까 정한 컨벤션 무시하기 시작
- 이미 만든 함수 또 만들려고 함
- 엉뚱한 파일 건드림
- 응답이 느려지거나 횡설수설
```

### /clear 루틴
```
# 1. /clear 전
[나] "CLAUDE.md 현재 세션 블록 업데이트해줘"
[Claude] 현재 도메인, 단계, 브랜치, 다음 작업 반영

# 2. /clear 실행
/clear

# 3. 재시작
[나] 업데이트된 CLAUDE.md 붙여넣기
[나] "계속 진행하자"
[Claude] 컨텍스트 파악 후 재개
```

### 세션 끊겼을 때 (tmux 덕분에 파일은 살아있음)
```bash
ssh navix-home
tmux attach -t {project-name}
claude
# CLAUDE.md 다시 붙여넣기
```

---

## 파일 위치 정리

```
~/.claude/CLAUDE.md              ← 전역 규칙 (Claude Code 자동 로드)
~/projects/{name}/CLAUDE.md      ← 프로젝트 컨텍스트
~/dev-docs/
    ├─ workflow.solo.md           ← 이 파일 (본인 참고용)
    └─ workflow.team.md
~/projects/{name}/docs/
    ├─ api-spec.md               ← Phase 1 산출물
    └─ schema.md                 ← Phase 1 산출물
```
