## API 종류
1. 2xx: "성공!" (Everything is OK)
    - 200 OK: 가장 흔한 성공. 조회, 수정, 삭제 시 사용.

    - 201 Created: 생성 완료. 새로운 리소스(게시글, 회원)가 성공적으로 DB에 저장되었을 때.

    - 204 No Content: 성공했으나, 돌려줄 데이터가 없을 때 (예: 삭제 성공 시).

2. 4xx: "클라이언트가 잘못했어!" (Client Side Error)
프론트엔드가 요청을 잘못 보냈을 때 반환합니다.

    - 400 Bad Request: 파라미터가 틀렸거나, JSON 형식이 깨졌을 때.

    - 401 Unauthorized: 로그인 안 함. 인증이 필요한데 토큰이 없거나 만료됨.

    - 403 Forbidden: 권한 부족. 로그인은 했지만, 관리자만 가능한 페이지에 접근했을 때.

    - 404 Not Found: 리소스 없음. 없는 주소나 존재하지 않는 주문 번호를 찾을 때.

    - 409 Conflict: 충돌. 이미 가입된 이메일로 가입을 시도할 때 등.

3. 5xx: "내 서버가 잘못했어!" (Server Side Error)
서버 코드나 DB에 문제가 생겼을 때입니다.

    - 500 Internal Server Error: 서버 로직에서 예외(Exception)가 터짐.

    - 503 Service Unavailable: 서버가 점검 중이거나 과부하로 응답할 수 없음.