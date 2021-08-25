FROM cimg/base:stable

LABEL author="github.com/kelvintaywl"

WORKDIR /home/circleci

COPY orb-version-check.sh /tmp/
COPY curl_payload.json /tmp/

CMD /tmp/orb-version-check.sh
