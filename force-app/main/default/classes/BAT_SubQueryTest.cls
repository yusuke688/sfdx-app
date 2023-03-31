public with sharing class BAT_SubQueryTest implements Database.batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query; 
        query = 'SELECT Id, Name, (SELECT Id, Name FROM Opportunities ORDER BY Name) ';
        query += 'FROM Account ';
        query += 'ORDER BY Name';

        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        for(Account acc: scope){
            System.debug('取引先:' + acc.Name);
            for(Opportunity opp: acc.Opportunities){

                wrapper w = new wrapper();

                exe(w.name);
            }
        }

    }
    public void finish(Database.BatchableContext BC){
    }

    private void exe(String name){
        System.debug('商談:' + name);
    }

    class wrapper {
        String name;

        wrapper(){
            name = 'test-----';
        }
    }
}
