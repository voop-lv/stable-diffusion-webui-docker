FROM nvidia/cuda:12.2.2-runtime-ubuntu22.04
FROM alpine/git:2.36.2 as download

COPY clone.sh /clone.sh

RUN . /clone.sh stable-diffusion-stability-ai https://github.com/Stability-AI/stablediffusion.git cf1d67a6fd5ea1aa600c4df58e5b47da45f6bdbf \
  && rm -rf assets data/**/*.png data/**/*.jpg data/**/*.gif

RUN . /clone.sh CodeFormer https://github.com/sczhou/CodeFormer.git 8392d0334956108ab53d9439c4b9fc9c4af0d66d \
  && rm -rf assets inputs

RUN . /clone.sh BLIP https://github.com/salesforce/BLIP.git 48211a1594f1321b00f14c9f7a5b4813144b2fb9
RUN . /clone.sh k-diffusion https://github.com/crowsonkb/k-diffusion.git 045515774882014cc14c1ba2668ab5bad9cbf7c0
RUN . /clone.sh clip-interrogator https://github.com/pharmapsychotic/clip-interrogator.git bc07ce62c179d3aab3053a623d96a071101d11cb
RUN . /clone.sh generative-models https://github.com/Stability-AI/generative-models.git 059d8e9cd9c55aea1ef2ece39abf605efb8b7cc9

FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN --mount=type=cache,target=/var/cache/apt \
  apt-get update && \
  # we need those
  apt-get install -y fonts-dejavu-core rsync git jq moreutils aria2 \
  # extensions needs those
  ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential g++ gcc

WORKDIR /
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/lllyasviel/Fooocus.git fooocus-app && \
  cd fooocus-app && \
  pip install -r requirements_versions.txt

ENV ROOT=/fooocus-app

COPY --from=download /repositories/ ${ROOT}/repositories/
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install -r ${ROOT}/repositories/CodeFormer/requirements.txt

RUN --mount=type=cache,target=/root/.cache/pip \
  pip install pyngrok xformers dctorch \
  git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 \
  git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 \
  git+https://github.com/mlfoundations/open_clip.git@91923dfc376afb9d44577a0c9bd0930389349438

RUN pip install open-clip-torch==2.20.0 

COPY . /docker

RUN \
  # mv ${ROOT}/style.css ${ROOT}/user.css && \
  # one of the ugliest hacks I ever wrote \
  sed -i 's/in_app_dir = .*/in_app_dir = True/g' /opt/conda/lib/python3.10/site-packages/gradio/routes.py && \
  git config --global --add safe.directory '*'

RUN \
  python3 -m venv fooocus_env \
  pip install -r requirements_versions.txt \
  source fooocus_env/bin/activate

WORKDIR ${ROOT}
ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]

