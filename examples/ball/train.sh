#!/usr/bin/env sh
export GLOG_minloglevel=0
./build/tools/caffe train --solver=examples/ball/ball_solver.prototxt
