## 도메인 모델링하기
- 즉, 비지니스 규칙 명확히 하기
- 엔티티 설계하기

## api 계약
- stub 코드 짜고(가짜 응답)
- OpenAPI Specification 사용해서 문서 만들기
    - swagger를 사용
    - 지정한 annotation를 붙인 애들을 알아서 문서화.

## 코딩 스타일 및, git branch 전략과 CI/CD환경 
- Layered vs Domain

## 디렉토리 구조
```
my-delivery-app/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD (테스트 + 문서 자동화)
├── docs/                       # [추가] 설계도 저장소 (API 명세서 등)
│   └── api/
│       └── order-api.yaml      # 프론트엔드와 공유할 계약서
├── src/
│   ├── main/
│   │   ├── java/com/delivery/
│   │   │   ├── common/         # 공통 컴포넌트
│   │   │   ├── order/          # 도메인 패키지
│   │   │   └── config/         # Swagger/RestDocs 설정
│   │   └── resources/
│   │       └── application.yml
│   └── test/
│       ├── java/com/delivery/  # 테스트 코드 (문서 생성의 근거)
│       └── resources/          # 문서 템플릿 (RestDocs)
├── build.gradle
└── README.md                   # 프로젝트 설명
```
## 디렉토리 구조 짠 후
- 1단계: Common 계층 (공통 규격의 약속) 코드 짜기: 공통 응답 객체와, 전역 예외 처리기 짜기

- 2단계: Domain 엔티티 설계하기: 즉, 핵심 서비스들의 객체 만들기

- 3단계: Repository interface 만들기

- 4단계: Service 비지니스 로직 만들기

- 5단계: Controller 만들기

## API 명세 짜는 시점
- Swagger YAML/JSON 파일을 직접 작성
- ex)
```
    openapi: 3.0.0
info:
  title: 주문 시스템 API
  version: 1.0.0
paths:
  /api/orders:
    post:
      summary: 주문 생성
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                itemId: { type: integer }
                quantity: { type: integer }
      responses:
        '200':
          description: 성공
          content:
            application/json:
              schema:
                type: object
                properties:
                  orderId: { type: integer }
```
- 이걸 한 후, Swagger Editor에 붙여넣기를 해서, 프엔이 여기서 나온 주소로 브라우저 열어보고 명세 확인
- Prism 같은 도구에 넣으면 가짜 JSON응답을 주는 서버를 만들어줌, 이런걸 사용해서 프엔이 개발
- docs/api/~.yaml 에 넣음

## git에 대한 이야기
- git 나누기
```
main (or master): 배포용 코드. 언제나 돌아가는 완벽한 상태.

develop: 개발 중인 코드. 모든 기능이 여기서 합쳐짐.

feature/주제: 개별 기능을 만드는 곳. (예: feature/order-create, feature/payment-init)
```

- git PR 보내기
```
작업: feature/order-create 브랜치를 파서 코딩
푸시: 내 작업 내용을 GItHub에 올림(commit 제대로)
PR 요청: 팀원에게 develop에 PR받아달라고 요청
```

- GitAction이란
```
만들어 놓은 테스트코드와 Swagger는 PR이 발생할때마다 자동으로 돌아가게 설정, 여기서 제대로 실행되면 API문서가 자동으로 빌드 및 배
```

- ./github/workflow/deploy.yml 파일에 GitAction 설정
```
name: CI Pipeline

on:
  push:
    branches: [ develop ] # develop 브랜치에 푸시될 때마다 실행

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Build with Gradle
        run: ./gradlew build # 여기서 테스트와 문서 생성(Rest Docs)이 동시에 진행됨
```

## DB에 대하여
- 초반에 H2같은 메모리 기반 데이터베이스 사용 후, 나중에 실제 배포때 바꿈

## 조립을 할때
- config와 application.yml에서 경로 설정만 하면 되게 하는게 핵심
  - 로컬 개발 시: application-local.yml의 DB 주소를 내 컴퓨터(localhost)로 설정.

  - 운영 배포 시: application-prod.yml의 DB 주소를 배민 클라우드 DB 주소로 설정.

```
  application-local.yml 에시
  spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE # H2 메모리 DB 사용
    username: sa
    password: 
    driver-class-name: org.h2.Driver
  
  jpa:
    hibernate:
      ddl-auto: update # 엔티티 변경 시 테이블 자동 업데이트
    show-sql: true     # 콘솔에 실제 SQL 로그 출력
    properties:
      hibernate:
        format_sql: true # SQL 예쁘게 출력

# Swagger 설정 (로컬에서만 확인용)
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html

# 로그 레벨 설정 (내 코드의 동작을 자세히 보려고)
logging:
  level:
    com.delivery: DEBUG
```

## 그럼 API명세를 어케 넘겨주는가?
- Github Pages나 AWS에 올려서 URL을 넘겨주기
```
deploy.yml에 git action중 github pages에 API명세 문서를 올리도록 설정
```

## config 코드 예시
- 1. Swagger 설정
```
package com.delivery.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("배민 클론코딩 API 명세서")
                .version("v1.0")
                .description("주문 시스템의 모든 API를 확인하세요."));
    }
}
```

- 2. JPA 설정
```
package com.delivery.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@Configuration
@EnableJpaAuditing // 생성일자(createdAt), 수정일자(updatedAt) 자동 기록을 위해 필수!
public class JpaConfig {
}
```

- 3. 웹 설정
```
package com.delivery.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // 모든 경로에 대해
            .allowedOrigins("*")  // 모든 도메인 허용 (나중엔 실제 도메인만 허용하도록 수정)
            .allowedMethods("GET", "POST", "PUT", "DELETE");
    }
}
```

## intellij 로 시작하기
1. New Project를 누른 뒤 시작
- Name: 프로젝트 이름
- Type: Gradle - Kotlin or Groovy
- Lang: Java
- JDK: 17이상

2. project 만들어지면
- 디렉토리 정리
```
src/main/java/com/delivery: 메인 로직이 들어가는 곳.

controller/: 외부 요청을 받는 창구

service/: 비즈니스 로직(요리)

repository/: DB와 소통하는 곳

config/: 아까 말한 중앙 통제실

src/main/resources/: 설정 파일(application-local.yml)이 들어가는 곳.

src/test/java/: AI가 짠 코드를 검증할 테스트 코드.
```

3. Entry Point: `src/main/java/com/delivery/DeliveryApplication.java`


