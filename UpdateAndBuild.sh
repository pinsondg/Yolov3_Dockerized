#!/bin/bash
set -e
echo Updating files on s3...
aws s3 cp darknet/cfg/obj.data s3://pothole-neural-network-training-data/configFiles/
aws s3 cp darknet/cfg/obj.names s3://pothole-neural-network-training-data/configFiles/
aws s3 cp DownloadAndStart.sh s3://pothole-neural-network-training-data/configFiles/
aws s3 cp process.py s3://pothole-neural-network-training-data/configFiles/
aws s3 cp darknet/cfg/yolov3_pothole.cfg s3://pothole-neural-network-training-data/configFiles/
#aws s3 cp darknet53.conv.74 s3://pothole-neural-network-training-data/configFiles/

echo Starting Docker Build...
docker build . -t pinsondg/yolov3_pothole:latest $1
#docker run -it pinsondg/yolov3_pothole:latest
