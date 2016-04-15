# prepare the environment
export $PATH=/urbantep/software/urbantep-dev/bin:$PATH
setup-example.sh

# test the software
cd example
mkdir wd
cd wd
../fmask-3.2/fmask-and-merge.sh /urbantep/eodata/LC8/v1/2014/07/03/LC81940272014184LGN00.tar.gz

# test the software inside a docker container
cd ~/example
mkdir -p wd
rm wd/*
cp /urbantep/eodata/LC8/v1/2014/07/03/LC81940272014184LGN00.tar.gz wd
echo "threshold=0.5" > wd/parameters
mkdir fmask-package-info
cp Dockerfile fmask-package-info
docker build -t urbancentos fmask-package-info
docker run -i -t --rm=true -v /urbantep/software/snap-2.0.2:/urbantep/software/snap-2.0.2 -v /urbantep/software/mcr_root-v81:/urbantep/software/mcr_root-v81 -v $(pwd)/wd:/wd -v $(pwd)/fmask-3.2:/urbantep-fmask-3.2 urbancentos /urbantep-fmask-3.2/fmask-and-merge.sh /wd/LC81940272014184LGN00.tar.gz /wd/parameters

# package the software
package-bc.sh

# upload the software
upload-bc.sh

# check if the software has been successfully deployed in the processing center (by sending a Describe Process request)
describeProcess-bc.sh