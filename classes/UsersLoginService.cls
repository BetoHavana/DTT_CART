public with sharing class UsersLoginService 
{
    public static void freezeUsers(fflib_ISObjectUnitOfWork unitOfWork, Set<Id> userIds)
    {
        List<UserLogin> usersToFreeze = ((UsersLoginSelector) Application.Selector.newInstance(UserLogin.SObjectType))
        .selectByUserIds(userIds);

        for(UserLogin uLogin : usersToFreeze)
        {
            uLogin.IsFrozen = true;
        }

        if(!usersToFreeze.isEmpty())
        {
			unitOfWork.registerDirty(usersToFreeze);
        }

    }
}