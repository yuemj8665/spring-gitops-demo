# spring-gitops-demo

Spring Boot 애플리케이션을 GitOps 방식으로 Kubernetes에 자동 배포하는 데모 프로젝트입니다.

---

## 4-1. 프로젝트 개요

이 프로젝트는 Spring Boot 애플리케이션을 GitLab CI/CD, Docker, Kubernetes(OrbStack), ArgoCD를 사용하여
GitOps 방식으로 자동 배포하는 전체 파이프라인을 구성한 데모입니다.

- **Git Push → GitLab CI → Docker 이미지 빌드 & Push → k8s 매니페스트 업데이트 → ArgoCD 자동 동기화 → Kubernetes 배포**
- 개발(dev)과 운영(prod) 환경을 Kustomize overlays로 분리 관리
- Spring Boot Actuator로 헬스체크 엔드포인트 제공

---

## 4-2. 프로젝트 구조

```
spring-gitops-demo/
├── src/
│   ├── main/
│   │   ├── java/com/example/javapractice/
│   │   │   ├── JavaPracticeApplication.java    # 메인 엔트리포인트
│   │   │   └── controller/
│   │   │       └── HelloController.java        # REST API 컨트롤러 (/, /health, /info)
│   │   └── resources/
│   │       └── application.yml                 # Spring Boot 설정
│   └── test/
│       └── java/.../JavaPracticeApplicationTests.java  # JUnit 테스트
├── k8s/
│   ├── base/                                   # Kustomize 공통 리소스
│   │   ├── deployment.yaml                     # Pod 배포 설정
│   │   ├── service.yaml                        # 서비스 노출 설정
│   │   ├── configmap.yaml                      # 환경변수 설정
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/                                # 개발 환경 오버라이드
│       │   └── kustomization.yaml
│       └── prod/                               # 운영 환경 오버라이드
│           ├── kustomization.yaml
│           ├── ingress.yaml
│           └── secret.yaml
├── argocd/
│   ├── project.yaml                            # ArgoCD 프로젝트 정의
│   ├── application-dev.yaml                    # dev 환경 ArgoCD 앱
│   ├── application-prod.yaml                   # prod 환경 ArgoCD 앱
│   └── application.yaml
├── docs/
│   └── changelog.md                            # 변경 이력
├── Dockerfile                                  # 멀티스테이지 Docker 빌드
├── deploy.sh                                   # 자동 배포 스크립트
├── .gitlab-ci.yml                              # GitLab CI/CD 파이프라인
└── pom.xml                                     # Maven 빌드 설정
```

---

## 4-3. 데이터베이스 구조

이 프로젝트는 데이터베이스를 사용하지 않습니다.
단순 REST API 응답을 반환하는 상태 비저장(stateless) 애플리케이션입니다.

| 엔드포인트 | 메서드 | 설명 |
|-----------|--------|------|
| `/`       | GET    | 환영 메시지 + 상태 반환 |
| `/health` | GET    | 헬스체크 (status: UP) |
| `/info`   | GET    | 애플리케이션 정보 |
| `/actuator/health` | GET | Spring Actuator 헬스체크 |

---

## 4-4. 사용 기술 및 선택 이유

| 기술 | 버전 | 선택 이유 |
|------|------|----------|
| **Spring Boot** | 3.2.0 | Java 표준 웹 프레임워크, Actuator로 헬스체크 엔드포인트 자동 제공 |
| **Java** | 17 | LTS 버전, Spring Boot 3.x 최소 요구사항 |
| **Docker** | - | 이식성 있는 컨테이너 이미지 빌드 |
| **Kubernetes** | - | 컨테이너 오케스트레이션, 롤링 업데이트 / 헬스체크 자동화 |
| **OrbStack** | - | macOS 로컬 Kubernetes 환경 (Docker Desktop 대비 경량) |
| **Kustomize** | - | 환경별(dev/prod) 설정 분리, 코드 중복 없이 오버레이 관리 |
| **ArgoCD** | - | GitOps 방식의 자동 배포, Git이 단일 진실의 원천(Source of Truth) |
| **GitLab CI** | - | 이미지 빌드 및 k8s 매니페스트 자동 업데이트 파이프라인 |
| **Maven** | - | Java 빌드 표준 도구 |

---

## 4-5. 설치 및 실행 방법

### 사전 요구사항
- Docker 실행 중
- OrbStack 설치 (macOS 기준)
- kubectl 설치
- ArgoCD 설치 (최초 1회)

### 로컬 실행 (Maven)

```bash
./mvnw spring-boot:run
# 접속: http://localhost:8080
```

### Docker

```bash
# 이미지 빌드
docker build -t spring-gitops-demo .

# 컨테이너 실행
docker run -d --name spring-gitops-demo -p 8080:8080 spring-gitops-demo

# 로그 확인
docker logs -f spring-gitops-demo

# 컨테이너 중지 및 삭제
docker stop spring-gitops-demo && docker rm spring-gitops-demo
```

### Kubernetes (OrbStack)

```bash
# Kubernetes 시작
orbctl start k8s

# ArgoCD 설치 (최초 1회)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD Application 등록
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application-dev.yaml
kubectl apply -f argocd/application-prod.yaml

# ArgoCD 포트포워딩 (UI 접속용)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# 접속: https://localhost:8080 (admin / 아래 명령으로 비밀번호 확인)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### 자동 배포 스크립트

```bash
./deploy.sh
```

### JUnit 테스트 실행

```bash
./mvnw test
# 또는 Docker Maven 환경
docker run --rm -v $(pwd):/app -w /app maven:3.9-eclipse-temurin-17 mvn test
```

---

## 4-6. 에러 모음

| 날짜 | 에러 | 원인 | 해결 방법 |
|------|------|------|----------|
| 2026-03-10 | Pod readiness probe 실패 | `initialDelaySeconds`가 너무 짧아 Spring Boot 기동 전에 probe 실행 | `initialDelaySeconds`를 30s로 증가 |

> 상세 내용은 `docs/changelog.md` 참고
