## 보안의 3대 개념
- Authentication(인증)
    - 로그인하여 자신이 누군지 알려주는 과정
- Authorizationio(인가)
    - 어떤 행동을 할 자격이 있는지 확인하고, 허용해주는 것
- Filter Chain
    - 위의 요청들을 검사하는 것

## 초기 세팅
- SecurityConfig.java 만들기
    - config 패키지에 Spring Security 관련 클래스를 만들어서, Spring Security를 사용하겠다고 설정
```
@Configuration
@EnableWebSecurity // 보안 설정을 시작하겠다!
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // 로컬 개발 시에는 일단 끕니다. (실무에선 다르게 관리)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/login", "/api/signup").permitAll() // 여기는 누구나 통과!
                .anyRequest().authenticated() // 나머지는 무조건 로그인한 사람만!
            );
        return http.build();
    }
}
```

## JWT
- JSON Web Token
    - 매번 id/passwd 를 보내면 서버 부하 높아짐 -> 토근을 발행
    1. 로그인: id/passwd를 확인 후, 서버가 JWT를 발급
    2. API 호출, 이후 모든 요청에 이 토큰을 헤더에 담아서 보내기
    3. 토큰을 보고 위조 여부를 확인 후 서비스 로직 실행

## 로그인 인증과정과, 책임 분담
```
단계,책임자,내용
1. 요청 전송,프론트엔드,로그인 폼 구성 및 데이터 전송
2. 필터 검문,Spring Security,요청을 가로채고 인증 처리 준비 (Filter 체인)
3. 신원 확인,개발자 (당신),DB에서 회원 정보 조회 및 비밀번호 매칭 로직
4. 신분증 발급,개발자 (당신),JWT 생성 및 암호화 알고리즘 선택
5. 응답 전달,Spring & 개발자,DTO 구성 및 JSON 변환/전송
```

## 롬복을 이용한 DTO 예시
```
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter // 모든 필드의 Getter를 자동으로 생성
@Setter // 모든 필드의 Setter를 자동으로 생성
@NoArgsConstructor // 파라미터가 없는 기본 생성자 생성
@AllArgsConstructor // 모든 필드를 포함한 생성자 생성
public class LoginRequest {
    
    private String email;
    private String password;
    
}
```