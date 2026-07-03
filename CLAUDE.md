# CLAUDE.md

이 저장소는 학습 노트를 정리하는 공간입니다.

## Git 병합 정책

- **브랜치를 `main`에 병합할 때는 항상 `--no-ff` 병합 커밋으로 처리한다.**
  - fast-forward가 가능하더라도 `--no-ff`를 사용해 병합 커밋을 남긴다.
  - 이유: 학습 브랜치의 항목별 커밋을 그대로 보존하면서, "어떤 주제 학습이 언제 완료되어 합쳐졌는지"를 병합 커밋 landmark로 한눈에 볼 수 있게 하기 위함.
  - `--squash`는 항목별 학습 자취가 사라지므로 사용하지 않는다.

```bash
git checkout main
git merge --no-ff <feature-branch>
```
