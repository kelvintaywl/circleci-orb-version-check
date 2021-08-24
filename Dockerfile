FROM cimg/base:stable

LABEL author="github.com/kelvintaywl"

COPY orb-version-check.sh ./
COPY curl_payload.json ./

CMD ./orb-version-check.sh
