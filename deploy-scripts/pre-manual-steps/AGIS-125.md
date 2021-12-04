# CAR-T Project

## Pre deployment Manual step for AGIS-125.
##### (Please validate with Integration team for Org specific URLs,Client_ID,Client_password)

Please execute the following steps.

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES|  
|1| Navigate to Setup -> in quick find box enter Named Credentials. Click on New| | | | | | | |
|2| Set the following values on Label => 'ConfirmSlotBooking' | | | | | | | |
|3| Set the following values on Name => 'ConfirmSlotBooking' | | | | | | | |
|4(a)| Set the following values on URL for DEV => https://phm-slot-booking-eapi-dev.us-e2.cloudhub.io/eapi/slotbook | | | | | | | |
|4(b)| Set the following values on URL for PRE-QA=> https://phm-slot-booking-eapi-preqa.us-e2.cloudhub.io/eapi/slotbook| | | | | | | |
|5| Set the following values on Identity Type => Named Principal | | | | | | | |
|6| Set the following values on Authentication Protocol => Password Authentication | | | | | | | |
|7| Set the following values on Username => client_id (check with Integration team) | | | | | | | |
|8| Set the following values on Password => client_secret (check with Integration team) | | | | | | | |
|9| Set the following values on Generate Authorization Header => Checkbox should be enabled | | | | | | | |
|10| Allow Merge Fields in HTTP Header => Checkbox should be enabled | | | | | | | |
|11| Click 'Save' | | | | | | | |
