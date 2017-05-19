VM login
========

 o user urbanuser, password urbanuser
 o either via desktop (start terminal)
 o or via ssh
 o urbantep software pre-installed in /urbantep/

Example setup
=============

cd ~
rm -r example
/urbantep/software/urbantep-dev/bin/setup-example.sh
cd example
ls -l $(find . -type f)

Local processor test (without Docker)
=====================================

cd ~/example
mkdir -p wd
rm -r wd/*
cd wd
../fmask-3.2/fmask-and-merge.sh /urbantep/eodata/LC8/v1/2014/07/03/LC81940272014184LGN00.tar.gz

Local processor test (with Docker)
==================================

cd ~/example
mkdir -p wd
rm -rf wd/*
cd wd
mkdir fmask-package-info
cp ../Dockerfile fmask-package-info/
echo "threshold=0.5" > parameters
cp /urbantep/eodata/LC8/v1/2014/07/03/LC81940272014184LGN00.tar.gz .
docker build -t urbancentos fmask-package-info
docker run --rm=true -v /urbantep/software/snap-3.0.1:/urbantep/software/snap-3.0.1 -v /urbantep/software/mcr_root-v81:/urbantep/software/mcr_root-v81 -v /home/urbanuser/example/wd:/wd -v /home/urbanuser/example/fmask-3.2:/urbantep-fmask-3.2 -w /wd urbancentos /urbantep-fmask-3.2/fmask-and-merge.sh /wd/LC81940272014184LGN00.tar.gz /wd/parameters

Packaging and upload to processing centre
=========================================

cd ~/example
/urbantep/software/urbantep-dev/bin/package-bc.sh descriptor.xml
/urbantep/software/urbantep-dev/bin/upload-bc.sh descriptor.xml
/urbantep/software/urbantep-dev/bin/describeProcess-bc.sh descriptor.xml

Cleaning up
===========

cd ~
rm -r example
