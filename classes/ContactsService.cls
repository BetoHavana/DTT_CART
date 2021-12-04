public with sharing class ContactsService
{
	public final static String ACTIVE = 'Active';
	public final static String INACTIVE = 'Inactive';

	private ContactsSelector contactsSelector
	{
		get
		{
			if (null == contactsSelector)
			{
				contactsSelector = (ContactsSelector) Application.Selector.newInstance(Contact.SObjectType);
			}
			return contactsSelector;
		}
		private set;
	}

	public void updateContacts(List<Contact> contactList)
	{
		if (contactList.isEmpty()) return;
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		uow.registerDirty(contactList);
		uow.commitWork();
	}

	public void deactivateContactsAndUsers(List<Account> accounts)
	{
		Set<String> sitePersonasSet = new Set<String>();
		Schema.DescribeFieldResult fieldResult = Account.SitePersona__pc.getDescribe();

		List<Schema.PicklistEntry> sitePersonasPickListEntry = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry sitePersona : sitePersonasPickListEntry)
        {
			sitePersonasSet.add(sitePersona.getLabel());
		}

		Set<Id> deactivatedAccountIds = sflib_ArrayUtils.pluckIdField(accounts, Account.Id);

        List<Contact> contactList = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectContactsByAccountsIdAndStatus(deactivatedAccountIds, sitePersonasSet, ACTIVE);
				 
		deactivateContactsAndUsers(contactList);
	}

	public void deactivateContactsAndUsers(List<Contact> contactList)
	{
		deactivateContactsAndUsers((Contacts) Application.Domain.newInstance(contactList));
	}

	public void deactivateContactsAndUsers(Contacts contacts)
	{
   		fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
		deactivateContactsAndUsers(unitOfWork, contacts);
		unitOfWork.commitWork();
	}

	public void deactivateContactsAndUsers(fflib_ISObjectUnitOfWork unitOfWork, Contacts contacts)
	{
		deactivateContacts(unitOfWork, contacts);
		UsersLoginService.freezeUsers(unitOfWork, contacts.getUserIds());
	}

	private void deactivateContacts(fflib_ISObjectUnitOfWork unitOfWork, Contacts contacts)
	{
		contacts.setStatus(INACTIVE);
   		unitOfWork.registerDirty(contacts.getRecords());
	}

	public Map<Id, Id> getContactByPersonAccountId(Set<Id> contactIds)
	{
		Map<Id, Id> contactIdByPersonAccountId = new Map<Id, Id>();
		if (contactIds == null || contactIds.isEmpty())
		{
			return contactIdByPersonAccountId;
		}
		for (Contact careGiver : contactsSelector.elevatedSelectById(contactIds))
		{
			contactIdByPersonAccountId.put(careGiver.Id, careGiver.AccountId);
		}
		return contactIdByPersonAccountId;
	}

}