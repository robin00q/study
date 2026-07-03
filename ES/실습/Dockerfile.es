# ES 7.17.18 + analysis-nori(한국어 형태소) 플러그인 이미지
# 기본 이미지엔 nori가 없어서, 여기서 미리 설치해 구워둔다.
# → docker compose down 해도 플러그인이 이미지에 있으니 사라지지 않음.
FROM docker.elastic.co/elasticsearch/elasticsearch:7.17.18

# --batch : 설치 중 보안 권한 확인 프롬프트를 자동 승인
RUN bin/elasticsearch-plugin install --batch analysis-nori
