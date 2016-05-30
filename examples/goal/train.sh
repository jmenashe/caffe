#!/usr/bin/env sh
export GLOG_minloglevel=0
./build/tools/caffe train --solver=examples/goal/goal_solver.prototxt
