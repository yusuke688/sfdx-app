public with sharing class SCH_MonthlySalesCreater implements Schedulable {
    public void execute(SchedulableContext SC) {
        Id batchId = Database.executeBatch(new BAT_MonthlySalesCreater(), 200);
    }
}
