FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update
RUN apt-get install -y libgl1 libglib2.0-0 libsm6 libxrender1 libxext6
RUN apt-get install -y git mc bash-completion rsync
RUN apt-get clean

RUN useradd -U -r -m -s /bin/bash comfy

USER comfy

WORKDIR /home/comfy

RUN git clone https://github.com/comfyanonymous/ComfyUI.git comfyui

ENV ROOT=/home/comfy/comfyui
ENV ROOT=${ROOT}
ENV COMFY_HOME=${ROOT}
ENV COMFYUI_PATH=${ROOT}

RUN pip install pandas && \
  pip install pydub && \
  pip install librosa && \
  pip install opencv-python && \
  pip install cython

WORKDIR ${ROOT}
RUN git checkout master
RUN --mount=type=cache,target=/home/ComfyUI/.cache/pip
RUN pip install -r requirements.txt

COPY ./comfy.entry.sh .
USER root
RUN chmod +x ./comfy.entry.sh
USER comfy

ENV NVIDIA_VISIBLE_DEVICES=all PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
EXPOSE 7870
ENTRYPOINT ["/home/comfy/comfyui/comfy.entry.sh"]
CMD python -u main.py --listen --port 7870 ${CLI_ARGS}
