#!/bin/bash
# Copyright 2012 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

PLATFORMS="darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm windows/386 windows/amd64"

eval "$(go env)"

function cgo-enabled {
	if [ "$1" = "${GOHOSTOS}" ]; then
		echo 1
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

function go-build-all {
        for PLATFORM in $PLATFORMS; do
      		GOOS=${PLATFORM%/*}
        	GOARCH=${PLATFORM#*/}
                #TODO - check if basename should actually be the next non-option argv. Or warn.
                BASENAME=${PWD##*/}
                # if necessary, set GOBIN according to go's usual logic
                if [ -z "$GOBIN" ]; then
                  MYGOBIN="$GOPATH/bin"
                else
                  MYGOBIN="$GOBIN"
                fi
                #echo "GOBIN=$GOBIN"
                #MYGOBIN=${GOBIN:?"$GOPATH/bin"}
                echo "$MYGOBIN"
                # use a subfolder of GOBIN called xc
                OUTPUTDIR="${MYGOBIN}/xc/$BASENAME/$PLATFORM"
                if [ "$GOOS" == "windows" ]; then
                   BASENAME="$BASENAME.exe"
                fi
                CMD="go-${GOOS}-${GOARCH} build -o ${OUTPUTDIR}/${BASENAME} $@"
                MKDIRCMD="mkdir -p \"$OUTPUTDIR\""
                echo "Running: $MKDIRCMD"
                mkdir -p "$OUTPUTDIR"
                ls "$OUTPUTDIR"
                echo "Running: $CMD"
                $CMD
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
