FROM nvidia/cuda:12.2.0-base-ubuntu22.04
ENV DEBIAN_FRONTEND noninteractive

COPY entrypoint.sh /entrypoint.sh
COPY mount.sh /mount.sh

RUN --mount=type=cache,target=/var/cache/apt apt-get update -y && \
        apt-get full-upgrade -y && \
        apt-get install -y aria2 libgl1 libglib2.0-0 wget git git-lfs python3-pip python-is-python3 && \
        pip install -q torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2+cu118 torchtext==0.15.2 torchdata==0.6.1 --extra-index-url https://download.pytorch.org/whl/cu118 && \
        pip install xformers==0.0.20 triton==2.0.0 packaging==23.1 pygit2==1.12.2

RUN git clone https://github.com/MoonRide303/Fooocus-MRE /fooocus-ai && \
    cd /fooocus-ai && \
    git reset --hard

ENV ROOT=/fooocus-ai

RUN mkdir -p /cleanConfig/prompt_expansio && \
    cp -r -f -v ${ROOT}/models/prompt_expansion/* /cleanConfig/prompt_expansio &&\
    cp -r -f -v ${ROOT}/settings-example.json /cleanConfig/settings.json

WORKDIR ${ROOT}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""

ENTRYPOINT ["/entrypoint.sh"]
CMD cd /fooocus-ai && python entry_with_update.py --listen ${CLI_ARGS}