#########################################################################################
# Micro XRCE-DDS Agent Docker
#########################################################################################
ARG MICRO_XRCE_DDS_AGENT_RELEASE="v2.4.1"
ARG HUSARNET_DDS_RELEASE="v1.3.6"

# Build stage
FROM ubuntu AS build

ARG MICRO_XRCE_DDS_AGENT_RELEASE
ENV DEBIAN_FRONTEND=noninteractive

# Essentials
RUN apt-get update
RUN apt-get install -y \
            software-properties-common \
            build-essential \
            cmake \
            git \
            curl

# Java
RUN apt install -y openjdk-8-jdk
ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64/"

# Gradle
RUN apt-get install -y gradle

RUN apt-get clean

# Prepare Micro XRCE-DDS Agent workspace
# RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git /agent
# RUN mkdir -p /agent/build
RUN curl -L https://github.com/eProsima/Micro-XRCE-DDS-Agent/archive/refs/tags/${MICRO_XRCE_DDS_AGENT_RELEASE}.tar.gz -o /MicroXRCEAgent.tar.gz && \
    tar -xzvf /MicroXRCEAgent.tar.gz && \
    mv /Micro-XRCE-DDS-Agent-* /agent && \
    mkdir -p /agent/build

# Build Micro XRCE-DDS Agent and install
RUN cd /agent/build && \
    cmake -DCMAKE_INSTALL_PREFIX=../install \
    .. &&\
    make -j $(nproc) && make install

ARG TARGETARCH
ARG HUSARNET_DDS_RELEASE
ENV HUSARNET_DDS_DEBUG=FALSE

RUN curl -L https://github.com/husarnet/husarnet-dds/releases/download/${HUSARNET_DDS_RELEASE}/husarnet-dds-linux-${TARGETARCH} -o /usr/bin/husarnet-dds

# =======================
# Final image
# =======================
FROM ubuntu:22.04

WORKDIR /root

COPY --from=build /agent/install/ /usr/local/
COPY --from=build /agent/agent.refs .
COPY entrypoint.sh /
COPY --from=build /usr/bin/husarnet-dds /usr/bin/husarnet-dds
RUN chmod +x /usr/bin/husarnet-dds

RUN ldconfig

ENTRYPOINT ["/entrypoint.sh"]
CMD ["MicroXRCEAgent --help"]