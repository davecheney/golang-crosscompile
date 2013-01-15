#!/bin/bash
# Copyright 2012 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

PLATFORMS="darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm windows/386 windows/amd64"

eval "$(go env)"

function cgo-enabled {
	if [ "$1" = "${GOHOSTOS}" ]; then
		if [ "${GOHOSTOS}" != "freebsd/arm" ]; then
			echo 1
		else
			# cgo is not freebsd/arm
			echo 0	
		fi
	else 
		echo 0
	fi
}

function go-alias {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	eval "function go-${GOOS}-${GOARCH} { (CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} go \$@ ) }"
}

function go-crosscompile-build {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	cd ${GOROOT}/src ; CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}

function go-crosscompile-build-all {
	for PLATFORM in $PLATFORMS; do
		CMD="go-crosscompile-build ${PLATFORM}"
		echo "$CMD"
		$CMD >/dev/null
	done
}	

function go-all {
	for PLATFORM in $PLATFORMS; do
		GOOS=${PLATFORM%/*}
		GOARCH=${PLATFORM#*/}
		CMD="go-${GOOS}-${GOARCH} $@"
		echo "$CMD"
		$CMD
	done
}

for PLATFORM in $PLATFORMS; do
	go-alias $PLATFORM
done

unset -f go-alias
