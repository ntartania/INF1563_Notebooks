#FROM openjdk:11.0.3-jdk
#FROM alpine:3.14
FROM openkbs/jdk-mvn-py3

USER root
RUN apt-get update
#RUN apt-get py3-pip
RUN python3 --version

RUN apt-get install -y build-essential libffi-dev libxml2-dev libxslt-dev zlib1g-dev python3-dev curl

# Download the kernel release
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

# Unpack and install the kernel
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Set up the user environment

ENV NB_USER jovyan
ENV NB_UID 1007
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER

COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER


RUN pip3 install wheel


# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir -r requirements.txt) \
        || pip3 install --no-cache-dir jupyter jupyterlab



# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
