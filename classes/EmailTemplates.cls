public with sharing class EmailTemplates extends fflib_SObjectDomain
{
    public EmailTemplates(List<EmailTemplate> records)
    {
        super(records);
	    //TO DO : Temp Fix. Need to delete this class. (We cannot grant community users access to EmailTemplate object)
	    Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new EmailTemplates(sObjectList);
		}
	}

    public Map<String,EmailTemplate> getEmailTemplatesByDeveloperName()
    {
        Map<String,EmailTemplate> emailTemplatesByDeveloperName = new Map<String,EmailTemplate>();
		for(EmailTemplate emailTemplate : (List<EmailTemplate>) Records)
		{
			emailTemplatesByDeveloperName.put(emailTemplate.developerName, emailTemplate);
        }
        
        return emailTemplatesByDeveloperName;
    }
}
