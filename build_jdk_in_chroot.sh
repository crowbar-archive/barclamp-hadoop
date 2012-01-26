#!/bin/bash
cd /mnt/files/java
for f in jdk-*-rpm.bin; do
    sh "$f" -x
done

find . -type f -name 'jdk-*.rpm' -or -name 'jre-*.rpm' \
    -exec mv '{}' /mnt/current_os/pkgs ';'
rm *.rpm