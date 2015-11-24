myCookie=~/.`basename $0`
cookie_is_valid=0

client_id='<CLIENT_ID>'
client_secret='<SECRETE>'
scope='<SCOPE>'
	
urlToken='<URL_TOKEN>'
urlApi='<URL_API>'

dataJSON="{ }"

echo "Authenticating in:"
echo "$urlToken?client_id=$client_id&scope=$scope"

if [ -f $myCookie ]; then #Validate Cookie
	. $myCookie
	time_now=`date +%s`
	
	if (( time_now < expires_at )); then cookie_is_valid=1; fi
fi

if !(( cookie_is_valid )); then
	#Renew Access Token
	
	auth_result=$(curl -k -s $urlToken \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d scope=$scope \
		-d client_id=$client_id \
		-d client_secret=$client_secret \
		-d grant_type=client_credentials)

	access_token=$(echo -e "$auth_result" | \
				grep -Po '"access_token" *: *.*?[^\\]",' | \
				awk -F'"' '{ print $4 }')

	expires_in=$(echo -e "$auth_result" | \
				grep -Po '"expires_in"*: *.*,' | \
				awk -F'"' '{ print $3 }' | \
				awk -F':' '{ print $2}' | \
				awk -F',' '{ print $1}' )
	time_now=`date +%s`

	expires_at=$((time_now + expires_in - 60))
	echo -e "access_token=$access_token\nexpires_at=$expires_at" > $myCookie
fi

if [ -n "$access_token" ]; then	
	data_result=$(curl -X POST -s $urlApi \
	-H "Content-Type: application/json; charset=utf-8" \
	-H "Accept: application/json" -H "Authorization: Bearer $access_token" \
	-d "$dataJSON")
	
	echo "Result: $data_result"
else 
	echo "Not Authenticated."
fi