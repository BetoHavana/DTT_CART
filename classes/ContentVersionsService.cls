public with sharing class ContentVersionsService {

    public ContentVersion getContentVersionToInsert(String contLocation, Blob verData, String title, String pathOnClient)
    {
        return new ContentVersion(
            ContentLocation = contLocation,
            VersionData = verData,
            Title = title,
            PathOnClient = pathOnClient
        );
    }

    public ContentDocumentLink getContentDocumentLinkToInsert(Id linkedEntityId, Id contDocumentId, String shareType, String visibility)
    {
        return New ContentDocumentLink(
            LinkedEntityId = linkedEntityId,
            ContentDocumentId = contDocumentId,
            ShareType = shareType,
            Visibility = visibility
        );
    }
}
