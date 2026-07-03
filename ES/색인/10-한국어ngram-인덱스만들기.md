# ngram 인덱스 직접 만들기

---

## title-group-meta 를 만들어보자.

---

`PUT /title-group-meta`

```json
{
  "settings": {
    "index.max_ngram_diff": 5,
    "analysis": {
      "tokenizer": {
        "ngram_tokenizer": {
          "type": "ngram",
          "min_gram": 2,
          "max_gram": 5
        }
      },
      "analyzer": {
        "ngram_analyzer": {
          "tokenizer": "ngram_tokenizer",
          "filter": [
            "lowercase"
          ]
        },
        "korean": {
          "type": "custom",
          "tokenizer": "nori_tokenizer",
          "filter": [
            "lowercase"
          ]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "subject": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword",
            "ignore_above": 256
          },
          "korean": {
            "type": "text",
            "analyzer": "korean"
          },
          "ngram": {
            "type": "text",
            "analyzer": "ngram_analyzer",
            "search_analyzer": "standard"
          }
        }
      }
    }
  }
}
```

## korean vs ngram _analyze 비교

---

**[개정판] 맞바람** 색인 시

- korean(nori) : [개정, 판, 맞, 바람] - 4개, 부호/공백 제거된 의미 단위
- ngram : [개, [개정, [개정판, ... - 26개, 대괄호/공백까지 포함

## 검색어 "맞바람"이 필드별로 잡는 것

---

| 문서 | keyword | korean | ngram |
| --- | --- | --- | --- |
| 맞바람 | ✅ | ✅ | ✅ |
| [개정판] 맞바람 | ❌ | ✅ | ✅ |
| 맞 바람 | ❌ | ✅ | ❌(공백) |
| 봄바람 | ❌ | ⚠️노이즈 | ❌ |