@IsTest
public with sharing class BAT_MonthlySalesCreater_Test {
    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();
        List<Contract> contracts = new List<Contract>();
        List<Opportunity> opps = new List<Opportunity>();
        List<OpportunityLineItem> oppItems = new List<OpportunityLineItem>();
        List<Product2> products = new List<Product2>();
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();

        /**
         * 取引先
         */
        for(Integer i = 1; i <= 1; ++i){
            String name = 'BAT_MonthlySalesCreater_Test-' + String.valueOf(i).leftPad(5, '0');
            accounts.add(new Account(Name = name));
        }
        insert accounts;

        /**
         * 契約
         * ドラフトで登録してからアクティブに変更
         */
        for(Account a: accounts){
            contracts.add(
                new Contract(
                    AccountId = a.Id
                    , StartDate = Date.Today()
                    , ContractTerm = 12
                    , Status = 'Draft'
                )
            );
        }
        insert contracts;

        for(Contract c: contracts){
            c.Status = 'Activated';
        }
        update contracts;
        
        /**
         * 商談
         */
        Account a = Accounts[0];
        Contract c = contracts[0];

        for(Integer i = 1; i <= 2; ++i){
            opps.add(new Opportunity(
                AccountId = a.Id
                , Name = a.Name + '-Opp-' + String.valueOf(i).leftPad(5, '0')
                , CloseDate = Date.today() + 60
                , StageName = '見込対象'
                , ContractId = c.Id
                , Pricebook2Id = Test.getStandardPricebookId()
            ));
        }

        insert opps;

        /**
         * 商品
         */
        for(Integer i = 1; i <= 5; ++i){
            String name = 'testProduct-' + String.valueOf(i).leftPad(5, '0');
            products.add(new product2(Name = name));
        }
        insert products;

        /**
         * 価格表エントリ
         */
        Integer price = 1000;
        for(Product2 p: products){
            priceBookEntries.add(
                new PriceBookEntry(
                    Pricebook2Id = Test.getStandardPricebookId()
                    , Product2Id = p.Id
                    , UnitPrice = price
                    , IsActive  = true
                )
            );
            price += 1000; 
        }
        insert priceBookEntries;

        /**
         * 商談商品
         */
        PriceBookEntry pbe1 = priceBookEntries[0];
        PriceBookEntry pbe2 = priceBookEntries[1];
        PriceBookEntry pbe3 = priceBookEntries[2];
        PriceBookEntry pbe4 = priceBookEntries[3];
        PriceBookEntry pbe5 = priceBookEntries[4];

        Opportunity opp1 = opps[0];
        Opportunity opp2 = opps[1];

        Integer quantity = 1;

        oppItems.add(new OpportunityLineItem(
            OpportunityId = opp1.Id
            , Product2Id = pbe1.Product2Id
            , Quantity = quantity
            , TotalPrice = pbe1.UnitPrice * quantity
        ));
        oppItems.add(new OpportunityLineItem(
            OpportunityId = opp1.Id
            , Product2Id = pbe2.Product2Id
            , Quantity = quantity
            , TotalPrice = pbe2.UnitPrice * quantity
        ));
        oppItems.add(new OpportunityLineItem(
            OpportunityId = opp1.Id
            , Product2Id = pbe3.Product2Id
            , Quantity = quantity
            , TotalPrice = pbe3.UnitPrice * quantity
        ));
        oppItems.add(new OpportunityLineItem(
            OpportunityId = opp2.Id
            , Product2Id = pbe4.Product2Id
            , Quantity = quantity
            , TotalPrice = pbe4.UnitPrice * quantity
        ));
        oppItems.add(new OpportunityLineItem(
            OpportunityId = opp2.Id
            , Product2Id = pbe5.Product2Id
            , Quantity = quantity
            , TotalPrice = pbe5.UnitPrice * quantity
        ));
        insert oppItems;

    }

    @IsTest
    static void test1(){
        
        Test.startTest();
        Id batchId = Database.executeBatch(new BAT_MonthlySalesCreater(), 200);
        Test.stopTest();
        
    }
}
