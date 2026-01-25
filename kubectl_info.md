# kubectl 명령어 정리

이 문서는 프로젝트에서 사용한 kubectl 명령어들을 설명과 함께 정리합니다.

---

## 목차

1. [클러스터 정보 확인](#1-클러스터-정보-확인)
2. [네임스페이스 관리](#2-네임스페이스-관리)
3. [리소스 배포 (apply)](#3-리소스-배포-apply)
4. [리소스 조회 (get)](#4-리소스-조회-get)
5. [리소스 상세 정보 (describe)](#5-리소스-상세-정보-describe)
6. [포트포워딩](#6-포트포워딩)
7. [리소스 삭제 (delete)](#7-리소스-삭제-delete)
8. [리소스 수정 (patch, annotate)](#8-리소스-수정-patch-annotate)
9. [대기 명령어 (wait)](#9-대기-명령어-wait)
10. [Secret 관리](#10-secret-관리)

---

## 1. 클러스터 정보 확인

### 클러스터 상태 확인

```bash
kubectl cluster-info
```

- 쿠버네티스 컨트롤 플레인이 실행 중인지 확인
- API 서버 주소 표시

**출력 예시:**
```
Kubernetes control plane is running at https://127.0.0.1:26443
```

### 노드 목록 확인

```bash
kubectl get nodes
```

- 클러스터에 등록된 모든 노드 목록 표시
- 노드의 상태(Ready/NotReady), 역할, 버전 확인

---

## 2. 네임스페이스 관리

### 네임스페이스 생성

```bash
kubectl create namespace argocd
```

- `argocd`라는 이름의 네임스페이스 생성
- 네임스페이스: 쿠버네티스 리소스를 논리적으로 분리하는 단위

### 네임스페이스 목록 확인

```bash
kubectl get namespaces
# 또는 축약형
kubectl get ns
```

---

## 3. 리소스 배포 (apply)

### YAML 파일로 리소스 배포

```bash
kubectl apply -f <파일명.yaml>
```

- YAML 파일에 정의된 리소스를 클러스터에 생성/업데이트
- `-f`: 파일 지정 옵션

**사용 예시:**

```bash
# 로컬 파일 적용
kubectl apply -f argocd/application-dev.yaml

# 특정 네임스페이스에 적용
kubectl apply -f argocd/project.yaml -n argocd

# 원격 URL에서 직접 적용
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**옵션 설명:**
- `-n <namespace>`: 특정 네임스페이스에 리소스 적용
- `-f <file>`: 적용할 YAML 파일 경로

---

## 4. 리소스 조회 (get)

### 기본 조회

```bash
kubectl get <리소스타입> [-n <네임스페이스>]
```

**주요 리소스 타입:**
- `pods` (po): 파드
- `services` (svc): 서비스
- `deployments` (deploy): 디플로이먼트
- `applications`: ArgoCD 애플리케이션
- `configmaps` (cm): 컨피그맵
- `secrets`: 시크릿

### 사용 예시

```bash
# ArgoCD 네임스페이스의 모든 Pod 조회
kubectl get pods -n argocd

# 모든 네임스페이스의 Pod 조회
kubectl get pods -A
# 또는
kubectl get pods --all-namespaces

# ArgoCD Application 목록 조회
kubectl get applications -n argocd

# 서비스 조회
kubectl get svc -n java-practice-dev

# YAML 형식으로 상세 출력
kubectl get application java-practice-dev -n argocd -o yaml

# JSON 경로로 특정 값만 추출
kubectl get application java-practice-dev -n argocd -o jsonpath='{.status.conditions[0].message}'
```

**옵션 설명:**
- `-n <namespace>`: 특정 네임스페이스의 리소스만 조회
- `-A` 또는 `--all-namespaces`: 모든 네임스페이스 조회
- `-o yaml`: YAML 형식으로 출력
- `-o json`: JSON 형식으로 출력
- `-o jsonpath='{...}'`: JSON 경로로 특정 값만 추출
- `-o wide`: 추가 정보(노드, IP 등) 포함하여 출력

---

## 5. 리소스 상세 정보 (describe)

```bash
kubectl describe <리소스타입> <리소스명> [-n <네임스페이스>]
```

- 리소스의 상세 정보, 이벤트, 상태 등 확인
- 문제 해결(troubleshooting)에 유용

**사용 예시:**

```bash
# Pod 상세 정보
kubectl describe pod dev-java-practice-xxx -n java-practice-dev

# 서비스 상세 정보
kubectl describe svc dev-java-practice-service -n java-practice-dev
```

---

## 6. 포트포워딩

### 서비스 포트포워딩

```bash
kubectl port-forward svc/<서비스명> <로컬포트>:<서비스포트> -n <네임스페이스>
```

- 로컬 머신에서 클러스터 내부 서비스에 접근 가능하게 함
- 개발/테스트 환경에서 주로 사용

**사용 예시:**

```bash
# ArgoCD 서버 접속 (로컬 8081 → 서비스 443)
kubectl port-forward svc/argocd-server -n argocd 8081:443

# 백그라운드 실행
kubectl port-forward svc/argocd-server -n argocd 8081:443 &

# 개발 환경 앱 접속 (로컬 8082 → 서비스 80)
kubectl port-forward svc/dev-java-practice-service -n java-practice-dev 8082:80
```

### Pod 포트포워딩

```bash
kubectl port-forward pod/<파드명> <로컬포트>:<컨테이너포트> -n <네임스페이스>
```

### 포트포워딩 종료

```bash
# 특정 포트포워딩 프로세스 찾기
ps aux | grep port-forward

# 프로세스 종료
kill <PID>

# 또는 패턴으로 종료
pkill -f "port-forward.*argocd-server"
```

---

## 7. 리소스 삭제 (delete)

### 리소스 삭제

```bash
kubectl delete <리소스타입> <리소스명> [-n <네임스페이스>]
```

**사용 예시:**

```bash
# 단일 리소스 삭제
kubectl delete application java-practice-dev -n argocd

# 여러 리소스 동시 삭제
kubectl delete application java-practice-dev java-practice-prod -n argocd

# YAML 파일로 정의된 리소스 삭제
kubectl delete -f argocd/application-dev.yaml

# 네임스페이스 전체 삭제 (주의: 내부 모든 리소스 삭제됨)
kubectl delete namespace java-practice-dev
```

---

## 8. 리소스 수정 (patch, annotate)

### patch - 리소스 부분 수정

```bash
kubectl patch <리소스타입> <리소스명> -n <네임스페이스> --type merge -p '<JSON>'
```

**사용 예시:**

```bash
# ArgoCD Application 동기화 트리거
kubectl patch application java-practice-dev -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

### annotate - 어노테이션 추가/수정

```bash
kubectl annotate <리소스타입> <리소스명> -n <네임스페이스> <key>=<value>
```

**사용 예시:**

```bash
# ArgoCD 강제 새로고침
kubectl annotate application java-practice-dev -n argocd argocd.argoproj.io/refresh=hard --overwrite
```

**옵션 설명:**
- `--overwrite`: 기존 어노테이션 덮어쓰기

---

## 9. 대기 명령어 (wait)

```bash
kubectl wait --for=<조건> <리소스타입>/<리소스명> -n <네임스페이스> --timeout=<시간>
```

- 특정 조건이 충족될 때까지 대기
- CI/CD 파이프라인에서 유용

**사용 예시:**

```bash
# Deployment가 사용 가능할 때까지 대기 (최대 5분)
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Pod가 Ready 상태가 될 때까지 대기
kubectl wait --for=condition=ready pod -l app=java-practice -n java-practice-dev --timeout=120s
```

---

## 10. Secret 관리

### Secret 값 조회

```bash
kubectl get secret <시크릿명> -n <네임스페이스> -o jsonpath='{.data.<키>}'
```

- Secret 값은 base64로 인코딩되어 저장됨
- 조회 후 base64 디코딩 필요

**사용 예시:**

```bash
# ArgoCD 초기 비밀번호 조회 (base64 디코딩 포함)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

### Secret 생성

```bash
kubectl create secret generic <시크릿명> \
  -n <네임스페이스> \
  --from-literal=<키>=<값>
```

**사용 예시:**

```bash
# GitHub 저장소 인증 Secret 생성
kubectl create secret generic github-repo-secret \
  -n argocd \
  --from-literal=url=https://github.com/user/repo.git \
  --from-literal=username=user \
  --from-literal=password=token

# ArgoCD용 라벨 추가
kubectl label secret github-repo-secret -n argocd argocd.argoproj.io/secret-type=repository
```

---

## 자주 사용하는 명령어 조합

### 1. 전체 상태 확인

```bash
# 모든 Pod 상태 확인
kubectl get pods -A

# ArgoCD Application 상태 확인
kubectl get applications -n argocd
```

### 2. 문제 해결 시

```bash
# Pod 로그 확인
kubectl logs <pod-name> -n <namespace>

# 실시간 로그 확인
kubectl logs -f <pod-name> -n <namespace>

# 이벤트 확인 (최근순 정렬)
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### 3. 리소스 재시작

```bash
# Deployment 재시작 (Pod 재생성)
kubectl rollout restart deployment/<deployment-name> -n <namespace>

# 롤아웃 상태 확인
kubectl rollout status deployment/<deployment-name> -n <namespace>
```

---

## 단축어 (Aliases)

| 전체 이름 | 단축어 |
|-----------|--------|
| pods | po |
| services | svc |
| deployments | deploy |
| namespaces | ns |
| configmaps | cm |
| replicasets | rs |
| persistentvolumeclaims | pvc |

**예시:**
```bash
kubectl get po -A      # kubectl get pods --all-namespaces
kubectl get svc -n dev # kubectl get services -n dev
```

---

## 참고 링크

- [kubectl 공식 문서](https://kubernetes.io/docs/reference/kubectl/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
