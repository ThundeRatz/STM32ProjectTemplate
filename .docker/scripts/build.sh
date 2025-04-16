#!/bin/bash

BUILD_ARG=$1

rm -rf /project/build || exit 1
mkdir -p /project/build || exit 1
cd /project/build || exit 1
cmake .. -DBUILD_TYPE=Release $BUILD_ARG || exit 1

echo "Compiling main..." | sed 's/.*/\x1b[34m&\x1b[0m/'

make -j

if [ $? -eq 0 ]; then
  echo "Compilation successful." | sed 's/.*/\x1b[32m&\x1b[0m/'
else
  echo "Compilation failed." | sed 's/.*/\x1b[31m&\x1b[0m/'
  exit 1
fi

echo "Compiling tests..." | sed 's/.*/\x1b[34m&\x1b[0m/'

make test_all -j

if [ $? -eq 0 ]; then
  echo "Tests compiled successfully." | sed 's/.*/\x1b[32m&\x1b[0m/'
else
  echo "Tests compilation failed." | sed 's/.*/\x1b[31m&\x1b[0m/'
  exit 1
fi
