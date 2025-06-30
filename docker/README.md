
# Working with Running Docker Containers
## Start an interactive session
```bash
docker run -it --user tuffy <image-name>
```

## List running containers
```bash
docker container ls
```

## To copy files
```bash
docker container cp cpsc-120-env-test <container-id>:/tmp
```

## To change permissions on files copied
```bash
docker exec -it --user root <container-id> /bin/bash
chown -R <username>:<groupname> <folder/file>
```

# Docker Command Line Tips

## List images
```bash
docker image ls
docker images
```

## Remove Build Cache
https://docs.docker.com/reference/cli/docker/builder/prune/
```bash
docker builder prune
docker builder prune --all
```

## Delete All Containers Including Its Volumes Use
```bash
docker rm -vf $(docker ps -aq)
```

## Delete All The Images
```bash
docker rmi -f $(docker images -aq)
```

## Remove All Unused Containers, Volumes, Networks And Images
```bash
docker system prune -a --volumes
```

## Delete Images
https://stackoverflow.com/questions/44785585/how-can-i-delete-all-local-docker-images
```bash
docker image prune -a
docker rmi $(docker images -a)
```

## Delete Containers Which Are In Exited State
```bash
docker rm $(docker ps -a -f status=exited -q)
```
What can be deleted from these packages?

adduser/now 3.137ubuntu1 all [installed,local]
apt-transport-https/now 2.8.3 all [installed,local]
apt/now 2.8.3 amd64 [installed,local]
autoconf/now 2.71-3 all [installed,local]
automake/now 1:1.16.5-1.3ubuntu1 all [installed,local]
autotools-dev/now 20220109.1 all [installed,local]
base-files/now 13ubuntu10.2 amd64 [installed,local]
base-passwd/now 3.6.3build1 amd64 [installed,local]
bash/now 5.2.21-2ubuntu4 amd64 [installed,local]
binutils-common/now 2.42-4ubuntu2.5 amd64 [installed,local]
binutils-x86-64-linux-gnu/now 2.42-4ubuntu2.5 amd64 [installed,local]
binutils/now 2.42-4ubuntu2.5 amd64 [installed,local]
bsdutils/now 1:2.39.3-9ubuntu6.2 amd64 [installed,local]
bzip2/now 1.0.8-5.1build0.1 amd64 [installed,local]
ca-certificates/now 20240203 all [installed,local]
clang-18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
clang-format-18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
clang-format/now 1:18.0-59~exp2 amd64 [installed,local]
clang-tidy-18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
clang-tidy/now 1:18.0-59~exp2 amd64 [installed,local]
clang-tools-18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
clang/now 1:18.0-59~exp2 amd64 [installed,local]
cmake-data/now 3.28.3-1build7 all [installed,local]
cmake/now 3.28.3-1build7 amd64 [installed,local]
coreutils/now 9.4-3ubuntu6 amd64 [installed,local]
dash/now 0.5.12-6ubuntu5 amd64 [installed,local]
debconf/now 1.5.86ubuntu1 all [installed,local]
debianutils/now 5.17build1 amd64 [installed,local]
diffutils/now 1:3.10-1build1 amd64 [installed,local]
dirmngr/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
dpkg-dev/now 1.22.6ubuntu6.1 all [installed,local]
dpkg/now 1.22.6ubuntu6.1 amd64 [installed,local]
e2fsprogs/now 1.47.0-2.4~exp1ubuntu4.1 amd64 [installed,local]
file/now 1:5.45-3build1 amd64 [installed,local]
findutils/now 4.9.0-5build1 amd64 [installed,local]
gcc-13-base/now 13.3.0-6ubuntu2~24.04 amd64 [installed,local]
gcc-14-base/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
gnupg-utils/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
gnupg2/now 2.4.4-2ubuntu17.2 all [installed,local]
gnupg/now 2.4.4-2ubuntu17.2 all [installed,local]
googletest/now 1.14.0-1 all [installed,local]
gpg-agent/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
gpg/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
gpgconf/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
gpgsm/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
gpgv/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
grep/now 3.11-4build1 amd64 [installed,local]
gzip/now 1.12-1ubuntu3 amd64 [installed,local]
hostname/now 3.23+nmu2ubuntu2 amd64 [installed,local]
init-system-helpers/now 1.66ubuntu1 all [installed,local]
keyboxd/now 2.4.4-2ubuntu17.2 amd64 [installed,local]
libacl1/now 2.3.2-1build1.1 amd64 [installed,local]
libapt-pkg6.0t64/now 2.8.3 amd64 [installed,local]
libarchive13t64/now 3.7.2-2ubuntu0.5 amd64 [installed,local]
libasan8/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libassuan0/now 2.5.6-1build1 amd64 [installed,local]
libatomic1/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libattr1/now 1:2.5.2-1build1.1 amd64 [installed,local]
libaudit-common/now 1:3.1.2-2.1build1.1 all [installed,local]
libaudit1/now 1:3.1.2-2.1build1.1 amd64 [installed,local]
libbinutils/now 2.42-4ubuntu2.5 amd64 [installed,local]
libblkid1/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
libbrotli1/now 1.1.0-2build2 amd64 [installed,local]
libbsd0/now 0.12.1-1build1.1 amd64 [installed,local]
libbz2-1.0/now 1.0.8-5.1build0.1 amd64 [installed,local]
libc-bin/now 2.39-0ubuntu8.4 amd64 [installed,local]
libc-dev-bin/now 2.39-0ubuntu8.4 amd64 [installed,local]
libc6-dev/now 2.39-0ubuntu8.4 amd64 [installed,local]
libc6/now 2.39-0ubuntu8.4 amd64 [installed,local]
libcap-ng0/now 0.8.4-2build2 amd64 [installed,local]
libcap2/now 1:2.66-5ubuntu2.2 amd64 [installed,local]
libclang-common-18-dev/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
libclang-cpp18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
libclang1-18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
libcom-err2/now 1.47.0-2.4~exp1ubuntu4.1 amd64 [installed,local]
libcrypt-dev/now 1:4.4.36-4build1 amd64 [installed,local]
libcrypt1/now 1:4.4.36-4build1 amd64 [installed,local]
libctf-nobfd0/now 2.42-4ubuntu2.5 amd64 [installed,local]
libctf0/now 2.42-4ubuntu2.5 amd64 [installed,local]
libcurl4t64/now 8.5.0-2ubuntu10.6 amd64 [installed,local]
libdb5.3t64/now 5.3.28+dfsg2-7 amd64 [installed,local]
libdebconfclient0/now 0.271ubuntu3 amd64 [installed,local]
libdpkg-perl/now 1.22.6ubuntu6.1 all [installed,local]
libedit2/now 3.1-20230828-1build1 amd64 [installed,local]
libexpat1/now 2.6.1-2ubuntu0.3 amd64 [installed,local]
libext2fs2t64/now 1.47.0-2.4~exp1ubuntu4.1 amd64 [installed,local]
libffi8/now 3.4.6-1build1 amd64 [installed,local]
libgc1/now 1:8.2.6-1build1 amd64 [installed,local]
libgcc-13-dev/now 13.3.0-6ubuntu2~24.04 amd64 [installed,local]
libgcc-s1/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libgcrypt20/now 1.10.3-2build1 amd64 [installed,local]
libgdbm-compat4t64/now 1.23-5.1build1 amd64 [installed,local]
libgdbm6t64/now 1.23-5.1build1 amd64 [installed,local]
libgmock-dev/now 1.14.0-1 amd64 [installed,local]
libgmp10/now 2:6.3.0+dfsg-2ubuntu6.1 amd64 [installed,local]
libgnutls30t64/now 3.8.3-1.1ubuntu3.3 amd64 [installed,local]
libgomp1/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libgpg-error0/now 1.47-3build2.1 amd64 [installed,local]
libgprofng0/now 2.42-4ubuntu2.5 amd64 [installed,local]
libgssapi-krb5-2/now 1.20.1-6ubuntu2.6 amd64 [installed,local]
libgtest-dev/now 1.14.0-1 amd64 [installed,local]
libhogweed6t64/now 3.9.1-2.2build1.1 amd64 [installed,local]
libhwasan0/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libicu74/now 74.2-1ubuntu3.1 amd64 [installed,local]
libidn2-0/now 2.3.7-2build1.1 amd64 [installed,local]
libitm1/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libjansson4/now 2.14-2build2 amd64 [installed,local]
libjsoncpp25/now 1.9.5-6build1 amd64 [installed,local]
libk5crypto3/now 1.20.1-6ubuntu2.6 amd64 [installed,local]
libkeyutils1/now 1.6.3-3build1 amd64 [installed,local]
libkrb5-3/now 1.20.1-6ubuntu2.6 amd64 [installed,local]
libkrb5support0/now 1.20.1-6ubuntu2.6 amd64 [installed,local]
libksba8/now 1.6.6-1build1 amd64 [installed,local]
libldap2/now 2.6.7+dfsg-1~exp1ubuntu8.2 amd64 [installed,local]
libllvm18/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
liblsan0/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
liblz4-1/now 1.9.4-1build1.1 amd64 [installed,local]
liblzma5/now 5.6.1+really5.4.5-1ubuntu0.2 amd64 [installed,local]
libmagic-mgc/now 1:5.45-3build1 amd64 [installed,local]
libmagic1t64/now 1:5.45-3build1 amd64 [installed,local]
libmd0/now 1.1.0-2build1.1 amd64 [installed,local]
libmount1/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
libncursesw6/now 6.4+20240113-1ubuntu2 amd64 [installed,local]
libnettle8t64/now 3.9.1-2.2build1.1 amd64 [installed,local]
libnghttp2-14/now 1.59.0-1ubuntu0.2 amd64 [installed,local]
libnpth0t64/now 1.6-3.1build1 amd64 [installed,local]
libobjc-13-dev/now 13.3.0-6ubuntu2~24.04 amd64 [installed,local]
libobjc4/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libp11-kit0/now 0.25.3-4ubuntu2.1 amd64 [installed,local]
libpam-modules-bin/now 1.5.3-5ubuntu5.1 amd64 [installed,local]
libpam-modules/now 1.5.3-5ubuntu5.1 amd64 [installed,local]
libpam-runtime/now 1.5.3-5ubuntu5.1 all [installed,local]
libpam0g/now 1.5.3-5ubuntu5.1 amd64 [installed,local]
libpcre2-8-0/now 10.42-4ubuntu2.1 amd64 [installed,local]
libperl5.38t64/now 5.38.2-3.2ubuntu0.1 amd64 [installed,local]
libproc2-0/now 2:4.0.4-4ubuntu3.2 amd64 [installed,local]
libpsl5t64/now 0.21.2-1.1build1 amd64 [installed,local]
libpython3-stdlib/now 3.12.3-0ubuntu2 amd64 [installed,local]
libpython3.12-minimal/now 3.12.3-1ubuntu0.7 amd64 [installed,local]
libpython3.12-stdlib/now 3.12.3-1ubuntu0.7 amd64 [installed,local]
libquadmath0/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libreadline8t64/now 8.2-4build1 amd64 [installed,local]
librhash0/now 1.4.3-3build1 amd64 [installed,local]
librtmp1/now 2.4+20151223.gitfa8646d.1-2build7 amd64 [installed,local]
libsasl2-2/now 2.1.28+dfsg1-5ubuntu3.1 amd64 [installed,local]
libsasl2-modules-db/now 2.1.28+dfsg1-5ubuntu3.1 amd64 [installed,local]
libseccomp2/now 2.5.5-1ubuntu3.1 amd64 [installed,local]
libselinux1/now 3.5-2ubuntu2.1 amd64 [installed,local]
libsemanage-common/now 3.5-1build5 all [installed,local]
libsemanage2/now 3.5-1build5 amd64 [installed,local]
libsepol2/now 3.5-2build1 amd64 [installed,local]
libsframe1/now 2.42-4ubuntu2.5 amd64 [installed,local]
libsmartcols1/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
libsqlite3-0/now 3.45.1-1ubuntu2.3 amd64 [installed,local]
libss2/now 1.47.0-2.4~exp1ubuntu4.1 amd64 [installed,local]
libssh-4/now 0.10.6-2build2 amd64 [installed,local]
libssl3t64/now 3.0.13-0ubuntu3.5 amd64 [installed,local]
libstdc++-13-dev/now 13.3.0-6ubuntu2~24.04 amd64 [installed,local]
libstdc++6/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libsystemd0/now 255.4-1ubuntu8.6 amd64 [installed,local]
libtasn1-6/now 4.19.0-3ubuntu0.24.04.1 amd64 [installed,local]
libtinfo6/now 6.4+20240113-1ubuntu2 amd64 [installed,local]
libtsan2/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libubsan1/now 14.2.0-4ubuntu2~24.04 amd64 [installed,local]
libudev1/now 255.4-1ubuntu8.6 amd64 [installed,local]
libunistring5/now 1.1-2build1.1 amd64 [installed,local]
libuuid1/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
libuv1t64/now 1.48.0-1.1build1 amd64 [installed,local]
libxml2/now 2.9.14+dfsg-1.3ubuntu3.3 amd64 [installed,local]
libxxhash0/now 0.8.2-2build1 amd64 [installed,local]
libyaml-0-2/now 0.2.5-1build1 amd64 [installed,local]
libzstd1/now 1.5.5+dfsg2-2build1.1 amd64 [installed,local]
linux-libc-dev/now 6.8.0-62.65 amd64 [installed,local]
llvm-18-linker-tools/now 1:18.1.3-1ubuntu1 amd64 [installed,local]
login/now 1:4.13+dfsg1-4ubuntu3.2 amd64 [installed,local]
logsave/now 1.47.0-2.4~exp1ubuntu4.1 amd64 [installed,local]
lto-disabled-list/now 47 all [installed,local]
m4/now 1.4.19-4build1 amd64 [installed,local]
make/now 4.3-4.1build2 amd64 [installed,local]
mawk/now 1.3.4.20240123-1build1 amd64 [installed,local]
media-types/now 10.1.0 all [installed,local]
mount/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
ncurses-base/now 6.4+20240113-1ubuntu2 all [installed,local]
ncurses-bin/now 6.4+20240113-1ubuntu2 amd64 [installed,local]
netbase/now 6.4 all [installed,local]
openssl/now 3.0.13-0ubuntu3.5 amd64 [installed,local]
passwd/now 1:4.13+dfsg1-4ubuntu3.2 amd64 [installed,local]
patch/now 2.7.6-7build3 amd64 [installed,local]
perl-base/now 5.38.2-3.2ubuntu0.1 amd64 [installed,local]
perl-modules-5.38/now 5.38.2-3.2ubuntu0.1 all [installed,local]
perl/now 5.38.2-3.2ubuntu0.1 amd64 [installed,local]
pinentry-curses/now 1.2.1-3ubuntu5 amd64 [installed,local]
procps/now 2:4.0.4-4ubuntu3.2 amd64 [installed,local]
python3-minimal/now 3.12.3-0ubuntu2 amd64 [installed,local]
python3-pexpect/now 4.9-2 all [installed,local]
python3-ptyprocess/now 0.7.0-5 all [installed,local]
python3-yaml/now 6.0.1-2build2 amd64 [installed,local]
python3.12-minimal/now 3.12.3-1ubuntu0.7 amd64 [installed,local]
python3.12/now 3.12.3-1ubuntu0.7 amd64 [installed,local]
python3/now 3.12.3-0ubuntu2 amd64 [installed,local]
readline-common/now 8.2-4build1 all [installed,local]
rpcsvc-proto/now 1.4.2-0ubuntu7 amd64 [installed,local]
sed/now 4.9-2build1 amd64 [installed,local]
sensible-utils/now 0.0.22 all [installed,local]
sysvinit-utils/now 3.08-6ubuntu3 amd64 [installed,local]
tar/now 1.35+dfsg-3build1 amd64 [installed,local]
tzdata/now 2025b-0ubuntu0.24.04.1 all [installed,local]
ubuntu-keyring/now 2023.11.28.1 all [installed,local]
unminimize/now 0.2.1 amd64 [installed,local]
util-linux/now 2.39.3-9ubuntu6.2 amd64 [installed,local]
wget/now 1.21.4-1ubuntu4.1 amd64 [installed,local]
xz-utils/now 5.6.1+really5.4.5-1ubuntu0.2 amd64 [installed,local]
zlib1g/now 1:1.3.dfsg-3.1ubuntu2.1 amd64 [installed,local]
