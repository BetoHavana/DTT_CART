public with sharing class PatientServicesEnrolleesLetterService implements Queueable{
    private static final String SALESFORCE = 'S';
    private static final String READ_ONLY = 'V';
    private static final String ALL_USERS = 'AllUsers';
    Map<String, EmailTemplate> emailTemplatesByDeveloperName;
    Map<String,Set<Id>> pseIdsByEmailTemplateDeveloperNames;

    public PatientServicesEnrolleesLetterService(
        Map<String, EmailTemplate> emailTemplatesByDeveloperName,
        Map<String,Set<Id>> pseIdsByEmailTemplateDeveloperNames)
    {
        this.emailTemplatesByDeveloperName = emailTemplatesByDeveloperName;
        this.pseIdsByEmailTemplateDeveloperNames = pseIdsByEmailTemplateDeveloperNames;
    }

    public void execute(QueueableContext context) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        Map<Id,List<ContentVersion>> contentVersionIdBypatientServicesId = new Map<Id,List<ContentVersion>>();

        EmailTemplate emailTemplate;
        Messaging.SingleEmailMessage emailMessage;

        ContentVersion contVersion;
        List<ContentVersion> contentVersionList;

        ContentVersionsService cvs = new ContentVersionsService();
        String pdfTitle;

		for(String developerName : pseIdsByEmailTemplateDeveloperNames.keySet())
		{
            for(Id pseId : pseIdsByEmailTemplateDeveloperNames.get(developerName))
            {
                if(!contentVersionIdBypatientServicesId.containsKey(pseId))
                {
                    contentVersionIdBypatientServicesId.put(pseId, new List<ContentVersion>());
                }

                emailTemplate = emailTemplatesByDeveloperName.get(developerName);
                emailMessage = Messaging.renderStoredEmailTemplate(emailTemplate.Id, UserInfo.getUserId(), pseId);

                pdfTitle = PatientServicesEnrolleesService.getPDFNameByDevelopername(developerName);
                contVersion = cvs.getContentVersionToInsert(
                                SALESFORCE,
                                Blob.toPdf(String.valueOf(emailMessage.getHtmlBody())),
                                pdfTitle,
                                pdfTitle
                );

                cvList.add(contVersion);

                contentVersionList = contentVersionIdBypatientServicesId.get(pseId);
                contentVersionList.add(contVersion);
                contentVersionIdBypatientServicesId.put(pseId, contentVersionList);
            }
        }

        if(!cvList.isEmpty())
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerNew(cvList);
			uow.commitWork();
        }

        Set<Id> cvIds = sflib_ArrayUtils.pluckIdField(cvList, ContentVersion.Id);
        Map<Id, ContentVersion> contentVersionById = new Map<Id, ContentVersion>(((ContentVersionsSelector) Application.Selector
                                                    .newInstance(ContentVersion.SObjectType))
                                                    .getContentVersionById(cvIds));

        ContentDocumentLink conDocLink;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(Id pseId : contentVersionIdBypatientServicesId.keySet())
        {
            for(ContentVersion contentVersion : contentVersionIdBypatientServicesId.get(pseId))
            {
                conDocLink = cvs.getContentDocumentLinkToInsert(
                                pseId,
                                contentVersionById.get(contentVersion.Id).ContentDocumentId,
                                READ_ONLY,
                                ALL_USERS
                );
                cdlList.add(conDocLink);
            }
        }

        if(!cdlList.isEmpty())
        {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(cdlList);
			uow.commitWork();
        }
    }

}

