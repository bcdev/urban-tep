#!/bin/bash

rootdir=$(dirname $(dirname $0))
descriptor=$1

if [ "$descriptor" = "" ] ; then
    echo "usage : $(basename $0) <descriptor file>"
    exit 1
fi

packagedir=$(dirname $descriptor)

packagename=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:name" $descriptor)
packageversion=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:version" $descriptor)

# This is a script to send initial request to upload a custom software to calvalus

SOFTWARE_PATH=urbantep-${packagename}-${packageversion}.zip
FILE_NAME=`echo $SOFTWARE_PATH | awk -F'[/\\\\\\\\]' '{print $NF}'`

# Server configuration
# =========================
SERVER_NAME="www.brockmann-consult.de"
SERVER_PORT="80"

read -p "Enter User Name: " BC_USER
read -s -p "Enter Password: " PASSWORD
printf "\n"

# Store the software bundle as a single file
cat $SOFTWARE_PATH > req-part2

echo -n "------WebKitFormBoundarycAADyutAUJBAZVds
Content-Disposition: form-data; name=\"bundleUpload\"; filename=\"${SOFTWARE_PATH}\"
Content-Type: application/x-zip-compressed

" > req-part1

echo -n "
------WebKitFormBoundarycAADyutAUJBAZVds--
" > req-part3

FILE_SIZE=`cat req-part1 ${SOFTWARE_PATH} req-part3 | wc -c`
echo "file size : "$FILE_SIZE

echo "POST /calvalus/calvalus/upload?dir=software&bundle=true HTTP/1.1
Host: www.brockmann-consult.de
Connection: keep-alive
Content-Length: ${FILE_SIZE}
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://localhost
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: multipart/form-data; boundary=----WebKitFormBoundarycAADyutAUJBAZVds
Referer: http://www.brockmann-consult.de/calvalus/calvalus.jsp
Accept-Encoding: gzip, deflate
Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4
" > req-header

cat req-header req-part1 ${SOFTWARE_PATH} req-part3 > req-complete

cat req-complete | nc $SERVER_NAME $SERVER_PORT > unauth-response

SESSION_ID=`awk -F"=" '{if ($1 == "Set-Cookie: JSESSIONID") {print $2}}' unauth-response | cut -d';' -f 1`

AUTH_PAYLOAD_SIZE=`echo -n "j_username=${BC_USER}&j_password=${PASSWORD}&submitBtn=Log+In" | wc -c`

echo "POST /calvalus/j_security_check HTTP/1.1
Host: www.brockmann-consult.de
Connection: keep-alive
Content-Length: ${AUTH_PAYLOAD_SIZE}
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://localhost
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: application/x-www-form-urlencoded
Referer: http://www.brockmann-consult.de/calvalus/calvalus.jsp
Accept-Encoding: gzip, deflate
Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4
Cookie: JSESSIONID=${SESSION_ID}

j_username=${BC_USER}&j_password=${PASSWORD}&submitBtn=Log+In" > req-auth

# Authenticate
cat req-auth | nc $SERVER_NAME $SERVER_PORT > auth-response

if grep -q "HTTP/1.1 302 Found" auth-response; then
	echo "Successful authentication"
else
	echo "Authentication for user '${BC_USER}' failed"
fi

echo "POST /calvalus/calvalus/upload?dir=software&bundle=true HTTP/1.1
Host: www.brockmann-consult.de
Connection: keep-alive
Content-Length: ${FILE_SIZE}
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://localhost
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: multipart/form-data; boundary=----WebKitFormBoundarycAADyutAUJBAZVds
Referer: http://www.brockmann-consult.de/calvalus/calvalus.jsp
Accept-Encoding: gzip, deflate
Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4
Cookie: JSESSIONID=${SESSION_ID}
" > req-header

cat req-header req-part1 req-part2 req-part3 > req-complete

cat req-complete | nc $SERVER_NAME $SERVER_PORT > upload-response

if grep -q "HTTP/1.1 202 Accepted" upload-response; then
	echo "Upload successful"
else
	echo "Upload failed"
	cat upload-response
fi

rm req-part1 req-part2 req-part3 auth-response req-auth req-complete req-header unauth-response upload-response
