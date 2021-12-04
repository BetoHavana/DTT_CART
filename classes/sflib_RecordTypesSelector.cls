/**
 * File Name: sflib_RecordTypesService 
 * Description: 
 * Copyright (c) 2018 Johnson & Johnson
 * @author: architect ir. William G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public virtual with sharing class sflib_RecordTypesSelector
{


	/**
	 * getRecordTypeId
     *
	 * @description Get the RecordType Id based on Object name and Recordtype Name from Schema
	 *
	 * @param sObjectType The name of the SObject
	 * @param recordTypeName The name of requested recordtype
	 *
	 * @return Id Record Type Id
	 * @example
	 * AR_RecordTypeService.getRecordTypeId(single_asset)
	 */

	public static Id selectByName(SObjectType sObjectType, String recordTypeName)
	{
		return selectByNames(sObjectType, new Set<String> {recordTypeName}).values().get(0);
	}


	public static Id selectByDeveloperName(SObjectType sObjectType, String recordTypeName)
	{
		return selectByDeveloperNames(sObjectType, new Set<String> {recordTypeName}).values().get(0);
	}


	public static Map<String, Id> selectByNames(sObjectType sObjectType, Set<String> recordTypeDeveloperNames)
	{
		return fetchRecordTypeId(
				sObjectType.getDescribe().getRecordTypeInfosByName(),
				sObjectType,
				recordTypeDeveloperNames
		);
	}


	public static Map<String, Id> selectByDeveloperNames(sObjectType sObjectType, Set<String> recordTypeDeveloperNames)
	{
		return fetchRecordTypeId(
				sObjectType.getDescribe().getRecordTypeInfosByDeveloperName(),
				sObjectType,
				recordTypeDeveloperNames
		);
	}


	private static Map<String, Id> fetchRecordTypeId(
			Map<String, RecordTypeInfo> recordTypeInfosByStrings,
			SObjectType sObjectType,
			Set<String> recordTypeNames)
	{
		return fetchRecordTypeId(
				recordTypeInfosByStrings,
				sObjectType.getDescribe().getName(),
				recordTypeNames
		);
	}


	private static Map<String, Id> fetchRecordTypeId(
			Map<String, RecordTypeInfo> recordTypeInfosByStrings,
			String sObjectName,
			Set<String> recordTypeNames)
	{
		Map<String, Id> results = new Map<String, Id>();
		for (String recordTypeName : recordTypeNames)
		{
			if (recordTypeInfosByStrings.containsKey(recordTypeName))
			{
				results.put(recordTypeName, recordTypeInfosByStrings.get(recordTypeName).getRecordTypeId());
			}
			else
			{
				throw new sflib_RecordTypesServiceException(
						String.format('Unknown record type {0} for SObject {1}',
								new List<String> {recordTypeName, sObjectName}
						)
				);
			}
		}
		return results;
	}

	private static Map<Id, String> fetchRecordTypeInfoById(
			Map<String, RecordTypeInfo> recordTypeInfosByStrings,
			String sObjectName,
			Set<String> recordTypeNames)
	{
		Map<Id, String> results = new Map<Id, String>();
		for (String recordTypeName : recordTypeNames)
		{
			if (recordTypeInfosByStrings.containsKey(recordTypeName))
			{
				results.put(recordTypeInfosByStrings.get(recordTypeName).getRecordTypeId(), recordTypeName);
			}
			else
			{
				throw new sflib_RecordTypesServiceException(
						String.format('Unknown record type {0} for SObject {1}',
								new List<String> {recordTypeName, sObjectName}
						)
				);
			}
		}

		return results;
	}

	public static Map<Id, String> selectRecordTypeByDeveloperNames(sObjectType sObjectType, Set<String> recordTypeDeveloperNames)
	{
		return fetchRecordTypeInfoById(
				sObjectType.getDescribe().getRecordTypeInfosByDeveloperName(),
				sObjectType.getDescribe().getName(),
				recordTypeDeveloperNames
		);
	}


	public class sflib_RecordTypesServiceException extends Exception
	{
	}
}