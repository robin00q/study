# bool 쿼리 (must, should, filter, must_not)

---

## bool 의 4개의 절

---

```json
{
  "query": {
    "bool": {
      "must": [
        ...
      ],
      "should": [
        ...
      ],
      "filter": [
        ...
      ],
      "must_not": [
        ...
      ]
    }
  }
}
```

| 절        | 의미           | 점수 기여 | 비유                        |
|----------|--------------|-------|---------------------------|
| must     | AND - 반드시 만족 | ✅ 함   | 필수 자격요건 (얼마나 잘 맞는지 채점도 함) |
| filter   | AND - 반드시 만족 | ❌ 안 함 | 서류 컷 (통과/탈락만, 점수 없음)      |
| should   | OR - 만족하면 좋음 | ✅ 함   | 가산점 (우대사항)                |
| must_not | 제외           | ❌ 안 함 |                           |

```text
4개의 절 사이에 적용 "순서" 는 없다. 
전부 하나의 조건식으로 합쳐진다. (must AND filter AND NOT must_not)
실행 순서는 Lucene 이 비용을 보고 알아서 정한다.
SQL 의 WHERE 처럼 선언적이다. 개발자의 선택지는 순서가 아니라 "어느 절에 담느냐." 이다.
```

## must vs filter

---

- `must` : 점수(_score) 를 계산한다. -> "얼마나 관련있나" 순위에 반영한다.
- `filter` : 점수 계산을 하지 않는다. (O/X 만) + 결과를 **캐시** 해서 재사용 시 빠르다.
- filter 만 있는 쿼리는 모든 문서가 `_score: 0.0` (순위 개념이 사라진다. -> 필요하면 sort 사용)

**그래서 실무에서는:**

- 검색어처럼 **순위 매길 조건은 must/should**
- 상태값, 날짜범위처럼 **딱 떨어지는 조건은 filter**

## should 의 두 모드

---

**모드 1 : must(또는 filter) 와 함께 -> 순수 가산점**

- 거르기에 관여하지 않는다. should 가 하나도 못맞춰도 결과에 포함된다.
- 맞춘 문서에만 점수가 **합산**된다. -> 순위 조작 도구

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "subject.korean": "맞바람"
          }
        }
      ],
      "should": [
        {
          "term": {
            "subject.keyword": "맞바람"
          }
        }
      ]
    }
  }
}
```

- 건수는 `must` 만 했을때의 결과와 완전히 동일하다.
- 완전일치되는 문서만 점수를 올려 1등이 굳혀진다.

**모드2 : bool 안에 should 만 -> OR 필터로 변신**

- `minimum_should_match` 가 자동으로 1이 된다. (최소 1개는 맞춰야 포함)
- 안 그러면 아무것도 안거르니 전체 문서가 다 나와버리기 때문이다.

> should 는 "같이 있는 절이 있으면 가산점, 혼자면 OR 필터"

## must_not

---

- 걸리면 무조건 탈락. 점수와 무관

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "subject.korean": "맞바람"
          }
        }
      ],
      "must_not": [
        {
          "match": {
            "subject.korean": "외전"
          }
        }
      ]
    }
  }
}
```

## 예시 (완전/전방/포함 티어를 bool 로 묶기)

---

```json
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "subject.keyword": "맞바람"
          }
        },
        {
          "prefix": {
            "subject.keyword": "맞바람"
          }
        },
        {
          "wildcard": {
            "subject.keyword": "*맞바람*"
          }
        }
      ]
    }
  }
}
```

실측 결과

| 문서                           | _score | 걸린 should                | 계산           |
|------------------------------|--------|--------------------------|--------------|
| 맞바람                          | 3.79   | term + prefix + wildcard | 1.79+1.0+1.0 |
| 맞바람 외전 / 맞바람 시즌2 / 맞바람 1기 외전 | 2.0    | prefix + wildcard        | 1.0+1.0      |
| [개정판] 맞바람 / 어느 날의 맞바람        | 1.0    | wildcard                 | 1.0          |

## match 의 operator (or/and)

---

match 는 검색어를 analyzer 로 쪼갠 뒤, 토큰들을 **어떻게 조합할지** operator 로 정한다.

- `or`(기본값) : 토큰 중 **하나라도** 있으면 매칭
- `and` : 토큰이 **전부** 있어야 매칭

```json
{
  "query": {
    "match": {
      "subject.korean": {
        "query": "맞 바람",
        "operator": "and"
      }
    }
  }
}
```

| operator | 봄바람                |
|----------|--------------------|
| or (기본)  | ✅ 포함 ([바람] 하나로 충분) |
| and      | ❌ 탈락 ([맞] 이 없음)    |

```text
operator 는 "쪼개진 토큰 사이" 의 AND/OR 이고,
bool 의 must/should 는 "쿼리(조건) 사이"의 AND/OR 이다.
```
