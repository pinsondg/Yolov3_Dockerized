FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

ENV AWS_ACCESS_KEY_ID 
ENV AWS_SECRET_ACCESS_KEY

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
&& dpkg-reconfigure --frontend noninteractive tzdata

RUN \
	apt-get install -qq -y \
  autoconf \
  automake \
	libtool \
	build-essential \
	git \
  awscli \
  unzip \
  vim
  #nvidia-driver-418

RUN git clone https://github.com/pinsondg/darknet.git ~/darknet && \
    cd ~/darknet && \
    sed -i 's/GPU=0/GPU=1/g' ~/darknet/Makefile && \
    sed -i 's/CUDNN=0/CUDNN=1/g' ~/darknet/Makefile

# test nvidia docker
#RUN nvidia-smi -q

RUN mkdir ~/darknet/train-data && \
aws s3 cp s3://pothole-neural-network-training-data/configFiles/obj.data ~/darknet/cfg/ && \
aws s3 cp s3://pothole-neural-network-training-data/configFiles/obj.names ~/darknet/cfg/ && \
aws s3 cp s3://pothole-neural-network-training-data/configFiles/process.py ~/darknet/ && \
aws s3 cp s3://pothole-neural-network-training-data/configFiles/DownloadAndStart.sh /usr/local/bin/ && \
aws s3 cp s3://pothole-neural-network-training-data/configFiles/darknet53.conv.74 ~/darknet/ && \
ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat

# defaults command
CMD ["/bin/bash", "DownloadAndStart.sh", "darknet53.conv.74"]
