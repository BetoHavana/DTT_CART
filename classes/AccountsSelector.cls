public with sharing class AccountsSelector extends fflib_SObjectSelector
{
	public static final String PATIENTRECORDTYPEDEVELOPERNAME = 'Patient';
	string accountId = Account.Id.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Account.AccountIdentifier__c,
				Account.PersonBirthdate,
				Account.CellTherapyOrderSpecialist__c,
				Account.CustomerCode__c,
				Account.Email__c,
				Account.ERPSiteID__c,
				Account.FirstName,
				Account.Id,
				Account.isPersonAccount,
				Account.LastName,
				Account.MiddleName,
				Account.Name,
				Account.ParentId,
				Account.PatientID__c,
				Account.PersonContactId,
				Account.PersonEmail,
				Account.PrimaryContactNumberType__c,
				Account.PreferredMethodOfCommunication__c,
				Account.Phone,
				Account.RecordTypeId,
				Account.Status__c,
				Account.Type
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Account.SObjectType;
	}

	public Accounts selectById(Set<Id> accountId)
	{
		return (Accounts) Application.Domain.newInstance(
				(List<Account>) selectSObjectsById(accountId)
		);
	}

	public Accounts selectAll()
	{
		return (Accounts) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
								.toSOQL()
				)
		);
	}

	public Accounts selectPatients()
	{
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PATIENTRECORDTYPEDEVELOPERNAME).getRecordTypeId();
		return (Accounts) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.selectField('PersonContactId')
								.selectField('PersonBirthdate')
								.selectField('Status__c')
								.setCondition('RecordTypeId=:recordTypeId')
								.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
								.toSOQL()
				)
		);
	}

	public List<Account> selectContactsByAccountId(Set<Id> accountIds)
	{
		List<String> conFields = new List<String> {'Id', 'AccountId'};
		fflib_QueryFactory queryFactory = newQueryFactory();
		queryFactory.subselectQuery('Contacts')
				.selectFields(conFields);
		queryFactory.setCondition('Id IN:accountIds');
		return (List<Account>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
	}

	public List<Account> selectAllContactsForAccount(String recTypeId)
	{
		List<String> conFields = new List<String> {'Id', 'AccountId'};
		fflib_QueryFactory queryFactory = newQueryFactory()
				.setCondition('RecordTypeId =:recTypeId');
		queryFactory
				.subSelectQuery('Contacts')
				.selectFields(conFields);
		return (List<Account>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
	}

	public List<Account> getCryoTypeForSites(Set<Id> accountIds, Id recTypeId)
	{
		return ((List<Account>) Database.query(
				newQueryFactory()
						.selectField('Type')
						.setCondition('Id IN:accountIds AND RecordTypeId=:recTypeId')
						.toSOQL()
		));
	}

	public List<Account> selectByNameGenderAndDateOfBirth(String firstName, String middleName, String lastName, String gender, Date dateOfBirth)
	{
		return ((List<Account>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__Gender__pc')
						.selectField('PersonBirthdate')
						.setCondition('FirstName =:firstName AND MiddleName=:middleName AND LastName=:lastName AND HealthCloudGA__Gender__pc=:gender AND PersonBirthdate=:dateOfBirth')
						.toSOQL()
		));
	}

	public List<Account> selectByDeveloperName(String recTypeId)
	{
		return ((List<Account>) Database.query(
				newQueryFactory()
						.setCondition('RecordTypeId=:recTypeId')
						.toSOQL()));
	}

	public List<Account> elevatedGetCryoTypeForSites(Set<Id> accountIds, Id recTypeId)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedGetCryoTypeForSites(accountIds, recTypeId);

	}

	public List<Account> elevatedSelectByERPSiteId(String erpSiteId, String recTypeId)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectByERPSiteId(erpSiteId, recTypeId);
	}

	public List<Account> elevatedSelectById(Set<Id> accountIds)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectById(accountIds);
	}

	private without sharing class elevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private elevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

	private List<Account> elevatedGetCryoTypeForSites(Set<Id> accountIds, Id recTypeId)
		{
			Set<String> fieldSet = new Set<String>();
			fieldSet.add('Type');
			queryFactory.selectFields(fieldSet);
			queryFactory.setCondition('Id IN:accountIds AND RecordTypeId=:recTypeId');
			return (List<Account>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		private List<Account> elevatedSelectByERPSiteId(String erpSiteId, String recTypeId)
		{
			String erpSite = Account.ERPSiteID__c.getDescribe().getName();
			queryFactory.setCondition(erpSite + ' =:erpSiteId AND RecordTypeId=:recTypeId');
			return (List<Account>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		private List<Account> elevatedSelectById(Set<Id> accountIds)
		{
			queryFactory.setCondition('Id IN:accountIds');
			queryFactory.selectField('Parent.RecordTypeId');
			return (List<Account>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}

	public List<Account> selectTreatmentSiteByIds(Set<Id> treatmentSiteIds){
		return ((List<Account>) Database.query(
				newQueryFactory()
						.selectField('ERPSiteID__c')
						.setCondition( accountId +' IN :treatmentSiteIds')
						.toSOQL()));
	}

	public List<Account> selectByAccountIds(Set<Id> accountIds)
	{
		return ((List<Account>) Database.query(
				newQueryFactory()
						.setCondition('Id IN:accountIds')
						.toSOQL()));
	}

}
