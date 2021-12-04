public interface ISObjectShareSelector {
    Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds);
}