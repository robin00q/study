# 점수(_score)

---

## _score 란?

---

- 검색 결과의 관련도 점수이다.
- 점수가 높을수록 검색 결과 위에 나온다.
- bool, match, term 같은 쿼리의 결과로 문서마다 계산된다.

## BM25 직관

---

- ES 는 기본적으로 `BM25` 라는 방식으로 _score 를 계산한다.
- `BM25` 는 검색어가 문서에 얼마나 의미 있게 들어있는지를 점수화한다.

**주요 기준**

1. 검색어가 문서에 있는가
2. 검색어가 문서 안에서 얼마나 자주 등장하는가
3. 그 검색어가 전체 문서 중 얼마나 희귀한가
4. 짧은 필드에서 맞았는가

## boost 란?

---

- 쿼리 점수에 곱하는 가중치이다.
- 어떤 조건을 더 중요하게 볼지 조정할 때 사용한다.

## 쿼리별 점수 계산 방식

| 쿼리           | 기본 점수 방식           | 예시 값       | 특징                         |
|--------------|--------------------|------------|----------------------------|
| term         | BM25 기반 점수         | 1.xxxxx    | 정확한 term 이 얼마나 희귀한지 등이 반영됨 |
| match        | BM25 기반 점수         | 1.xxxxx    | 검색어를 분석한 뒤 text 필드와 비교     |
| match_phrase | BM25 기반 점수 + 위치 조건 | 1.xxxxx    | 토큰 순서/인접 조건까지 봄            |
| prefix       | constant score     | 1.0        | 패턴에 맞으면 동일 점수처럼 나옴         |
| wildcard     | constant score        | 1.0        | 패턴에 맞으면 동일 점수처럼 나옴         |
| bool         | 내부 쿼리 점수 합산        | 합산값        | must/should 점수를 더함         |
| filter       | 점수 계산 안 함          | 0 또는 영향 없음 | 통과/탈락만 판단                  |

> prefix / wildcard 가 항상 1.0 이라는 뜻은 아니다. 
> 기본 rewrite 방식에서 constant score 계열로 동작해 이번 실습에서는 1.0 으로 나온 것이다.

## term / prefix / wildcard 기본 점수

---

**term - 완전일치**

```json
{
  "query": {
    "term": {
      "subject.keyword": "맞바람"
    }
  }
}
```

| 문서  | _score    |
|-----|-----------|
| 맞바람 | 1.7917595 |

**prefix - 전방일치**

```json
{
  "query": {
    "prefix": {
      "subject.keyword": "맞바람"
    }
  }
}
```

| 문서        | _score |
|-----------|--------|
| 맞바람       | 1.0    |
| 맞바람 외전    | 1.0    |
| 맞바람 시즌2   | 1.0    |
| 맞바람 1기 외전 | 1.0    |

**wildcard - 포함일치**

```json
{
  "query": {
    "wildcard": {
      "subject.keyword": "*맞바람*"
    }
  }
}
```

| 문서        | _score |
|-----------|--------|
| 맞바람       | 1.0    |
| [개정판] 맞바람 | 1.0    |
| 맞바람 외전    | 1.0    |
| 맞바람 시즌2   | 1.0    |
| 어느 날의 맞바람 | 1.0    |
| 맞바람 1기 외전 | 1.0    |

## should 로 합쳤을때

---

```json
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "subject.keyword": {
              "value": "맞바람",
              "_name": "term"
            }
          }
        },
        {
          "prefix": {
            "subject.keyword": {
              "value": "맞바람",
              "_name": "prefix"
            }
          }
        },
        {
          "wildcard": {
            "subject.keyword": {
              "value": "*맞바람*",
              "_name": "wildcard"
            }
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

| 문서                           | 걸린 should                | 계산                    | _score    |
|------------------------------|--------------------------|-----------------------|-----------|
| 맞바람                          | term + prefix + wildcard | 1.7917595 + 1.0 + 1.0 | 3.7917595 |
| 맞바람 외전 / 맞바람 시즌2 / 맞바람 1기 외전 | prefix + wildcard        | 1.0 + 1.0             | 2.0       |
| [개정판] 맞바람 / 어느 날의 맞바람        | wildcard                 | 1.0                   | 1.0       |

## boost 100/10/1 적용

---

```json
{
  "query": {
    "bool": {
      "should": [
        {
          "term": {
            "subject.keyword": {
              "value": "맞바람",
              "boost": 100,
              "_name": "term"
            }
          }
        },
        {
          "prefix": {
            "subject.keyword": {
              "value": "맞바람",
              "boost": 10,
              "_name": "prefix"
            }
          }
        },
        {
          "wildcard": {
            "subject.keyword": {
              "value": "*맞바람*",
              "boost": 1,
              "_name": "wildcard"
            }
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}
```

| 문서                           | 걸린 should                | 계산                                  | _score    |
|------------------------------|--------------------------|-------------------------------------|-----------|
| 맞바람                          | term + prefix + wildcard | 1.7917595 *100 + 1.0 * 10 + 1.0 * 1 | 190.17593 |
| 맞바람 외전 / 맞바람 시즌2 / 맞바람 1기 외전 | prefix + wildcard        | 1.0 * 10 + 1.0 * 1                  | 11.0      |
| [개정판] 맞바람 / 어느 날의 맞바람        | wildcard                 | 1.0 * 1                             | 1.0       |

## 정리

---

- boost 는 각 쿼리의 점수에 곱해지는 가중치이다.
- 따라서 boost 를 사용하면 특정 조건에 따라 순서로 정렬이 가능하다.