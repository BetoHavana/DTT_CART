if (String.isBlank(sflib_Settings.get('Number Of Business Days Excluded')))
{
    sflib_Settings.set('Number Of Business Days Excluded', '2');
}

if (String.isBlank(sflib_Settings.get('Number of Days For Reschedule')))
{
    sflib_Settings.set('Number of Days For Reschedule', '1');
}
