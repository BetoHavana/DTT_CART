# CAR-T Project

## Post Deployment Manual Steps for AGIS-177.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Upload the Patient Services Enrollment Form updated|
|1|Download the 'Patient Services Enrollment Form.pdf' document located at data > 'Adobe Sign Form PSE' folder. | | | | | | | |
|2|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|3|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|4|Click on 'Agreement Templates' link and then click on the 'Enrollment Form for Patient Services' agreement template.| | | | | | | |
|5|Click on 'Attachment' tab, go to the 'Documents added' section and remove the PDF document previously added (click on 'Remove ' option). Then, click on 'Upload Files' button and upload the downloaded document in step #1 'Patient Services Enrollment Form.pdf'| | | | | | | |
|6|Click the Save button.| | | | | | | |

#### Add Planned Infusion Date Mapping in Patient Services Enrollment Form Data Mapping

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES|
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|3|Click on 'Data Mappings' link and then click on 'PS Enrolleee Record Data Mapping'.| | | | | | | |
|4|Go to Fields Mapping section and follow the next steps:| | | | | | | |
|5|Click on 'Add Mapping' button and then, into the new record displayed:| | | | | | | |
|5(a)| From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.| | | | | | | |
|5(b)| From 'Which Salesforce Field to Update?' picklist, select 'Planned Infusion Date (Date)' option.| | | | | | | |
|5(c)| From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.| | | | | | | |
|5(d)| Enter "{{PlannedInfusionDate}}_af_date" (without quotation marks) into the text field from 'What is the value of the Data?'.| | | | | | | |
|5(e)| From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.| | | | | | | |
|6|Finally click on Save button.

## Post Deployment Manual Steps for AGIS-177-ClearingInfusionDateField.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Upload the Patient Services Enrollment Form updated|
|1|Download the 'Patient Services Enrollment Form.pdf' document located at data > 'Adobe Sign Form PSE' folder. | | | | | | | |
|2|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|3|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|4|Click on 'Agreement Templates' link and then click on the 'Enrollment Form for Patient Services' agreement template.| | | | | | | |
|5|Click on 'Attachment' tab, go to the 'Documents added' section and remove the PDF document previously added (click on 'Remove ' option). Then, click on 'Upload Files' button and upload the downloaded document in step #1 'Patient Services Enrollment Form.pdf'.| | | | | | | |
|6|Click the Save button.| | | | | | | |


