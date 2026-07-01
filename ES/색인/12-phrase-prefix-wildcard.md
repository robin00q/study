# phrase, prefix, wildcard

---

## match_phrase

---

`match` 는 토큰이 있기만 하면되지만, `match_phrase` 는 순서대로 인접해야 매칭된다.

```json
{
  "query": {
    "match_phrase": {
      "subject": "맞바람 외전"
    }
  }
}
```

| subject   | 검색 여부 | slop = 1 적용 |
|-----------|-------|-------------|
| 맞바람 1기 외전 | ❌     | ✅           |
| 외전 맞바람    | ❌     | ❌           |
| 맞바람 외전    | ✅     | ✅           |

- "맞바람 외전" 으로 토큰화 된 "맞바람", "외전" 이 인접해야하므로 "맞바람 외전" 만 검색된다.
- slop (토큰 사이 허용 간격) 을 추가하면 "맞바람 1기 외전" 도 검색된다.

> 역색인은 토큰 -> (문서, position) 까지 저장하므로 match_phrase 의 결과인 인접여부를 알 수 있다.

## prefix

---

```json
{
  "query": {
    "prefix": {
      "subject.keyword": "맞바람"
    }
  }
}
```

- `keyword` 에 사용하는게 정석이다.
- `text` 에 사용하게되면 토큰자체가 "맞바람" 으로 토큰화된 문서들이 모두 검색되어 의도와 다르게 동작한다.

> 역색인 단어는 사전순으로 정렬되어 저장된다. 이로인해 적은 비용으로 prefix 를 알 수 있다.

## wildcard

---

```json
{
  "query": {
    "wildcard": {
      "subject.keyword": "*맞바람*"
    }
  }
}
```

- `keyword` 값을 패턴으로 검색한다.

> wildcard 가 앞쪽에 붙어있으면, 정렬된 역색인 참조가 불가능하므로 모든 색인을 훑어야해서 느리다.

> 이로인해 포함은 wildcard 가 아닌, ngram 을 사용하는것이 정석이다.