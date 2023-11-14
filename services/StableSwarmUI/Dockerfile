FROM mcr.microsoft.com/dotnet/sdk:7.0-bookworm-slim

# Install python and other stuff
RUN apt update
RUN apt install -y git wget build-essential python3.11 python3.11-venv git curl

WORKDIR /

COPY entrypoint.sh /entrypoint.sh

RUN git clone https://github.com/Stability-AI/StableSwarmUI.git && \
  cd StableSwarmUI && \
  git reset --hard 150e563e2c5dc63c8b1c4cbca743457936a7d500

ENV ROOT=/StableSwarmUI

# Set the run file to the launch script
ENTRYPOINT ["bash", "entrypoint.sh"]