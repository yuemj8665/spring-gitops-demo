# Java Practice - Spring Boot + Kubernetes + ArgoCD

Spring Boot 애플리케이션을 Kubernetes와 ArgoCD로 배포하는 예제 프로젝트입니다.

---

## 프로젝트 구조

```
javaPractice_20260125/
├── src/main/java/...          # Spring Boot 소스
├── Dockerfile                 # Docker 이미지 빌드
├── k8s/
│   ├── base/                  # Kustomize 기본 리소스
│   └── overlays/              # 환경별 오버레이 (dev/prod)
├── argocd/                    # ArgoCD Application 설정
└── .gitlab-ci.yml             # CI/CD 파이프라인
```

---

## 빠른 시작 명령어

### Docker

```bash
# 이미지 빌드
docker build -t java-practice_20260125 .

# 컨테이너 실행 (ON)
docker run -d --name java-practice -p 8080:8080 java-practice_20260125

# 컨테이너 중지 (OFF)
docker stop java-practice

# 컨테이너 재시작
docker start java-practice

# 컨테이너 삭제
docker rm java-practice

# 로그 확인
docker logs -f java-practice
```

---

### Kubernetes (OrbStack)

```bash
# Kubernetes 시작 (ON)
orbctl start k8s

# Kubernetes 중지 (OFF)
orbctl stop k8s

# 클러스터 상태 확인
kubectl cluster-info
kubectl get nodes
```

---

### ArgoCD

```bash
# ArgoCD 네임스페이스 생성 (최초 1회)
kubectl create namespace argocd

# ArgoCD 설치 (최초 1회)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 상태 확인
kubectl get pods -n argocd

# ArgoCD 서버 포트포워딩 (ON) - 백그라운드 실행
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# 포트포워딩 중지 (OFF)
pkill -f "port-forward.*argocd-server"

# 초기 admin 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# ArgoCD 접속
# URL: https://localhost:8080
# Username: admin
# Password: 위에서 확인한 비밀번호
```

---

### ArgoCD Application 등록

```bash
# 프로젝트 디렉토리로 이동
cd /Users/mamyeongjae/home-server/workspace/personal/javaPractice_20260125

# ArgoCD Application 등록
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application-dev.yaml
kubectl apply -f argocd/application-prod.yaml

# Application 상태 확인
kubectl get applications -n argocd
```

---

## 전체 환경 ON/OFF

### 전체 시작 (ON)

```bash
# 1. Kubernetes 시작
orbctl start k8s

# 2. ArgoCD 포트포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# 3. 상태 확인
kubectl get pods -n argocd
```

### 전체 중지 (OFF)

```bash
# 1. 포트포워딩 중지
pkill -f "port-forward.*argocd-server"

# 2. Kubernetes 중지
orbctl stop k8s
```

---

## 유용한 명령어

### Pod 관리

```bash
# 모든 Pod 확인
kubectl get pods -A

# 특정 네임스페이스 Pod 확인
kubectl get pods -n java-practice-dev
kubectl get pods -n java-practice-prod

# Pod 로그 확인
kubectl logs -f <pod-name> -n <namespace>

# Pod 재시작 (Deployment)
kubectl rollout restart deployment/java-practice -n java-practice-dev
```

### ArgoCD CLI (선택사항)

```bash
# ArgoCD CLI 설치
brew install argocd

# 로그인
argocd login localhost:8080 --insecure

# Application 목록
argocd app list

# 수동 동기화
argocd app sync java-practice-dev

# Application 상태 확인
argocd app get java-practice-dev
```

---

## 트러블슈팅

### Kubernetes 연결 실패

```bash
# OrbStack Kubernetes 상태 확인
orbctl status

# Kubernetes 재시작
orbctl stop k8s
orbctl start k8s
```

### ArgoCD Pod가 시작되지 않음

```bash
# Pod 상태 확인
kubectl get pods -n argocd

# Pod 상세 정보
kubectl describe pod <pod-name> -n argocd

# 이벤트 확인
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

### 포트 충돌

```bash
# 8080 포트 사용 중인 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 <PID>
```

---

## 환경 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `APP_MESSAGE` | 환영 메시지 | Hello from Spring Boot! |
| `SPRING_PROFILES_ACTIVE` | Spring 프로파일 | default |
| `SERVER_PORT` | 서버 포트 | 8080 |

---

## 참고 링크

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [OrbStack Documentation](https://docs.orbstack.dev/)
- [Kustomize Documentation](https://kustomize.io/)
