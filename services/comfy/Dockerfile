FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git gcc g++ ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential fonts-dejavu-core rsync git jq moreutils aria2 && apt-get clean

ENV ROOT=/stable-diffusion

RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout master && \
  pip install -r requirements.txt

WORKDIR ${ROOT}
ADD https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth \
  ${ROOT}/models/vae_approx/taesd_decoder.pth

ADD https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth \
  ${ROOT}/models/vae_approx/taesdxl_decoder.pth

RUN --mount=type=cache,target=/root/.cache/pip \
  git fetch && \
  git checkout ${BRANCH} && \
  pip install -r requirements.txt && \
  pip install opencv-python

COPY . /docker/
RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml ${ROOT}

ENV NVIDIA_VISIBLE_DEVICES=all PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""

RUN conda install cuda-nvcc -c nvidia --update-all -y

EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
