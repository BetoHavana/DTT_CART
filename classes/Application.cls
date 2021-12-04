public class Application
{
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork =
			new fflib_Application.UnitOfWorkFactory(
					new List<SObjectType>
					{
							Account.SObjectType,
							AccountShare.SObjectType,
							AccountContactRelation.SObjectType,
							Attachment.SObjectType,
							ContentVersion.SObjectType,
							ContentDocumentLink.SObjectType,
							Schema.Location.SObjectType,
							Schema.AssociatedLocation.SObjectType,
							CareProgramEnrollee.SObjectType,
							CareProgramEnrolleeProduct.SObjectType,
							CareProgramEnrolleeProductShare.SObjectType,
							Case.SObjectType,
							CaseShare.SObjectType,
							CaseTeamMember.SObjectType,
							Contact.SObjectType,
							Group.SObjectType,
							GroupMember.SObjectType,
                            HealthCloudGA__AccountAccountRelation__c.SObjectType,
							HealthCloudGA__AccountAccountRelation__Share.SObjectType,
							HealthCloudGA__CarePlanGoal__c.SObjectType,
							HealthCloudGA__CarePlanGoal__share.SObjectType,
							HealthCloudGA__ContactContactRelation__c.SObjectType,
                            HealthCloudGA__ContactContactRelation__Share.SObjectType,
                            Notification__c.SObjectType,
							Order__share.SObjectType,
							Order__c.SObjectType,
							OrderMilestones__c.SObjectType,
                            PatientServicesEnrollee__c.SObjectType,
							PatientServicesEnrollee__Share.SObjectType,
							Task.SObjectType,
							User.SObjectType,
							UserLogin.SObjectType
					});

	public static final fflib_Application.ServiceFactory Service =
			new fflib_Application.ServiceFactory(
					new Map<Type, Type>
					{
							AccountAccountRelationsService.class => AccountAccountRelationsService.class,
							AccountContactRelationsService.class => AccountContactRelationsService.class,
							AccountsService.class => AccountsService.class,
							AccountSharesService.class => AccountSharesService.class,
							AnaplanNotificationService.class => AnaplanNotificationService.class,
							RecordsSharingService.class => RecordsSharingService.class,
							AssociatedLocationsService.class => AssociatedLocationsService.class,
							CasesService.class => CasesService.class,
							CaseTeamMembersService.class => CaseTeamMembersService.class,
							CarePlanGoalsService.class => CarePlanGoalsService.class,
							CareProgramEnrolleesService.class => CareProgramEnrolleesService.class,
                            CareProgramEnrolleeProductsService.class => CareProgramEnrolleeProductsService.class,
							CaseSharesService.class => CaseSharesService.class,
							ContactContactRelationsService.class => ContactContactRelationsService.class,
							ContactsService.class => ContactsService.class,
							GroupMembersService.class => GroupMembersService.class,
							GroupsService.class => GroupsService.class,
							KnowledgeTopicService.class => KnowledgeTopicService.class,
							KnowledgeArticleService.class => KnowledgeArticleService.class,
							ManufacturingMilestonesUpdateService.class => ManufacturingMilestonesUpdateService.class,
							NotificationsService.class => NotificationsService.class,
							OrdersService.class => OrdersService.class,
							OrderMilestonesService.class => OrderMilestonesService.class,
							PatientServicesEnrolleesService.class => PatientServicesEnrolleesService.class,
							PatientTreatmentMilestonesService.class => PatientTreatmentMilestonesService.class,
							PurchaseOrderService.class => PurchaseOrderService.class,
							SalesOrderUpdateService.class => SalesOrderUpdateService.class,
							SiteProductsService.class => SiteProductsService.class,
							TasksService.class => TasksService.class,
							UsersLoginService.class => UsersLoginService.class,
							UsersService.class => UsersService.class
					});

	public static final fflib_Application.SelectorFactory Selector =
			new fflib_Application.SelectorFactory(
					new Map<SObjectType, Type>
					{
							Account.SObjectType => AccountsSelector.class,
                            AccountShare.SObjectType => AccountSharesSelector.class,
							AccountContactRelation.SObjectType => AccountContactRelationsSelector.class,
							BusinessHours.SObjectType => BusinessHoursSelector.class,
							CarePlanTasksConfigs__mdt.SObjectType => CarePlanTasksConfigsSelector.class,
							CareProgramEnrollee.SObjectType => CareProgramEnrolleesSelector.class,
							CareProgramEnrolleeProduct.SObjectType => CareProgramEnrolleeProductsSelector.class,
							CareProgramProduct.SObjectType => CareProgramProductsSelector.class,
							CareProgramEnrolleeProductShare.SObjectType => CareProgramEnrolleeProductSharesSelector.class,
							Case.SObjectType => CasesSelector.class,
							CaseShare.SObjectType => CaseSharesSelector.class,
							CaseTeamRole.SObjectType => CaseTeamRoleSelector.class,
							CaseTeamMember.SObjectType => CaseTeamMembersSelector.class,
							Contact.SObjectType => ContactsSelector.class,
							ContentDocument.SObjectType => ContentDocumentsSelector.class,
							ContentDocumentLink.SObjectType => ContentDocumentLinksSelector.class,
							ContentVersion.SObjectType => ContentVersionsSelector.class,
							CountryToRegionMapping__mdt.SObjectType => CountryToRegionMappingSelector.class,
							EmailTemplate.SObjectType => EmailTemplatesSelector.class,
							Group.SObjectType => GroupsSelector.class,
							GroupMember.SObjectType => GroupMembersSelector.class,
							HealthCloudGA__AccountAccountRelation__c.SObjectType => AccountAccountRelationSelector.class,
                            HealthCloudGA__AccountAccountRelation__Share.SObjectType => AccountAccountRelationSharesSelector.class,
							HealthCloudGA__CarePlanGoal__c.SObjectType => CarePlanGoalsSelector.class,
							HealthCloudGA__CarePlanGoal__Share.SObjectType => CarePlanGoalSharesSelector.class,
							HealthCloudGA__CarePlanTemplate__c.SObjectType => CarePlanTemplatesSelector.class,
							HealthCloudGA__CarePlanTemplateGoal__c.SObjectType => CarePlanTemplateGoalsSelector.class,
							HealthCloudGA__CarePlanTemplateTask__c.SObjectType => CarePlanTemplateTasksSelector.class,
							HealthCloudGA__ContactContactRelation__c.SObjectType => ContactContactRelationSelector.class,
                            HealthCloudGA__ContactContactRelation__Share.SObjectType => ContactContactRelationSharesSelector.class,
							HealthCloudGA__ReciprocalRole__c.SObjectType => ReciprocalRoleSelector.class,
							KnowledgeArticleVersion.SObjectType => KnowledgeArticleSelector.class,
							KnowledgeDataCategory__mdt.SObjectType => KnowledgeDataCategorySelector.class,
                            Notification__c.SObjectType => NotificationsSelector.class,
							NotificationEngine__mdt.SObjectType => NotificationEngineSelector.class,
							Order__c.SObjectType => OrdersSelector.class,
							Order__Share.SObjectType => OrderSharesSelector.class,
							OrderMilestones__c.SObjectType =>OrderMilestonesSelector.class,
							OrderProcessingRule__mdt.SObjectType => OrderProcessingRulesSelector.class,
							OrderMilestonesDetails__mdt.SObjectType => OrderMilestonesDetailsSelector.class,
							OrderMilestonesUpdateRules__mdt.SObjectType => OrderMilestonesUpdateRulesSelector.class,
							OrderTaskConfig__mdt.SObjectType => OrderTaskConfigSelector.class,
							PatientEnrollmentSteps__mdt.SObjectType => PatientEnrollmentStepsSelector.class,
							PatientLandingPageStatusValue__mdt.SObjectType => PatientTreatmentMilestonesSelector.class,
							PatientServicesEnrollee__c.SObjectType => PatientServicesEnrolleesSelector.class,
							PatientServicesEnrollee__Share.SObjectType => PatientServicesEnrolleeSharesSelector.class,
							PatientServiceEnrolleeTaskConfig__mdt.SObjectType => PatientServiceEnrolleeTaskConfigSelector.class,
							PermissionSet.SObjectType => PermissionSetSelector.class,
							Profile.SObjectType => ProfilesSelector.class,
							Schema.AssociatedLocation.SObjectType => AssociatedLocationsSelector.class,
							RecordShareConfig__mdt.SObjectType => RecordShareConfigSelector.class,
							SiteProduct__c.SObjectType => SiteProductsSelector.class,
							Task.SObjectType => TasksSelector.class,
							TreatmentJourneySteps__mdt.SObjectType => TreatmentJourneyStepsSelector.class,
							Topic.SObjectType => KnowledgeTopicSelector.class,
							TopicAssignment.SObjectType => TopicAssignmentSelector.class,
							User.SObjectType => UsersSelector.class,
							UserLogin.SObjectType => UsersLoginSelector.class,
							UserRole.SObjectType => UserRolesSelector.class
					});

	public static final fflib_Application.SelectorFactory ElevatedSelector =
			new fflib_Application.SelectorFactory(
					new Map<SObjectType, Type>
					{
							CareProgram.SObjectType => CareProgramsSelectorElevatedImp.class
					});

	public static final fflib_Application.DomainFactory Domain =
			new fflib_Application.DomainFactory(
					Application.Selector,
					new Map<SObjectType, Type>
					{
							Account.SObjectType => Accounts.Constructor.class,
                            CareProgramEnrolleeProduct.SObjectType => CareProgramEnrolleeProducts.Constructor.class,
							CareProgramProduct.SObjectType => CareProgramProducts.Constructor.class,
							Case.SObjectType => Cases.Constructor.class,
							CaseTeamMember.SObjectType => CaseTeamMembers.Constructor.class,
							Contact.SObjectType => Contacts.Constructor.class,
							EmailTemplate.SObjectType => EmailTemplates.Constructor.class,
							Group.SObjectType => Groups.Constructor.class,
							GroupMember.SObjectType => GroupMembers.Constructor.class,
							User.SObjectType => Users.Constructor.class,
							HealthCloudGA__AccountAccountRelation__c.SObjectType => AccountAccountRelations.Constructor.class,
							HealthCloudGA__CarePlanGoal__c.SObjectType => CarePlanGoals.Constructor.class,
							HealthCloudGA__ContactContactRelation__c.SObjectType => ContactContactRelations.Constructor.class,
                            Notification__c.SObjectType => Notifications.Constructor.class,
							Order__c.SObjectType => Orders.Constructor.class,
							OrderMilestones__c.SObjectType =>OrderMilestones.Constructor.class,
							PatientServicesEnrollee__c.SObjectType =>PatientServicesEnrollees.Constructor.class,
							Schema.AssociatedLocation.SObjectType => AssociatedLocations.class,
							SiteProduct__c.SObjectType => SiteProducts.Constructor.class,
							Task.SObjectType => Tasks.Constructor.class
					});

	public static final sflib_ILogger logEntry = new sflib_Logger().addAppender(new sflib_logEventAppender());

	public static fflib_ISObjectUnitOfWork getUnitOfWork()
	{
		return Application.UnitOfWork.newInstance();
	}

    public static ISObjectShareSelector getSObjectShareSelectorInstance(SObjectType sObjectType)
    {
        return (ISObjectShareSelector) Application.Selector.newInstance(sObjectType);
    }

}
