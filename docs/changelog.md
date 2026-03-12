# 변경 이력

## 2026-03-10

### 프로젝트 이름 변경
- **변경 전**: `java-practice` / `javaPractice_20260125`
- **변경 후**: `spring-gitops-demo`
- **변경 파일**: pom.xml, application.yml, deployment.yaml, service.yaml, ingress.yaml, configmap.yaml, kustomization.yaml (dev/prod), argocd/*.yaml, README.md, kubectl_info.md 등 총 19개 파일
- **GitHub**: 기존 저장소(`yuemj8665/javaPractice_20260125`) 삭제 후 신규 저장소(`yuemj8665/spring-gitops-demo`) 생성 및 push

### 테스트 결과
- JUnit `contextLoads` 테스트 통과 (Docker Maven 환경)
- Spring Boot 컨텍스트 정상 로드 확인
- `Tests run: 1, Failures: 0, Errors: 0, Skipped: 0`
