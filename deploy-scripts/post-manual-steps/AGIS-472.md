# CAR-T Project

## Post Deployment Manual Steps for AGIS-472.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Configure Adobe permission sets as needed|
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Navigate to Setup -> Quick Find -> Type 'Users' and then select 'Users'| | | | | | | |
|3|For the User that will execute all the Adobe Sign configuration steps (Salesforce System Administrator), follow the next steps:
	|a|a) Click on the name of this user.
	|b|b) Go to the Permission Set Assignments section and then click on 'Edit Assignment' button.
	|c|c) Select the 'Adobe Sign Admin' and 'Adobe Sign Integration User' permission sets and add them to the current user. Click on Save.
|4|For the rest of the Users with minimum required permission for Adobe Sign:
	|a|a) Click on the name of each user.
	|b|b) Go to the Permission Set Assignments section and then click on 'Edit Assignment' button.
	|c|c) Select the 'Adobe Sign User' permission set and add it to the user. Clic on Save.	
|Configure the Adobe Sign account|
|1|In order to follow the next steps, it is necessary to enter the same email address in the Salesforce profile that we will use in this configuration as the one with which you have registered the Adobe Sign account. | | | | | | | |
|2|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|3|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item and then click on 'Launch Setup Wizard' link (right side). An Adobe Sign for Salesforce Setup Wizard will be displayed.| | | | | | | |
|5|If for the previous step the wizard shows an unauthorized endpoint error, then, configure the endpoint value that is showed in the error message (inside the Remote site settings). | | | | | | | |
|6|Click on 'Sign in to Adobe' button and then enter the credentials for the Adobe Sign account that will be linked to the Salesforce org. Enter the correct credentials for the Adobe account and then, will be displayed the next success message: 'Success! You have successfully authorized your Adobe Account.' | | | | | | | |
|7|In the next step #2 of the Wizard, click on 'Enable' button in order to enable the automatic status update from Adobe.| | | | | | | |
|8|At the end, a successfully message will be displayed: 'Congrats! Your setup is complete.'| | | | | | | |
|Allow recipient roles into the Adobe Sign Account 
|1|Login into the Adobe Sign portal using the Adobe Sign credentials that have been used in the previous configuration.| | | | | | | |
|2|In the left menu, click on 'Send Settings' and then go to the 'Allowed Recipient Roles' section. Then check the option 'Allow senders to mark some recipients as form fillers'. Click on 'Save'.  | | | | | | | |
|Create Patient Service Enrolle lookup relationship into Adobe Sign Agreement object |
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Navigate to Setup -> Object Manager -> Select the Agreement Object -> Select Fields and Relationships and click on 'New' button| | | | | | | |
|3|Select 'Lookup Relationship' data type and click on Next.| | | | | | | |
|4|From the 'Related To' picklist select 'Patient Services Enrolle' option and click on Next.| | | | | | | |
|5|	Set the following values:a) Field Label => 'Patient Services Enrolle'b) Field Name => 'PatientServicesEnrolle'c) Description => 'Lookup to Patient Services Enrolle object'.d) Left rest of fields with default values and click on Next.e) Left default values for step#4 and #5.f) In step  #6, just confirm that is selected the checkbox 'Add Related List' for Patient Services Enrolle Layout. Click on Save.
|Configure the Agreement Template for Patient Service Enrolle records |
|1|Download the 'Patient Services Enrollment Form.pdf' document located at data > 'Adobe Sign Form PSE' folder. | | | | | | | |
|2|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|3|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|4|Click on 'Agreement Templates' Tab and then click on 'New' button to generate a new Agreement Template. Assign the name 'Patient Enrollment' to this template and click on Save.| | | | | | | |
|On this new template:
|1|Select the 'TEMPLATE DETAILS' tab and set the following values:
    |a| Agreement Name => 'Enrollment Form for Patient Services'
    |b| Salesforce Object => Select 'Choose from other Objects' option, then from the next picklist enter 'patient' and click on the search icon. Select the 'Patient Services Enrolle' option.  
    |c| Mapped data => Click on 'Map data into agreement fields' link and then select the 'Select from Object' option under the 'Mapping Method' label. From the 'Source Type' picklist, select the 'Id' option and then, from the 'Target Agreement field' picklist select the 'Patient Services Enrollee (REFERENCE)' option. 
|2|Select the 'ATTACHMENT' tab and follow the next step:
    a) Click on 'Upload Files' button and upload the downloaded document in step #1 'Patient Services Enrollment Form.pdf'.
    Select the 'RECIPIENTS' tab and follow the next steps:
    a) Delete the default Recipient configuration (click on the 'x' icon). Then, click on 'Add recipient from object or run-time variable' link and set the following values:
		a1.- Choose object or runtime variable => Select 'Look Up Based on Master Object Field' option.
		a2.- Recipient Role => Select 'Form Filler' option.
		a3.- Recipient Type => Select 'Email' option.
		a4.- Source field from master object => Select 'Patient Email (PatientEmail__c)' option.
		a5.- Verification Method => Select 'Email' option.
		a6.- Click on Save.
	b) Copy and enter the following text into the body of the Message (canvas area) starting with the 'Dear' word and finishing with the 'Coordinator' word:
	-----
	Dear {!Patient__r.Name},

	Thank you for your interest in Patient Services. Please find below options to enroll into the Patient Services Program.

	To fill the form electronically, please click on the Adobe DocuSign link provided above. Request you to complete the form and submit.
	To call in and request for help from our Patient Services agents, please dial: 1800-xxx-xxxx
	Sincerely,

	{!Owner.Name}

	Janssen Operations Coordinator
	-----
|   |   ||||||||
|---:|:---|:---|:---|:---|:---|:---|:---|:---|
|3|Select the 'RULES MAPPING' tab and follow the next step:| | | | | | | |
	|a| Go to the 'Configure where the template is used' section and then check the option 'Set as default template for all agreements'.
|4|Finally, click on the Save button (upper corner, blue color).| | | | | | | |
Add FLS permissions of Patient Enrolle object to Patient Service Management and Patient Service Ready Only permission sets |
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Navigate to Setup -> Quick Find -> Enter 'permission' and select 'Permission Sets'| | | | | | | |
|3|From the permission set list, select 'Patient Services Management' permission set and then click on 'Object Settings' | | | | | | | |
|4|From the object set list, click on Agreements object and then click on Edit button | | | | | | | |
|5|Give Read Access permission to 'Patient Service Enrolle' field and click on Save.| | | | | | | |
|6|Back to permission set list and select 'Patient Services Read Only' permission set and then click on 'Object Settings' | | | | | | | |
|7|From the object set list, click on Agreements object and then click on Edit button | | | | | | | |
|8|Give Read Access permission to 'Patient Service Enrolle' field and click on Save.| | | | | | |   |


## Post Deployment Manual Steps for AGIS-472-FormatEmailBodyforPSEForm.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Update Email's body for PSE form |
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | |
|3|Click on 'Recipients' Tab, copy and enter the following text into the body of the Message (canvas area) starting with the 'Dear' word and finishing with the 'Coordinator' word (without '#' signs): | | | | | | |

#######
Dear {!Patient__r.Name},

Thank you for your interest in Patient Services.

Please find below options to enroll into the Patient Services Program.

	1. To fill the form electronically, please click on the Adobe DocuSign link provided above. Request you to complete the enrollment form and submit.
	2. To call in and request for help from our Patient Services Agents, please dial: 1800-xxx-xxxx.

Sincerely,

{!Owner.Name}

Janssen Operations Coordinator

|   |   ||||||||
|---:|:---|:---|:---|:---|:---|:---|:---|:---|
|4|Finally, click on the Save button (right corner, blue color).| | | | | | |  |

