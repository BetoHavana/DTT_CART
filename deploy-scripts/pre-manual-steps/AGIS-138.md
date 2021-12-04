## AGIS-138 Pre Deployment Manual steps

| # | Description | PREDEV | DEV | PREQA | SIT | UAT | PREPROD | PRODUCTION |   
|---:|:---|:---|:---|:---|:---|:---|:---|:---|  
|	|	|YES|YES|YES|YES|YES|YES|YES|
|1| Inside salesforce go to setup -> quick find: Roles. Click on Internal Site Administrator role. 
    1.1 - Click on Users in Internal Site Administrator Role.
    
    1.2 - Scroll down until you can see the list view Users in Internal Site Administrator Role.
    
    1.3 - Now repeat the following actions until there is no more users in the list view.
        -click over the "Edit" button left to each user name.
        -remove Internal Site Administrator Role.
        -Click save.