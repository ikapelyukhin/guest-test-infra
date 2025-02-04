#!/bin/bash
# Copyright 2019 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

#export GOCOVPATH=/gocov.txt

BUILD_DIR=$1
if [[ -n $BUILD_DIR ]]; then
  cd $BUILD_DIR || exit 1
fi
shift

echo "Pulling Linux imports..."
go get -d -t ./... || exit 1
echo "Pulling Windows imports..."
GOOS=windows go get -d -t ./... || exit 1

go test -v -coverprofile=/coverage.out "$@" ./... >/go-test.txt
RET=$?
if [[ $RET -ne 0 ]]; then
  echo "go test -coverprofile=/coverage.out $@ ./... returned ${RET}"
fi
cp /go-test.txt ${ARTIFACTS}/

# $ARTIFACTS is provided by prow decoration containers
go tool cover -func=/coverage.out | grep ^total | awk '{print $NF}' | cut -d'.' -f1 > ${ARTIFACTS}/coverage.txt
cat /go-test.txt | go-junit-report > ${ARTIFACTS}/junit.xml

# Upload coverage results to Codecov.
#CODEV_COV_ARGS="-v -t $(cat ${CODECOV_TOKEN}) -B master -C $(git rev-parse HEAD)"
#
#if [[ ! -z "${PULL_NUMBER}" ]]; then
#  CODEV_COV_ARGS="${CODEV_COV_ARGS} -P ${PULL_NUMBER}"
#fi
#
#if [[ -e ${GOCOVPATH} ]]; then
#  bash <(curl -s https://codecov.io/bash) -f ${GOCOVPATH} -F go_unittests ${CODEV_COV_ARGS}
#fi

echo Done
exit "$RET"
