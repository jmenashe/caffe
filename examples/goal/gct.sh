#!/usr/bin/env bash
cd $NAO_HOME/build
./compile tool --fast
$NAO_HOME/build/tool/goal_trainer --generate
cd ~/code/deep/caffe
build/tools/compute_image_mean /home/jake/nao/trunk/tools/trainers/datasets/goal_data/database-train /home/jake/nao/trunk/tools/trainers/datasets/goal_data/database-train-mean.binaryproto
examples/goal/train.sh

