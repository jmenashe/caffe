#!/usr/bin/env bash
cd $NAO_HOME/build
./compile tool --fast
$NAO_HOME/build/tool/ball_deep_trainer --generate
cd ~/code/deep/caffe
build/tools/compute_image_mean /home/jake/nao/trunk/tools/trainers/datasets/ball_data/databases/database-train /home/jake/nao/trunk/tools/trainers/datasets/ball_data/databases/database-train-mean.binaryproto
examples/ball/train.sh

