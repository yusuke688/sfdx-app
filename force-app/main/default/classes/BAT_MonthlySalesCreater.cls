public with sharing class BAT_MonthlySalesCreater implements Database.batchable<sObject>{

    public final Date today;
    public final String yearAndMonth;

    public BAT_MonthlySalesCreater() {
        today = Date.today();
        yearAndMonth = String.valueOf(today.year()) + String.valueOf(today.month()).leftPad(2, '0');
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String query; 
        query = 'SELECT Id, ContractNumber, Account.name, StartDate, EndDate ';
        query += 'FROM Contract ';
        query += 'WHERE StartDate <= TODAY ';
        query += 'AND EndDate >= TODAY ';
        query += 'AND Status = ' + '\'Activated\' ';
        query += 'ORDER BY ContractNumber';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contract> scope){
        
        System.debug('BAT_MonthlySalesCreater excute-start');
        System.debug('Contract Count(Scope):' + scope.size());

        // 契約をマップとして保持
        Map<Id, Contract> contractMap = new Map<Id, Contract>(scope);
        // Insertする月次売上のリスト
        List<MonthlySales__c> mss = new List<MonthlySales__c>();
        // Insertする月次売上明細のリスト
        List<MonthlySalesDetail__c> msds = new List<MonthlySalesDetail__c>();
        // 契約IDと月次売上明細リストのマップ
        Map<Id, List<MonthlySalesDetail__c>> contractIdAndMonthlySalesDetailsMap = new Map<Id, List<MonthlySalesDetail__c>>();

        // データベースセーブポイント
        Savepoint sp = Database.setSavepoint();
        
        // 1.契約を参照する商談と商品を取得し、ループする
        for(Opportunity o :[
            SELECT 
                Name
                , ContractId
                , Contract.ContractNumber
                , (SELECT Id, Name FROM OpportunityLineItems)
            FROM Opportunity 
            WHERE ContractId =: contractMap.keySet()
            ORDER BY Contract.ContractNumber
        ]){
            System.debug('契約ID     契約番号:' + o.ContractId + '-' + o.Contract.ContractNumber);
            System.debug('商談ID     名前    :' + o.Id + '-' + o.Name );
            // 2.商談商品をもとに月次売上明細を作成
            List<MonthlySalesDetail__c> msds2 = new List<MonthlySalesDetail__c>();
            for(OpportunityLineItem oi: o.OpportunityLineItems){
                System.debug('商談商品ID 名前    :' + oi.Id + '-' + oi.Name );
                msds2.add(new MonthlySalesDetail__c(
                    OpportunityItem__c = oi.Id
                ));
            }

            // 3.契約IDがすでにcontractIdAndMonthlySalesDetailsMapに登録されているか確認する。
            if(contractIdAndMonthlySalesDetailsMap.containsKey(o.ContractId)){
                // 3-1.ある場合、月次売上明細リストを追加する。
                System.debug('契約IDがマップに存在するため、月次売上明細をadd');
                contractIdAndMonthlySalesDetailsMap
                .get(o.ContractId)
                .addAll(msds2);
            } else {
                // 3-2.ない場合、新しくmapにIdを登録し、月次売上明細リストを追加する。
                System.debug('契約IDがマップに存在しないため、月次売上明細をput');
                contractIdAndMonthlySalesDetailsMap.put(
                    o.ContractId
                    , msds2
                );
            }
            System.debug('::::::::::::::::::::::::::');
        }

        // 4.contractIdAndMonthlySalesDetailsMapの契約ID分、mssを作成する。
        for(Id contractId : contractIdAndMonthlySalesDetailsMap.keySet()){
            mss.add(
                new MonthlySales__c(
                    Contract__c = contractId
                    ,YearAndMonth__c = yearAndMonth
                )
            );
        }

        System.debug('月次売上レコード数:' + mss.size());

        // 5.mssをインサートする。
        try {
            insert mss;    
        } catch (Exception e) {
            System.debug('月次売上のインサートでエラーが発生');
            System.debug(e.getMessage());
            Database.rollback(sp);
        }
        
        
        // 6.mssのIDをcontractIdAndMonthlySalesDetailsMapのValueの月次売上Idに登録する。
        for(MonthlySales__c ms : mss){
            for(MonthlySalesDetail__c msd : contractIdAndMonthlySalesDetailsMap.get(ms.Contract__c)){
                msd.MonthlySales__c = ms.Id;
                msds.add(msd);
            }
        }
        
        System.debug('月次明細売上レコード数:' + msds.size());
        
        // 8.7をインサートする。
        try {
            insert msds;    
        } catch (Exception e) {
            System.debug('月次売上明細のインサートでエラーが発生');
            System.debug(e.getMessage());
            Database.rollback(sp);
        }


        // Database.rollback(sp);
    }
   
    public void finish(Database.BatchableContext BC){
        System.debug('finish-start');
        AsyncApexJob a = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody
        
        ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('finish-end');
    }
}
