#!/bin/bash

subfolder=${1}

for i in {0..9..1}
do
  x_test=$i
  x_val=$(((i+1)%10))
  echo $x_test $x_val
  cp salt/configs/${subfolder}/template.yaml salt/configs/${subfolder}/fold$i.yaml

  sed -i "s/foldX/fold$i/g" salt/configs/${subfolder}/fold$i.yaml

done
