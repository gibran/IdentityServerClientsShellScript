client_id='<CLIENT_ID>'
client_secret='<SECRETE>'
scope='<SCOPE>'
	
urlToken='<URL_TOKEN>'
urlApi='<URL_API>'

dataJSON="{ }"

echo "Authenticating in:"
echo "$urlToken?client_id=$client_id&scope=$scope"

auth_result=$(curl -k -s $urlToken \
	-H "Content-Type: application/x-www-form-urlencoded" \
	-d scope=$scope \
	-d client_id=$client_id \
	-d client_secret=$client_secret \
	-d grant_type=client_credentials)

access_token=$(echo -e "$auth_result" | \
			grep -Po '"access_token" *: *.*?[^\\]",' | \
			awk -F'"' '{ print $4 }')

if [ -n "$access_token" ]; then	
	data_result=$(curl -X POST -s $urlApi \
	-H "Content-Type: application/json; charset=utf-8" \
	-H "Accept: application/json" -H "Authorization: Bearer $access_token" \
	-d "$dataJSON")
	
	echo "Result: $data_result"
else 
	echo "Not Authenticated."
fi
