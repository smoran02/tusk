# File System Size Comparison

Each container was built and then it was exported as a tar archive in July 2025.

77 MB base-noble.tar - bare Ubuntu noble container
1.2 GB silkeh-clang.tar - Debian image with clang/LLVM
808M  24-noble-small-tusk-everything.tar
636M  24-noble-small-tusk-nogfxmgck.tar
557M  24-noble-small-tusk-onlyclangwutils.tar
454M  24-noble-small-tusk-onlyclang.tar
77M base-noble.tar - bare Ubuntu noble container
77M 24-noble-small-tusk-useronly.tar
77M 24-noble-small-tusk-updateonly.tar
1.3G  silkeh-clang.tar - Debian image with clang/LLVM

## Finding Candidates to Remove
```bash
tar tvf 24-noble-small-tusk-onlyclang.tar  | awk '{print $3 " " $6}' > 24-noble-small-tusk-onlyclang.toc
tar tvf base-noble.tar | awk '{print $3 " " $6}' > base-noble.toc
```
## Analysis

`toc_compare.py` looks for files that were added to the base image and then estimates how much disk space those files take up.
```bash
./toc_compare.py base-noble.toc 24-noble-small-tusk-onlyclang.toc  
```

## Helper functions
```bash
function dbuild () {
  CONTAINERTAG=$1
  docker buildx build --quiet --tag ${CONTAINERTAG} --file ${CONTAINERTAG}.Dockerfile .
}

function dexp () {
  CONTAINERID=$2
  CONTAINERTAG=$1
  docker container export ${CONTAINERID} -o ${CONTAINERTAG}.tar
}

function g () {
  CONTAINERTAG=$1
  docker run -it --user tuffy ${CONTAINERTAG}
}
```