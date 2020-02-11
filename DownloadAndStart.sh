#!/bin/bash
function _exit() {
  printf -v date '%(%Y-%m-%d)T\n' -1
  echo $date
  echo Uploading backups to s3...
  aws s3 sync ~/darknet/backup s3://pothole-neural-network-training-data/configFiles/backup/$date
}

trap _exit SIGTERM
echo Making Darknet...
cd ~/darknet
make -j"$(nproc)" && \
cp ~/darknet/include/* /usr/local/include && \
cp ~/darknet/*.a /usr/local/lib && \
cp ~/darknet/*.so /usr/local/lib && \
cp ~/darknet/darknet /usr/local/bin

echo Downloading images...
set -e
#Download Images
aws s3 cp s3://pothole-neural-network-training-data/trainingData.zip ~/darknet/train-data/
aws s3 cp s3://pothole-neural-network-training-data/configFiles/backup/yolov3_pothole_last.weights ~/darknet/backup/
aws s3 cp s3://pothole-neural-network-training-data/configFiles/yolov3_pothole.cfg ~/darknet/cfg/

#Unzip
echo Unzipping...
cd ~/darknet/train-data/ && unzip trainingData.zip
rm trainingData.zip

#Split into train/test data
cd ~/darknet/
python3 process.py

cat train.txt
cat test.txt

#Train darknet
echo Training using starting weights $1...
~/darknet/darknet detector train cfg/obj.data cfg/yolov3_pothole.cfg $1
