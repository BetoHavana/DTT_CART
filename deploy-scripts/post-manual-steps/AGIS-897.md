# CAR-T Project

## Post Deployment Manual Steps for AGIS-897.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Configure Adobe Sign Data Mapping|
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | |
|2|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | |
|3|Click on 'Data Mappings' Tab and then click on 'New' button to generate a new Data Mapping.| | | | | | |
|4|Assign the name 'PS Enrolleee Record Data Mapping' to this new data mapping.| | | | | | |
|5|Go to Fields Mapping section and follow the next steps:

	a) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Phone (Phone)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientPhone}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	b) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Phone Type (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientPhoneType}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	c) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Email (Email)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientEmail}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	d) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Primary Contact for Travel Logistics (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PrimaryContactforTravelLogistics}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.
		
	e) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Best Time for Outreach (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{BestTimeforOutreach}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	f) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Preferred Language (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientPreferredLanguage}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	g) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Address Line 1 (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientAddressLine1}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	h) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Address Line 2 (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientAddressLine2}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	i) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient City (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientCity}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	j) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient State (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientState}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	k) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Country (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientCountry}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.
		
	l) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Patient Zip (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{PatientZip}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	m) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver First Name (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverFirstName}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.	
		
	n) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Middle Name (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverMiddleName}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	o) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Last Name (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverLastName}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	d) Click on 'Add Mapping' button and then, into the new record displayed:
		d1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		d2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Phone (String)' option.
		d3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		d4.- Enter "{{CaregiverPhone}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		d5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	p) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Phone Type (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverPhoneType}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.
		
	q) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Email (Email)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverEmail}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	r) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Address Line 1 (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverAddressLine1}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	s) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Address Line 2 (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverAddressLine2}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		
		
	t) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver City (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{Caregiver City}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	u) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver State (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverState}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	v) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Country (Picklist)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverCountry}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.
		
	w) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Caregiver Zip (String)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{CaregiverZip}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.

	x) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Attestation of Completion (Boolean)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'EchoSign Form Field' option.
		4.- Enter "{{AttestationofCompletion}}" (without quotation marks) into the text field from 'What is the value of the Data?'.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	y) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Date of Signature (Date)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'Agreement Field' option.
		4.- From 'What is the value of the Data?' picklist select 'Date Signed (Date) (Date)' option.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		

	z) Click on 'Add Mapping' button and then, into the new record displayed:
		1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		2.- From 'Which Salesforce Field to Update?' picklist, select 'Signed for Consent (Boolean)' option.
		3.- From 'Where is the Data Coming From? Select Type' picklist, select 'Constant' option.
		4.- Enter True into 'What is the value of the Data?' text field.
		5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		
		
	a1) Click on 'Add Mapping' button and then, into the new record displayed:
		a1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		a2.- From 'Which Salesforce Field to Update?' picklist, select 'Form Signed By Patient (Boolean)' option.
		a3.- From 'Where is the Data Coming From? Select Type' picklist, select 'Constant' option.
		a4.- Enter True into 'What is the value of the Data?' text field.
		a5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.		
		
	b1) Click on 'Add Mapping' button and then, into the new record displayed:
		b1.- From 'Which Salesforce Object to Update?' picklist, click on 'Selected Object' link and then select 'Patient Services Enrolleee' from the object selector picklist. Then click on Select button.
		b2.- From 'Which Salesforce Field to Update?' picklist, select 'Date of Enrollment Form Recipient (Date)' option.
		b3.- From 'Where is the Data Coming From? Select Type' picklist, select 'Agreement Field' option.
		b4.- From 'What is the value of the Data?' picklist select 'Date Signed (Date) (Date)' option.
		b5.- From 'When to Run Mapping? - Select Agreement Status' picklist, select 'Signed/Approved/Accepted/Form-Filled/Delivered' option.	
| | | | | | |  |    |   |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|
|6|Finally click on Save button.


## Post Deployment Manual Steps for AGIS-897-AddRelatedListAndUpdateForm.

Please execute the following steps:
##### Upload update for PSE Agreement Form 

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|1|Download the update for 'Patient Services Enrollment Form.pdf' document located at data > 'Adobe Sign Form PSE' folder. | | | | | | |    |
|2|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|3|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|4|Click on 'Agreement Templates' Tab and then click on 'Enrollment Form for Patient Services' template showed in the below list.| | | | | | |  |
|5|Click on 'Attachment' and follow the following steps | | | | | | |   |

    a) Go to 'Documents added' section, select the record displayed and then click on the dropdown button, then select 'Remove'.
	b) Go to 'Upload to add a document' section and click on 'Upload Files' button; then select and upload the document downloaded in step#1. Remove '+' signs in case that PDF document name contains them.
	c) Click on 'Save' button (right corner, blue button).

