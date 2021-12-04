public abstract inherited sharing class BusinessHoursCalculator
{
	public static final Integer oneDayToMilliSeconds = 24 * 60 * 60 * 1000;

	Id businessHoursId;

	public BusinessHoursCalculator(Id businessHoursId)
	{
		if (string.isBlank((string) businessHoursId))
		{
			throw new BusinessHoursCalculatorException();
		}
		this.businessHoursId = businessHoursId;
	}

	public virtual DateTime getNextBusinessHourDateTime(Date dateInfo)
	{
		return BusinessHours.nextStartDate(businessHoursId, Datetime.newInstanceGmt(dateInfo.year(),
				dateInfo.month(), dateInfo.day()));
	}

	public virtual Date getDueDateBasedOnBusinessHours(DateTime nextBusinessDay, Integer noOfDaysToReachDueDate)
	{
		return BusinessHours.add(businessHoursId, nextBusinessDay,
				noOfDaysToReachDueDate * oneDayToMilliSeconds).date() ;
	}

	public virtual Long getDifferenceBetweenTimeSpans(Datetime startDate, Datetime endDate)
	{
		return BusinessHours.diff(businessHoursId, startDate, endDate);
	}

	public virtual Boolean getIsWithinBusinessHours(Datetime targetDate)
	{
		return BusinessHours.isWithin(businessHoursId, targetDate);
	}

	public class BusinessHoursCalculatorException extends Exception
	{
	}
}