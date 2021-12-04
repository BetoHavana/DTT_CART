## AGIS-634 Pre Deployment Manual steps

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES|   
|1|Inside salesforce go to setup -> quick find: Duplicate Rules. | | | | | | | |
    
    1.1 - Look for 'CustomRuleForPersonAccountWithDuplicatePatients' rule and click on it.
    1.2 - Click on 'Deactivate' button.

|   |   ||||||||    
|---:|:---|:---|:---|:---|:---|:---|:---|:---|
|2| Inside salesforce go to setup -> quick find: Matching Rules. | | | | | | | |
    
    2.1 - Look for 'CustomRuleForAccountWithDuplicatePatientsMatchingRule' rule and click on it. 
    2.2 - Click on 'Deactivate' button, then click 'Ok' button in the window message.

