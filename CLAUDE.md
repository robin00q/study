# study 레포 작업 규칙

개인 학습 노트 저장소. Claude와 주제별로 함께 공부하며 노트를 마크다운으로 축적한다.

## 브랜치 네이밍

- 주제별로 `study/<주제>` 형식 브랜치를 따서 작업한다.
  - 예: `study/cdc`, `study/outbox`, `study/idempotency`
- `main`에는 바로 커밋하지 않고, 브랜치를 거친다.

## Git 병합 정책

- **브랜치를 `main`에 병합할 때는 항상 `--no-ff` 병합 커밋으로 처리한다.**
  - fast-forward가 가능하더라도 `--no-ff`를 사용해 병합 커밋을 남긴다.
  - 이유: 학습 브랜치의 항목별 커밋을 그대로 보존하면서, "어떤 주제 학습이 언제 완료되어 합쳐졌는지"를 병합 커밋 landmark로 한눈에 볼 수 있게 하기 위함.
  - `--squash`는 항목별 학습 자취가 사라지므로 사용하지 않는다.

```bash
git checkout main
git merge --no-ff <feature-branch>
```

## 파일 네이밍

- **사용자가 직접 공부해서 쓴 노트** = 번호 접두사 (`01-`, `02-` …)
  - 나중에 이것만 남길 예정.
- **Claude가 만든 질문 스캐폴드/가이드** = `ai-` 접두사 (`ai-01-...`, `ai-README.md`)
  - 정리 시 `rm ai-*` 로 한 번에 제거 가능.
- 경로(폴더/파일명)는 한글 사용 OK (`core.quotepath false`, `core.precomposeunicode true` 설정됨).

## 학습 방식

- 설명형(explanatory) + active recall(가끔 퀴즈) 선호.
- 곁가지로 깊게 파고 싶은 주제는 `TODO.md`에 백로그로 남기고 메인 트랙 유지.
