FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git gcc g++ ffmpeg libsm6 libxext6 libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential fonts-dejavu-core rsync git jq moreutils aria2 && apt-get clean

ENV ROOT=/stable-diffusion
ENV CUDA_HOME=/opt/conda

RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
  cd ${ROOT} && \
  git checkout master && \
  pip install -r requirements.txt

RUN mkdir -vp /CLEAN_CONFIG/web/extensions
RUN cp -r -f -v ${ROOT}/web/extensions/* /CLEAN_CONFIG/web/extensions
RUN rm -rf ${ROOT}/web/extensions/

WORKDIR ${ROOT}

ADD https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth \
  ${ROOT}/models/vae_approx/taesd_decoder.pth

ADD https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth \
  ${ROOT}/models/vae_approx/taesdxl_decoder.pth

RUN --mount=type=cache,target=/root/.cache/pip \
  echo "[INSTALL] Installing 'Openmim' and 'mmcv' this could take a bit..." \
  pip install opencv-python mmdet mmengine && \
  pip install -U openmim && \
  mim install mmcv insightface onnxruntime-gpu


COPY . /docker/
RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml ${ROOT}
RUN conda install -c nvidia cuda --no-update-deps -y

ENV NVIDIA_VISIBLE_DEVICES=all 
ENV PYTHONPATH="${PYTHONPATH}:${PWD}" 
ENV CLI_ARGS=""

EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
