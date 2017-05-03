#!/bin/bash

#Manual Configuration
api_ver="5_1"    #R3.5 - 5.0
vscg_ip="10.128.0.2"
login_name="admin"
login_password="admin#111"
temp_cookie="/tmp/public-api-temp-cookies_${vscg_ip}"
create_domain_name="domain-test"
#zone_cnfig
zone_ap_login_name="admin"
zone_ap_login_pwd="admin#123"
zone_ap_version="3.5.1.100.166"
zone_country_code="US"
#wispr 
wispr_smart_client_support="None"                         #None or Enabled
wispr_location_id="wispr-location-id"                     #Optional, string
wispr_location_name="wispr-location-name"                 #Optional, string
list_domain_size="1100"
list_zone_size="1100"
test_limit_num="8"
test_zone_uuid="ea6c7834-4dc2-4ca9-9f62-a276bca76a88"
test_domain_uuid="d1d899b3-9362-4244-8d27-1adccb8fc7dd"
test_ap_entry="201703310001"                              #either AP serial num or AP MAC (kumo uses AP serial num)
test_client_mac="00:CC:C1:00:00:01"
pre_provision_ap_entry="321433201988"                              #either AP serial num or AP MAC (kumo uses AP serial num)
pre_provision_ap_model="R710"                              #either AP serial num or AP MAC (kumo uses AP serial num)
pre_provision_ap_name="Pre-Prov-AP"                              #either AP serial num or AP MAC (kumo uses AP serial num)
pre_provision_ap_base="201704250001"

#debugging configuration
system_domain_uuid="8b2081d5-9662-40d9-a3db-2a3cf4dde3f7"
temp_zone_list="/tmp/temp_zone_list.txt"
temp_zone_list_sort="/tmp/temp_zone_list_sort.txt"
temp_domain_list="/tmp/temp_domain_list.txt"
temp_domain_list_sort="/tmp/temp_domain_list_sort.txt"
local_zone_list_sort="./zone_list_sort.txt"
local_domain_list_sort="./domain_list_sort.txt"
temp_domain_result="/tmp/temp_domain_result.txt"
temp_v4_zone_result="/tmp/temp_v4_zone_result.txt"
temp_wispr_profile_result="/tmp/temp_wispr_profile_result.txt"
temp_proxy_radius_auth_server_result="/tmp/temp_proxy_radius_auth_server_result.txt"
temp_proxy_radius_auth_profile_result="/tmp/temp_proxy_radius_auth_profile_result.txt"
response_time_check="yes" 
http_resp_display="yes"
		
test_type_chk="0"

usage(){
        echo "usage: $0"
        echo "       --type=                                                   :<Support parameters for this type>   "
        echo "               1. sz-login                                       :login-name, login-pwd                "
        echo "               2. get-domain-list                                :list-domain-size                     "
        echo "               3. get-zone-list                                  :list-zone-size                       "
        echo "               4. get-proxy-radius-auth-server-list              :"
        echo "               5. get-proxy-radius-auth-profile-list             :"
        echo "               6. get-hotspot_profile_list                       :test_zone_uuid"
        echo "              11. move-ap                                        :"
        echo "              12. create-ap-registration-rules                   :"
        echo "              13. pre-provision-single-ap                        :test_zone_uuid, pre_provision_ap_entry, pre_provision_ap_model, pre_provision_ap_name"
        echo "              14. pre-provision-many-ap                          :pre_provision_ap_base, pre_provision_ap_model, pre_provision_ap_name"
        #echo "              21. create-domain"
        #echo "              22. create-v4-zone"
        #echo "              23. create-internal-wispr-profile"
        #echo "              24. create-open-wlan"
        #echo "              25. create-wispr-wlan"
        #echo "              26. create-8021x-wlan"
        #echo "              27. create-proxy-radius-auth-server"
        #echo "              28. create-proxy-radius-auth-server"
        #echo "              50. get-ap-list-per-domain"
        #echo "              51. get-ap-list-per-zone"
        #echo "              52. get-ap-count-per-domain"
        #echo "              53. get-ap-count-per-zone"
        #echo "              54. get-per-ap-summary"
        #echo "              55. get-client-count-per-ap"
        #echo "              56. get-client-list-per-ap"
        #echo "              61. get-client-count-per-ap"
        #echo "              62. get-client-list-per-ap"
        #echo "              63. get-client-list-per-domain-post"
        #echo "              64. get-client-on-demand-call"
        echo "              71. kumo_total-count-of-clients-per-domain         :test_domain_uuid"
        echo "              72. kumo_total-count-of-ap-state-per-domain        :test_domain_uuid"   
        echo "              73. kumo_total-count-of-clients-per-zone           :test_domain_uuid"
        echo "              74. kumo_total-count-of-ap-state-per-zone          :test_domain_uuid"
        echo "              75. kumo_get-per-ap-detail                         :test_ap_entry"
        echo "              76. kumo_get-client-list-per-ap-post               :test_domain_uuid, test_ap_entry, test_limit_num" 
        echo "              77. kumo_get-ap-list-per-domain-post               :test_domain_uuid, test_limit_num"
        echo "              78. kumo_get-client-list-per-domain-post           :test_domain_uuid, test_limit_num"
        echo "              79. kumo_get-client-on-demand-call                 :test_ap_entry, test_client_mac"
        echo "              80. kumo_get-ap-on-demand-call                     :test_ap_entry"
        echo "              98. 1k-domain-config"
        echo "             777. 1k-domain-zone-wlan"
        echo "             801. create-zone-in-same-domain"
        echo "             802. create-wlan-in-same-zone"
        echo "             901. create-zone-in-diff-domain"
        echo "             902. create-wlan-in-diff-zone"
        echo "       Global attributes:                                                               "
        echo "       --list          :Check attributes for type                                       "
        echo "       --time-check    :Show response time also                                         "
        echo "       Current Default Configuration:                                                   "
        echo -e "       --api-ver                 :Optional for all types        \e[1;36m      (Current: $api_ver) \e[0m"
        echo -e "       --vsz-ip                  :Optional for all types        \e[1;36m      (Current: $vscg_ip) \e[0m"
        echo -e "       --login-name              :Optional for login            \e[1;36m      (Current: $login_name) \e[0m"
        echo -e "       --login-pwd               :Optional for login            \e[1;36m      (Current: $login_password) \e[0m"
        echo -e "       --list-domain-size        :Optional for domain list      \e[1;36m      (Current: $list_domain_size) \e[0m"
        echo -e "       --list-zone-size          :Optional for zone list        \e[1;36m      (Current: $list_domain_size) \e[0m"
        echo -e "       --test-limit-num          :Optional for zone list        \e[1;36m      (Current: $test_limit_num) \e[0m"
        echo -e "       --test-domain-uuid        :Optional for domain           \e[1;36m      (Current: $test_domain_uuid) \e[0m"
        echo -e "       --test-zone-uuid          :Optional for zone             \e[1;36m      (Current: $test_zone_uuid) \e[0m"
        echo -e "       --test-ap-entry           :Optional for ap               \e[1;36m      (Current: $test_ap_entry) \e[0m"
        echo -e "       --test-client-mac         :Optional for client           \e[1;36m      (Current: $test_client_mac) \e[0m"
        echo -e "       --zone-ap-ver             :Optional for zone             \e[1;36m      (Current: $zone_ap_version) \e[0m"
        echo -e "       --pre-provision-ap-entry  :Optional for pre-provision ap \e[1;36m      (Current: $pre_provision_ap_entry) \e[0m"
        echo -e "       --pre-provision-ap-model  :Optional for pre-provision ap \e[1;36m      (Current: $pre_provision_ap_model) \e[0m"
        echo -e "       --pre-provision-ap-name   :Optional for pre-provision ap \e[1;36m      (Current: $pre_provision_ap_name) \e[0m"
        echo -e "       --pre-provision-ap-base   :Optional for pre-provision ap \e[1;36m      (Current: $pre_provision_ap_base) \e[0m"
        exit 1
}

for item in $*
do
	echo $item
	arg=${item%%=*}
	val=${item##*=}
	if [ $arg == "--type" ]; then
		test_type=$val
		test_type_chk="1"
	elif  [ $arg == "--api-ver" ]; then
                api_ver=$val
	elif  [ $arg == "--vsz-ip" ]; then
                vscg_ip=$val
        elif  [ $arg == "--login-name" ]; then
                login_name=$val
        elif  [ $arg == "--login-pwd" ]; then
                login_password=$val
	elif  [ $arg == "--list-domain-size" ]; then
                list_domain_size=$val
	elif  [ $arg == "--list-zone-size" ]; then
                list_zone_size=$val
	elif  [ $arg == "--test-limit-num" ]; then
                test_limit_num=$val
	elif  [ $arg == "--test-domain-uuid" ]; then
                test_domain_uuid=$val
	elif  [ $arg == "--test-zone-uuid" ]; then
                test_zone_uuid=$val
	elif  [ $arg == "--test-ap-entry" ]; then
                test_ap_entry=$val
	elif  [ $arg == "--test-client-mac" ]; then
                test_client_mac=$val
	elif  [ $arg == "--zone-ap-ver" ]; then
                zone_ap_version=$val
	elif  [ $arg == "--pre-provision-ap-entry" ]; then
                pre_provision_ap_entry=$val
	elif  [ $arg == "--pre-provision-ap-model" ]; then
                pre_provision_ap_model=$val
	elif  [ $arg == "--pre-provision-ap-name" ]; then
                pre_provision_ap_name=$val
	else
                echo -e "\e[1;31m Do not support this item \"$item\" \e[0m"
                exit 1
	fi
done

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

if [ $test_type_chk == "0" ]; then
	echo -e "\e[1;31m You have to execute the command with --type \e[0m"
	exit 1
fi
	

if [ $response_time_check == "yes" ]; then
	time_check='-w time:%{time_total}__http:%{http_code}\n'  
#	time_check='-w time:%{time_total}\n'   #time only
	#time_check='-w %{http_code}"\n"'      #http code only
else
	time_check='-w "\n"'
fi 

if [ $http_resp_display == "yes" ]; then
	resp_display=""
else
	resp_display="-o /dev/null"
fi 

sz_login(){
	curl -s  --cookie-jar ${temp_cookie} -k --tlsv1 -w "\n" -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"username\":\"${login_name}\", \"password\":\"${login_password}\", \"timeZoneUtcOffset\":\"+08:00\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/session
	#curl -s  --cookie-jar ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display}  -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"username\":\"${login_name}\", \"password\":\"${login_password}\", \"timeZoneUtcOffset\":\"+08:00\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/session
	#curl -s  --cookie-jar ${temp_cookie} -k --tlsv1 -w "@curl-format.txt" -o /dev/null  -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"username\":\"${login_name}\", \"password\":\"${login_password}\", \"timeZoneUtcOffset\":\"+08:00\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/session
}

sz_chk_session(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/session
}

get_domain_list(){
	#curl -s --cookie ${temp_cookie} -k --max-time 7200 --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/domains?listSize=${list_domain_size}
	curl -s --cookie ${temp_cookie} -k --max-time 7200 --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:8443/wsg/api/public/v${api_ver}/rkszones/domains?listSize=${list_domain_size}
}

get_zone_list(){
	#curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones?listSize=${list_zone_size}
	curl -s --cookie ${temp_cookie} -k --max-time 7200 --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:8443/wsg/api/public/v${api_ver}/rkszones?listSize=${list_zone_size}
}

get_hotspot_profile_list_per_zone(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/${test_zone_uuid}/portals/hotspot
}

get_proxy_radius_auth_server_list(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/services/auth/radius
}

get_proxy_radius_auth_profile_list(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/profiles/auth
}

create_domain(){
	#curl -s  --cookie-jar ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"type\":\"object\", \"additionalProperties\":\"false\", \"propertites\":{\"name\":{\"description\":\"domain-name-test\",\"\$ref\":\"common.json#/normalName\"},\"description\":{\"description\":\"description-test\",\"\$ref\":\"common.json#description\"}},\"required\":[\"name\"]}" https://${vscg_ip}:7443/api/public/v${api_ver}/domains
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"description\":\"\",\"domainType\":\"REGULAR\",\"name\":\"$create_domain_name\",\"parentDomainId\":\"${system_domain_uuid}\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/domains
}	

create_v4_zone(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"domainId\":\"${test_domain_uuid}\",\"name\":\"${create_zone_name}\",\"login\":{\"apLoginName\":\"${zone_ap_login_name}\",\"apLoginPassword\":\"${zone_ap_login_pwd}\"},\"description\":\"${create_zone_name}\",\"version\":\"${zone_ap_version}\",\"countryCode\":\"${zone_country_code}\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones
}

create_internal_wispr_profile(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"name\":\"${create_internal_wispr_profile_name}\",\"description\":\"${create_internal_wispr_profile_name}\",\"smartClientSupport\":\"${wispr_smart_client_support}\",\"location\":{\"id\":\"${wispr_location_id}\",\"name\":\"${wispr_location_name}\"},\"macAddressFormat\":2}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/${test_zone_uuid}/portals/hotspot/internal
}

create_open_wlan(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"name\":\"${create_open_wlan_name}\",\"ssid\":\"${create_open_wlan_name}\",\"description\":\"${create_open_wlan_name}\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/${test_zone_uuid}/wlans
}

create_wispr_wlan(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"name\":\"${create_wispr_wlan_name}\",\"ssid\":\"${create_wispr_wlan_name}\",\"description\":\"${create_wispr_wlan_name}\",\"authServiceOrProfile\":{\"throughController\":true, \"id\":\"${test_proxy_radius_auth_server_uuid}\",\"name\":\"${test_proxy_radius_auth_server_name}\"},\"portalServiceProfile\":{\"id\":\"${test_wispr_profile_uuid}\",\"name\":\"$test_wispr_profile_name\"}}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/${test_zone_uuid}/wlans/wispr
}

create_8021x_wlan(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"name\":\"${create_8021x_wlan_name}\",\"ssid\":\"${create_8021x_wlan_name}\",\"description\":\"${create_8021x_wlan_name}\",\"authServiceOrProfile\":{\"throughController\":true, \"id\":\"${test_proxy_radius_auth_profile_uuid}\",\"name\":\"${test_proxy_radius_auth_profile_name}\"}}" https://${vscg_ip}:7443/api/public/v${api_ver}/rkszones/${test_zone_uuid}/wlans/standard80211
}

create_proxy_radius_auth_server(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"name\":\"${create_proxy_radius_auth_server_name}\",\"domainId\":\"${system_domain_uuid}\",\"primary\":{\"ip\":\"${proxy_primary_radius_auth_server_ip}\",\"port\":1812,\"sharedSecret\":\"${proxy_primary_radius_auth_server_secret}\"}}" https://${vscg_ip}:7443/api/public/v${api_ver}/services/auth/radius
}

create_proxy_radius_auth_profile(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"domainId\":\"${system_domain_uuid}\",\"name\":\"${create_proxy_radius_auth_profile_name}\",\"realmMappings\":[{\"realm\":\"No Match\",\"serviceType\":\"RADIUS\",\"name\":\"${test_proxy_radius_auth_server_name}\",\"id\":\"${test_proxy_radius_auth_server_uuid}\",\"authorizationMethod\":\"NonGPPCallFlow\"},{\"realm\":\"Unspecified\",\"serviceType\":\"RADIUS\",\"name\":\"${test_proxy_radius_auth_server_name}\",\"id\":\"${test_proxy_radius_auth_server_uuid}\",\"authorizationMethod\":\"NonGPPCallFlow\"}],\"gppSuppportEnabled\":false,\"aaaSuppportEnabled\":false}" https://${vscg_ip}:7443/api/public/v${api_ver}/profiles/auth
}

move_ap_to_zone(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X PATCH -H "Content-type: application/json;charset=UTF-8" -d "{\"zoneId\":\"${test_move_zone_uuid}\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_move_ap_mac}
}

create_ap_registration_rule(){
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"description\":\"\",\"type\":\"Subnet\",\"subnet\":{\"networkAddress\":\"${test_ap_ip_rule}\",\"subnetMask\":\"255.255.255.255\"},\"mobilityZone\":{\"id\":\"${test_move_zone_uuid}\"}}" https://${vscg_ip}:7443/api/public/v${api_ver}/apRules
}


get_ap_list_per_domain_post () {
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"filters\":[{\"type\":\"DOMAIN\",\"value\":\"${test_domain_uuid}\"}],\"fullTextSearch\":{\"type\":\"AND\",\"value\":\"\"},\"attributes\":[\"*\"],\"sortInfo\":{\"sortColumn\":\"apMac\",\"dir\":\"ASC\"},\"page\":0,\"start\":0,\"limit\":8}" https://${vscg_ip}:7443/api/public/v${api_ver}/query/ap
}

get_client_list_per_ap_post () {
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"filters\":[{\"type\":\"DOMAIN\",\"value\":\"${test_domain_uuid}\"}],\"extraFilters\":[{\"type\":\"AP\",\"value\":\"${test_ap_entry}\"}],\"fullTextSearch\":{\"type\":\"AND\",\"value\":\"\"},\"attributes\":[\"*\"],\"sortInfo\":{\"sortColumn\":\"clientMac\",\"dir\":\"ASC\"},\"page\":0,\"start\":0,\"limit\":${test_limit_num}}" https://${vscg_ip}:7443/api/public/v${api_ver}/query/client/compatible
}

get_client_list_per_domain_post () {
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"filters\":[{\"type\":\"DOMAIN\",\"value\":\"${test_domain_uuid}\"}],\"fullTextSearch\":{\"type\":\"AND\",\"value\":\"\"},\"attributes\":[\"*\"],\"sortInfo\":{\"sortColumn\":\"clientMac\",\"dir\":\"ASC\"},\"page\":0,\"start\":0,\"limit\":${test_limit_num}}" https://${vscg_ip}:7443/api/public/v${api_ver}/query/client/compatible
}

pre_provision_ap_post() {
	curl -s  --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X POST -H "Content-type: application/json;charset=UTF-8" -d "{\"mac\":\"${pre_provision_ap_entry}\",\"zoneId\":\"${test_zone_uuid}\",\"serial\":\"${pre_provision_ap_entry}\",\"model\":\"${pre_provision_ap_model}\",\"name\":\"${pre_provision_ap_name}\"}" https://${vscg_ip}:7443/api/public/v${api_ver}/aps
}

get_ap_list_per_domain(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps?domainId=${test_domain_uuid}\&listSize=${list_ap_size}
}

get_ap_list_per_zone(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps?zoneId=${test_zone_uuid}\&listSize=${list_ap_size}
}

get_ap_count_per_domain(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/totalCount?domainId=${test_domain_uuid}
}

get_ap_count_per_zone(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/totalCount?zoneId=${test_zone_uuid}
}

get_per_ap_summary(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}/operational/summary
}

get_per_ap_detail(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}
}

get_client_count_per_ap(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}/operational/client/totalCount
}

get_client_list_per_ap(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}/operational/client?listSize=${list_client_size}
}


get_client_on_demand_call(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}/operational/clientOnDemandData?clientMac=${test_client_mac}
}

get_get_ap_on_demand_call(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/${test_ap_entry}/operational/onDemandData
}

get_total_count_of_clients_per_domain(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/clients/domains/${test_domain_uuid}/count?groupBy=domain
}

get_total_count_of_ap_state_per_domain(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/domains/${test_domain_uuid}/count?groupBy=domain
}

get_total_count_of_clients_per_zone(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/clients/domains/${test_domain_uuid}/count?groupBy=zone
}

get_total_count_of_ap_state_per_zone(){
	curl -s --cookie ${temp_cookie} -k --tlsv1 ${time_check} ${resp_display} -X GET -H "Content-type: application/json;charset=UTF-8" https://${vscg_ip}:7443/api/public/v${api_ver}/aps/domains/${test_domain_uuid}/count?groupBy=zone
}




case $test_type in
 "1" | "$n0001_item" )
	sz_login
	;;
 "2" | "get-domain-list" )
 	get_domain_list > $temp_domain_list
	cat $temp_domain_list | sed 's/^.*:\[{//g' | sed 's/},{/\n/g' | sed 's/}]}.*$//g' | sort -t : -k 3 > $temp_domain_list_sort
	cp $temp_domain_list_sort $local_domain_list_sort
	;;
 "3" | "get-zone-list" )
 	get_zone_list > $temp_zone_list
	cat $temp_zone_list | sed 's/^.*:\[{//g' | sed 's/},{/\n/g' | sed 's/}]}.*$//g' | sort -t : -k 3 > $temp_zone_list_sort
	cp $temp_zone_list_sort $local_zone_list_sort
	;;
 "4" | "get-proxy-radius-auth-server-list" )
	get_proxy_radius_auth_server_list
	;;
 "5" | "get-proxy-radius-auth-profile-list" )
	get_proxy_radius_auth_profile_list
	;;
 "6" | "get-hotspot_profile_list" )
	get_hotspot_profile_list_per_zone
	;;
 "11" | "move-ap" )
	if [ -e $local_zone_list_sort ]; then
		/bin/cp $local_zone_list_sort $temp_zone_list_sort
	else 
		echo "No local zone list file exists, please get zone list file first, $0 3"
		exit 1
	fi
	
	move_ap_num=257
	for ((a=1; a <= $move_ap_num; a++))
	do
		test_move_ap_mac=`printf "01:AA:AA:00:%02X:%02X" $(($a/256)) $(($a%256))`
		test_move_zone_uuid=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$a{print}" | cut -d \" -f 4`
		test_move_zone_name=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$a{print}" | cut -d \" -f 8`
		echo "Move ap - $test_move_ap_mac to the zone $test_move_zone_name with uuid $test_move_zone_uuid"
		move_ap_to_zone	
	done
	;;
 "12" | "create-ap-registration-rules" )
	if [ -e $local_zone_list_sort ]; then
		/bin/cp $local_zone_list_sort $temp_zone_list_sort
	else 
		echo "No local zone list file exists, please get zone list file first, $0 3"
		exit 1
	fi
	
	set_ap_num=1000
	
	b=1
	for ((b=1; b <= $set_ap_num; b++))
	do
		test_ap_ip_rule=`printf "10.1.%s.%s" $(($b/256)) $(($b%256))`
		test_move_zone_uuid=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$b{print}" | cut -d \" -f 4`
		test_move_zone_name=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$b{print}" | cut -d \" -f 8`
		echo "Crate ap regist rule for AP IP $test_ap_ip_rule to the zone $test_move_zone_name with uuid $test_move_zone_uuid"
		create_ap_registration_rule
	done
	;;
 "13" | "pre-provision-signle-ap" )
	pre_provision_ap_post
	;;
 "14" | "pre-provision-many-ap" )
	if [ -e $local_zone_list_sort ]; then
		/bin/cp $local_zone_list_sort $temp_zone_list_sort
	else 
		echo "No local zone list file exists, please get zone list file first, $0 3"
		exit 1
	fi
	
	set_ap_num=10
	#pre_provision_ap_base=201704250001
	
	b=1
	for ((b=1; b <= $set_ap_num; b++))
	do
		pre_provision_ap_entry=$pre_provision_ap_base
		test_move_zone_uuid=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$b{print}" | cut -d \" -f 4`
		test_move_zone_name=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$b{print}" | cut -d \" -f 8`
		pre_provision_ap_post
		echo "Pre-provision AP $pre_provision_ap_entry to the zone $test_move_zone_name with uuid $test_move_zone_uuid"
		pre_provision_ap_base=$(($pre_provision_ap_base + 1))
	done
	;;
 "21" | "create-domain" )
 	create_domain
	;;
 "22" | "create-v4-zone" )
 	test_domain_uuid="246c4ceb-30fd-4dd8-9756-377b42f0e5b7"
	create_zone_name="zone0001"
	create_v4_zone
	;;
 "23" | "create-internal-wispr-profile" )
	test_zone_uuid="2039a851-0444-45eb-b3cc-ef6869d7f943"
 	create_internal_wispr_profile_name="wispr-int-profile-0001"
	create_internal_wispr_profile
	;;
 "24" | "create-open-wlan" )
	test_zone_uuid="2039a851-0444-45eb-b3cc-ef6869d7f943"
 	create_open_wlan_name="open-wlan-name-0001"
 	create_open_wlan
	;;
 "25" | "create-wispr-wlan" )
	test_zone_uuid="ea6c7834-4dc2-4ca9-9f62-a276bca76a88"
	test_proxy_radius_auth_server_name="proxy-radius-auth-server01"
	test_proxy_radius_auth_server_uuid="532f6c81-07c8-11e7-b158-42010a800002"
	test_wispr_profile_uuid="883b0839-876e-4708-a4a3-abb39eae62d9"
	test_wispr_profile_name="wispr-int-profile-0001"
 	create_wispr_wlan_name="wispr-wlan-name"
 	create_wispr_wlan
	;;
 "26" | "create-8021x-wlan" )
	test_zone_uuid="d47e09f7-6469-4dce-9046-23761e798dff"
	test_proxy_radius_auth_profile_name="proxy-radius-auth-profile01"
	test_proxy_radius_auth_profile_uuid="534a6e92-07c8-11e7-b158-42010a800002"
 	create_8021x_wlan_name="8021x-wlan-name"
 	create_8021x_wlan
	;;
 "27" | "create-proxy-radius-auth-server" )
	create_proxy_radius_auth_server_name="proxy-radius-auth-server01"
	proxy_primary_radius_auth_server_ip="1.2.3.4"
	proxy_primary_radius_auth_server_secret="12345678"
 	create_proxy_radius_auth_server
	;;
 "28" | "create-proxy-radius-auth-server" )
	test_proxy_radius_auth_server_name="proxy-radius-auth-server01"
	test_proxy_radius_auth_server_uuid="db4289b0-07b7-11e7-b158-42010a800002"
	create_proxy_radius_auth_profile_name="proxy-radius-auth-profile01"
 	create_proxy_radius_auth_profile
	;;
 "50" | "get-ap-list-per-domain" )
	list_ap_size=100
	test_domain_uuid="c771c964-88dc-4c08-a38f-f8c10b801b3d"
	get_ap_list_per_domain
	;;
 "51" | "get-ap-list-per-domain-post" )
	test_domain_uuid="c771c964-88dc-4c08-a38f-f8c10b801b3d"
	get_ap_list_per_domain_post
	;;
 "52" | "get-ap-list-per-zone" )
	list_ap_size=100
	test_zone_uuid="fdede607-9afe-4e04-83e3-7f7d2357a91a"
	get_ap_list_per_zone
	;;
 "53" | "get-ap-count-per-domain" )
	test_domain_uuid="d87a9056-f610-4e42-a421-b3d8b77b8d43"
	get_ap_count_per_domain
	;;
 "54" | "get-ap-count-per-zone" )
	test_zone_uuid="fdede607-9afe-4e04-83e3-7f7d2357a91a"
	get_ap_count_per_zone
	;;
 "55" | "get-per-ap-summary" )
	test_ap_entry="01:AA:AA:00:01:EC"
	get_per_ap_summary
	;;
 "56" | "get-per-ap-detail" )
	test_ap_entry="01:AA:AA:00:01:EC"
	get_per_ap_detail
	;;
 "61" | "get-client-count-per-ap" )
	test_ap_entry="01:AA:AA:00:01:EC"
	get_client_count_per_ap
	;;
 "62" | "get-client-list-per-ap" )
	list_client_size=100
	test_ap_entry="01:AA:AA:00:01:EC"
	get_client_list_per_ap
	;;
 "63" | "get-client-list-per-domain-post" ) 
	test_domain_uuid="c771c964-88dc-4c08-a38f-f8c10b801b3d"
	test_ap_entry="01:AA:AA:00:01:5C"
	test_limit_num="8"
	get_client_list_per_domain_post
	;;
 "64" | "get-client-on-demand-call" )
	test_ap_entry="01:AA:AA:00:01:EC"
	test_client_mac="00:CC:C1:00:25:26"
	get_client_on_demand_call
	;;
 "71" | "kumo_total-count-of-clients-per-domain" )
	get_total_count_of_clients_per_domain
	;;
 "72" | "kumo_total-count-of-ap-state-per-domain" )
	get_total_count_of_ap_state_per_domain
	;;
 "73" | "kumo_total-count-of-clients-per-zone" )
	get_total_count_of_clients_per_zone
	;;
 "74" | "kumo_total-count-of-ap-state-per-zone" )
	get_total_count_of_ap_state_per_zone
	;;
 "75" | "kumo_get-per-ap-detail" )
	get_per_ap_detail
	;;
 "76" | "kumo_get-client-list-per-ap-post" ) 
	get_client_list_per_ap_post
	;;
 "77" | "kumo_get-ap-list-per-domain-post" )
	get_ap_list_per_domain_post
	;;
 "78" | "kumo_get-client-list-per-domain-post" ) 
	get_client_list_per_domain_post
	;;
 "79" | "kumo_get-client-on-demand-call" )
	get_client_on_demand_call
	;;
 "80" | "kumo_get-ap-on-demand-call" )
	get_get_ap_on_demand_call
	;;
 "98" | "1k-domain-config")
	echo "Start the test on `date +%F-%T`"
	for ((i=1; i<=10000; i++))
	do
		if [ $i -lt 10 ]; then
			create_domain_name="domain000$i"
		elif [ $i -lt 100 ]; then
			create_domain_name="domain00$i"
		elif [ $i -lt 1000 ]; then
			create_domain_name="domain0$i"
		else	
			create_domain_name="domain$i"
		fi
		echo -n "create the $i domain: "
		create_domain
		sleep 1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 "777" | "1k-domain-zone-wlan" )
	################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
	resp_display=""
	create_open_wlan_name="open-wlan-test"
	create_wispr_wlan_name="wispr-wlan-test"
	create_8021x_wlan_name="8021x-wlan-test"
	echo "Start the test on `date +%F-%T`"
	auto_create_proxy_radius_auth="yes"
	if [ ${auto_create_proxy_radius_auth} == "yes" ]; then
		create_proxy_radius_auth_server_name="proxy-radius-auth-server01"
		proxy_primary_radius_auth_server_ip="10.128.0.4"
		proxy_primary_radius_auth_server_secret="abcd1234"
		create_proxy_radius_auth_server > $temp_proxy_radius_auth_server_result
		test_proxy_radius_auth_server_uuid=`cat $temp_proxy_radius_auth_server_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_proxy_radius_auth_server_result=`cat $temp_proxy_radius_auth_server_result | cut -d } -f 2`
		test_proxy_radius_auth_server_name=$create_proxy_radius_auth_server_name
		echo "create the proxy radius auth server     : ${test_proxy_radius_auth_server_result}"

		create_proxy_radius_auth_profile_name="proxy-radius-auth-profile01"
		create_proxy_radius_auth_profile > $temp_proxy_radius_auth_profile_result
		test_proxy_radius_auth_profile_uuid=`cat $temp_proxy_radius_auth_profile_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_proxy_radius_auth_profile_result=`cat $temp_proxy_radius_auth_profile_result | cut -d } -f 2`
		test_proxy_radius_auth_profile_name=$create_proxy_radius_auth_profile_name
		echo "create the proxy radius auth profile    : ${test_proxy_radius_auth_profile_result}"
	else
		test_proxy_radius_auth_server_name="proxy-radius-auth-server01"
		test_proxy_radius_auth_server_uuid="532f6c81-07c8-11e7-b158-42010a800002"
		test_proxy_radius_auth_profile_name="proxy-radius-auth-profile01"
		test_proxy_radius_auth_profile_uuid="534a6e92-07c8-11e7-b158-42010a800002"
	
	fi
	for ((i=1; i<=1000; i++))
	do
		################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
		resp_display=""
		if [ $i -lt 10 ]; then
			create_domain_name="domain-000$i"
			create_zone_name="zone-000$i"
			create_internal_wispr_profile_name="wispr-int-profile-000$i"
			#create_open_wlan_name="open-wlan-000$i"
			#create_wispr_wlan_name="wispr-wlan-000$i"
			#create_8021x_wlan_name="8021x-wlan-000$i"
		elif [ $i -lt 100 ]; then
			create_domain_name="domain-00$i"
			create_zone_name="zone-00$i"
			create_internal_wispr_profile_name="wispr-int-profile-00$i"
			#create_open_wlan_name="open-wlan-00$i"
			#create_wispr_wlan_name="wispr-wlan-00$i"
			#create_8021x_wlan_name="8021x-wlan-00$i"
		elif [ $i -lt 1000 ]; then
			create_domain_name="domain-0$i"
			create_zone_name="zone-0$i"
			create_internal_wispr_profile_name="wispr-int-profile-0$i"
			#create_open_wlan_name="open-wlan-0$i"
			#create_wispr_wlan_name="wispr-wlan-0$i"
			#create_8021x_wlan_name="8021x-wlan-0$i"
		else	
			create_domain_name="domain-$i"
			create_zone_name="zone-$i"
			create_internal_wispr_profile_name="wispr-int-profile-$i"
			#create_open_wlan_name="open-wlan-$i"
			#create_wispr_wlan_name="wispr-wlan-$i"
			#create_8021x_wlan_name="8021x-wlan-$i"
		fi
		#Create domain
		create_domain > $temp_domain_result
		test_domain_uuid=`cat $temp_domain_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_domain_result=`cat $temp_domain_result | cut -d } -f 2`
		echo "create the $i domain                    : ${test_domain_result}"
		#Create zone
		create_v4_zone > $temp_v4_zone_result
		test_v4_zone_uuid=`cat $temp_v4_zone_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_v4_zone_result=`cat $temp_v4_zone_result | cut -d } -f 2`
		echo "create the $i v4-zone                   : ${test_v4_zone_result}"
		test_zone_uuid=$test_v4_zone_uuid
		#Create internal wispr portal
		create_internal_wispr_profile > $temp_wispr_profile_result
		test_wispr_profile_uuid=`cat $temp_wispr_profile_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_wispr_profile_result=`cat $temp_wispr_profile_result | cut -d } -f 2`
		echo "create the $i wispr_profile             : ${test_wispr_profile_result}"
		################ Hide http reply because no need to get uuid afterward ################
		resp_display="-o /dev/null"
		#Create open wlan
		echo -n "create the $i open wlan                 : "
		create_open_wlan
		#Create wispr wlan
		test_wispr_profile_name=$create_internal_wispr_profile_name
		echo -n "create the $i wispr wlan                : "
		create_wispr_wlan
		#Create 8021x wlan
		echo -n "create the $i 8021x wlan                : "
		create_8021x_wlan
		
		sleep 0.1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 "801" | "create-zone-in-same-domain" )
	resp_display=""
	echo "Start the test on `date +%F-%T`"
	for ((i=1; i<=2000; i++))
	do
		################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
		resp_display=""
		if [ $i -lt 10 ]; then
			create_zone_name="zone-000$i"
		elif [ $i -lt 100 ]; then
			create_zone_name="zone-00$i"
		elif [ $i -lt 1000 ]; then
			create_zone_name="zone-0$i"
		else	
			create_zone_name="zone-$i"
		fi
		test_domain_uuid=$system_domain_uuid
		#Create zone
		create_v4_zone > $temp_v4_zone_result
		test_v4_zone_uuid=`cat $temp_v4_zone_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		test_v4_zone_result=`cat $temp_v4_zone_result | cut -d } -f 2`
		echo "create the $i v4-zone                   : ${test_v4_zone_result}"
		sleep 0.1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 "802" | "create-wlan-in-same-zone" )
	echo "Start the test on `date +%F-%T`"
	for ((i=1; i<=2000; i++))
	do
		################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
		resp_display=""
		if [ $i -lt 10 ]; then
			create_open_wlan_name="open-wlan-000$i"
		elif [ $i -lt 100 ]; then
			create_open_wlan_name="open-wlan-00$i"
		elif [ $i -lt 1000 ]; then
			create_open_wlan_name="open-wlan-0$i"
		else	
			create_open_wlan_name="open-wlan-$i"
		fi
		test_zone_uuid="557fa223-2a48-464f-aae2-c9bb4c8465be"
		resp_display="-o /dev/null"
		#Create open wlan
		echo -n "create the $i open wlan                 : "
		create_open_wlan
		sleep 0.1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 "901" | "cretae-zone-in-diff-domain" )
	################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
	if [ -e $local_domain_list_sort ]; then
		/bin/cp $local_domain_list_sort $temp_domain_list_sort
	else 
		echo "No local domain list file exists, please get domain list file first, $0 2"
		exit 1
	fi
	echo "Start the test on `date +%F-%T`"
	for ((i=1; i<=2000; i++))
	do
		################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
		resp_display=""
		if [ $i -lt 10 ]; then
			create_zone_name="zone-000$i"
		elif [ $i -lt 100 ]; then
			create_zone_name="zone-00$i"
		elif [ $i -lt 1000 ]; then
			create_zone_name="zone-0$i"
		else	
			create_zone_name="zone-$i"
		fi
		test_domain_uuid=`cat $temp_domain_list_sort | awk "NR==$i{print}" | cut -d \" -f 4`
		test_domain_name=`cat $temp_domain_list_sort | awk "NR==$i{print}" | cut -d \" -f 8`
		#Create zone
		#create_v4_zone > $temp_v4_zone_result
		#test_v4_zone_uuid=`cat $temp_v4_zone_result | sed 's/^.*id":"//g' | sed 's/"}.*$//g'`
		#test_v4_zone_result=`cat $temp_v4_zone_result | cut -d } -f 2`
		#echo "create the $i v4-zone                   : ${test_v4_zone_result}"
	
		resp_display="-o /dev/null"
		echo "create the $i v4-zone under the domain - $test_domain_name : "
		create_v4_zone
		
		sleep 0.1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 "902" | "create-wlan-in-diff-zone" )
	################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
	if [ -e $local_zone_list_sort ]; then
		/bin/cp $local_zone_list_sort $temp_zone_list_sort
	else 
		echo "No local zone list file exists, please get zone list file first, $0 3"
		exit 1
	fi
	echo "Start the test on `date +%F-%T`"
	for ((i=1; i<=2000; i++))
	do
		################ Force to get  http reply because domain and zone uuid are needed for profile and wlan created ################
		if [ $i -lt 10 ]; then
			create_open_wlan_name="open-wlan-000$i"
		elif [ $i -lt 100 ]; then
			create_open_wlan_name="open-wlan-00$i"
		elif [ $i -lt 1000 ]; then
			create_open_wlan_name="open-wlan-0$i"
		else	
			create_open_wlan_name="open-wlan-$i"
		fi
		
		test_zone_uuid=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$i{print}" | cut -d \" -f 4`
		test_zone_name=`cat $temp_zone_list_sort | grep -v "Staging Zone" | awk "NR==$i{print}" | cut -d \" -f 8`
		resp_display="-o /dev/null"
		#resp_display=""
		#Create open wlan
		echo -n "create the $i open wlan under the zone - $test_zone_name : "
		create_open_wlan
		
		sleep 0.1
	done
	echo "Finish thd test on `date +%F-%T`"
	;;
 *)
	echo "Don not support this test type - $test_type"
	exit 1
	;;
esac
