FROM livepeer/go-livepeer:jaliveingest as binary

FROM ubuntu:18.04
RUN apt-get update \
    && apt-get install -y software-properties-common gnutls-bin \
    && add-apt-repository ppa:graphics-drivers/ppa \
    && apt-get update

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -qy \
    libnvidia-compute-430 libnvidia-encode-430 libnvidia-decode-430 nvidia-driver-430

COPY --from=binary /usr/bin/livepeer /usr/bin/livepeer
COPY --from=binary /usr/bin/livepeer_cli /usr/bin/livepeer_cli

ENTRYPOINT ["/usr/bin/livepeer"]