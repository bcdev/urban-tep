#!/bin/sh

# This is a script to send initial request to upload a custom software to calvalus

SOFTWARE_PATH=$1
FILE_NAME=`echo $SOFTWARE_PATH | awk -F'[/\\\\\\\\]' '{print $NF}'`

# Server configuration
# =========================
SERVER_NAME="urbantep-test"
SERVER_PORT="8080"

read -p "Enter User Name: " USER
read -s -p "Enter Password: " PASSWORD
printf "\n"

# Store the software bundle as a single file
cat $SOFTWARE_PATH > req-part2

#sed "s/FILE_NAME/$FILE_NAME/" req-part1 > payload-header
FILE_SIZE=`cat req-part1 req-part2 req-part3 | wc | awk '{print $3}'`
echo "file size : "$FILE_SIZE

echo "POST /calvalus/calvalus/upload?dir=software&bundle=true HTTP/1.1
Host: urbantep-test:8080
Connection: keep-alive
Content-Length: ${FILE_SIZE}
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://urbantep-test:8080
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: multipart/form-data; boundary=----WebKitFormBoundarycAADyutAUJBAZVds
Referer: http://urbantep-test:8080/calvalus/calvalus.jsp
Accept-Encoding: gzip, deflate
Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4
Cookie: JSESSIONID=C8F8273BED9B871B5C66CCECD8FE14FA
" > req-header

cat req-header req-part1 req-part2 req-part3 > req-complete

cat req-complete | nc $SERVER_NAME $SERVER_PORT > unauth-response

SESSION_ID=`awk -F"=" '{if ($1 == "Set-Cookie: JSESSIONID") {print $2}}' unauth-response | cut -d';' -f 1`

echo "POST /calvalus/j_security_check HTTP/1.1
Host: urbantep-test:8080
Connection: keep-alive
Content-Length: 52
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://urbantep-test:8080
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: application/x-www-form-urlencoded
Referer: http://urbantep-test:8080/calvalus/calvalus.jsp
Accept-Encoding: gzip, deflate
Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4
Cookie: JSESSIONID=${SESSION_ID}

j_username=${USER}&j_password=${PASSWORD}&submitBtn=Log+In" > req-auth

# Authenticate
cat req-auth | nc $SERVER_NAME $SERVER_PORT > auth-response

if grep -q "HTTP/1.1 302 Found" auth-response; then
	echo "Successful authentication"
else
	echo "Authentication for user '${USER}' failed"
fi

echo "POST /calvalus/calvalus/upload?dir=software&bundle=true HTTP/1.1
Host: urbantep-test:8080
Connection: keep-alive
Content-Length: ${FILE_SIZE}
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://urbantep-test:8080
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36
Content-Type: multipart/form-data; boundary=----WebKitFormBoundarycAADyutAUJBAZVds
Referer: http://urbantep-test:8080/calvalus/calvalus.jsp
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
fi

rm req-part2 auth-response req-auth req-complete req-header unauth-response upload-response