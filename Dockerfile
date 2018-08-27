FROM buildpack-deps:stretch-curl

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

RUN rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk8u162-b12_openj9-0.8.0

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       ppc64el|ppc64le) \
         ESUM='c985d22a58d43165561fa5c0c483acefb2afd407a6a0539da66d06d13c2af00c'; \
         JAVA_URL="https://api.adoptopenjdk.net/openjdk8-openj9/releases/ppc64le_linux/latest/binary"; \
         ;; \
       s390x) \
         ESUM='b1eb77b49ae94c77df1762d372897ff52d918c8a25ce8b6dcb9c18e9ad7a58db'; \
         JAVA_URL="https://api.adoptopenjdk.net/openjdk8-openj9/releases/s390x_linux/latest/binary"; \
         ;; \
       amd64|x86_64) \
         ESUM='4a90944fbe96cb6452391e952cc7c9b5136fb042a445eb205e31a029fd72fd7c'; \
         JAVA_URL="https://api.adoptopenjdk.net/openjdk8-openj9/releases/x64_linux/latest/binary"; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -Lso /tmp/openjdk.tar.gz ${JAVA_URL}; \
    echo "${ESUM}  /tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz; \
    jdir=$(dirname $(dirname $(find /opt/java/openjdk -name javac))); \
    mv ${jdir}/* /opt/java/openjdk; \
    rm -rf ${jdir} /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"
