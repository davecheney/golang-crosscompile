# golang-crosscompile

See http://dave.cheney.net/2012/09/08/an-introduction-to-cross-compilation-with-go (the directions there are
slightly outdated).

## Usage

Clone the repo somewhere:

    $ git clone git://github.com/davecheney/golang-crosscompile.git

In your `.bashrc`/`.zshrc`/rc-file-of-choice, add the following (and then open a new terminal or `exec
$SHELL`):

    source <(bash path/to/golang-crosscompile/crosscompile.bash)

**Note that should *not* source the file directly; you should run the file and source the output.**

Do this once to set up your crosscompile environment:

    $ cd $GOROOT/src
    $ ./all.bash                # do this once (each time you update go)
    $ go-crosscompile-build-all # Build go for every platform/architecture combination
    # Alternatively, just build for a particular target if you're in a hurry
    $ go-crosscompile-build-windows-amd64

Now you can crosscompile your project using `go-${OS}-${ARCH}` instead of `go`:

    $ go-linux-arm build
