FROM mcr.microsoft.com/dotnet/sdk:7.0-bookworm-slim

# Install python and other stuff
RUN apt update
RUN apt install -y git wget build-essential python3.11 python3.11-venv git curl

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY mount.sh /mount.sh

RUN git clone https://github.com/Stability-AI/StableSwarmUI.git && \
  cd StableSwarmUI && \
  git reset --hard 9975621dd51926c9e14ff96954a042eeac9917b6

ENV ROOT=/StableSwarmUI

# Set the run file to the launch script
ENTRYPOINT ["bash", "entrypoint.sh"]