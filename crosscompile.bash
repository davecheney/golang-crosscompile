#!/bin/bash
# Copyright 2012 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

PLATFORMS="darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 linux/386 linux/amd64 linux/arm windows/386 windows/amd64"

eval "$(go env)"
HOST_GOOS=${GOOS}
HOST_GOARCH=${GOARCH}

function cgo-enabled {
	if [ "$1" = "${HOST_GOOS}" ]; then 
		CGO_ENABLED=1
	else 
		CGO_ENABLED=0
	fi
}

function go-alias {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	eval "function go-${GOOS}-${GOARCH} { (CGO_ENABLED=$(cgo-enabled ${GOOS}) GOOS=${GOOS} GOARCH=${GOARCH} go \$@ ) }"
}

function go-crosscompile-build {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	OUTPUT=$(cd ${GOROOT}/src ; CGO_ENABLED=$(cgo-enabled ${GOOS}) GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1)
	if [ $? -ne 0 ] ; then
		echo "$OUTPUT" >&2
	fi
}

function go-crosscompile-build-all {
	set -e
	for PLATFORM in $PLATFORMS; do
		CMD="go-crosscompile-build ${PLATFORM}"
		echo $CMD
		$CMD
	done
}	

for PLATFORM in $PLATFORMS; do
	go-alias $PLATFORM
done

