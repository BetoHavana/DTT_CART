# CAR-T Project

## Post Deployment Manual Steps for AGIS-155.

Please execute the following steps:

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|Enable the 'Allow Sending on Behalf of Others' setting for the Adobe Sign Agreements
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Go to Setup > Quick Find > Enter 'Custom Settings' > Then click on 'Adobe Sign Settings' link.| | | | | | | |
|3|Click the Manage button.| | | | | | | |
|4|Click the New (or Edit) button.| | | | | | | |
|5|Find (ctrl/cmd +f) the 'Allow Sending On Behalf of Others' setting and enable the checkbox.| | | | | | | |
|6|Click the Save button| | | | | | | |

##### Add the 'DC – Allow Sending as Other Users' field to the User record layout

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Go to Setup > Object Manager > Search and select the User object.| | | | | | | |
|3|Select User Page Layouts from the left rail of the User object page.| | | | | | | |
|4|Click the User Layout link.| | | | | | | |
|5|With Fields selected, click 'Adobe Sign Allow Sending As Other Users' button and drag it to the 'Additional Information (Header visible on edit only)' section of the layout.| | | | | | | |
|6|Click the Save button.| | | | | | | |

##### Enable 'Adobe Sign Allow Sending as Other Users' option for the JnJ Adobe Sign User (with the email tempocart@its.jnj.com)

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Go to Setup > Users > Click on New user and enter the following details: | | | | | | | |
	a) First Name: Adobe Sign
	b) Last Name: User
	c) Email: tempocart@its.jnj.com
	d) Username: adobesignuser@its.jnj.com
	e) Profile: Internal Base User
	f) User License: Salesforce
| | | | | | |  |    |   |
|---:|:---|:---|:---|:---|:---|:---|:---|:---| 	
|3|Click on Save button| | | | | | | |
|4|In the User Setup screen for the new user created - Adobe Sign User, go to Permission Set Assignments, click on Edit Assignments and assign the next permission sets:| | | | | | | |
	- Adobe Sign Admin
	- Adobe Sign Integration
	- Adobe Sign User
| | | | | | |  |    |   |
|---:|:---|:---|:---|:---|:---|:---|:---|:---| 	
|5|In the User Setup screen for the new user created - Adobe Sign User, click on Edit and then enable the Adobe Sign Allow Sending as Other Users option.| | | | | | | |
|6|Click the Save button.| | | | | | | |

##### Add the 'Send On Behalf Of Others' field to the Agreement page layout

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Go to Setup > Object Manager > Search and select the Agreement object.| | | | | | | |
|3|Click Field Sets option from the left rail of the Agreement object page and then click on the 'Additional Fields' link| | | | | | | |
|4|With Agreement selected, locate the 'Send On Behalf Of' button then click and drag it to the In the Field Set section.| | | | | | | |
|5|Click the Save button.| | | | | | | |

##### Update the 'Enrollment Form for Patient Services' agremment template with the correct Adobe Sign User Id

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES| 
|1|Login to respective Salesforce Environment as an Administrator.| | | | | | | |
|2|Go to the Developer Console > Query Editor > Execute the below query to retrive the User Id for the Adobe Sign account (tempocart@its.jnj.com) .| | | | | | | |
|3|Select id from User where email = 'tempocart@its.jnj.com'
|4|Click on App Launcher button to show the App Launcher, then find and click 'Adobe Sign Admin' item.| | | | | | | |
|5|Click on 'Agreement Templates' link and then click on the 'Enrollment Form for Patient Services' agreement template.| | | | | | | |
|6|Click on 'Recipients' tab and enter the User id from step #2 into the 'Send on Behalf of' text field.| | | | | | | |
|7|Click the Save button.| | | | | | | | 

