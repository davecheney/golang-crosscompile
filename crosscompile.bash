#!/bin/bash
# Copyright 2012 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# support functions for go cross compilation

PLATFORMS="darwin/386 darwin/amd64 freebsd/386 freebsd/amd64 linux/386 linux/amd64 linux/arm windows/386 windows/amd64"

eval "$(go env)"

# Need to export GOROOT to the calling environment.
echo "export $(go env | grep GOROOT)"

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
	echo "
function go-${GOOS}-${GOARCH} {
	CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} go \$@
}"
	echo "
function go-crosscompile-build-${GOOS}-${GOARCH} {
	cd \${GOROOT}/src
	CGO_ENABLED=$(cgo-enabled ${GOOS} ${GOARCH}) GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}"
}

echo "
function go-crosscompile-build-all {
	for PLATFORM in $PLATFORMS; do
		GOOS=\${PLATFORM%/*}
		GOARCH=\${PLATFORM#*/}
		echo \"go-crosscompile-build-\${GOOS}-\${GOARCH}\"
		go-crosscompile-build-\${GOOS}-\${GOARCH} >/dev/null
	done
}
"

echo "
function go-all {
	for PLATFORM in $PLATFORMS; do
		GOOS=\${PLATFORM%/*}
		GOARCH=\${PLATFORM#*/}
		echo \"go-\${GOOS}-\${GOARCH} \$@\"
		go-\${GOOS}-\${GOARCH} \$@
	done
}
"

for PLATFORM in $PLATFORMS; do
	go-alias $PLATFORM
done
