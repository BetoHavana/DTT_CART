trigger CareProgramEnrolleeProductTrigger on CareProgramEnrolleeProduct (after insert)
{
	fflib_SObjectDomain.triggerHandler(CareProgramEnrolleeProducts.class);
}