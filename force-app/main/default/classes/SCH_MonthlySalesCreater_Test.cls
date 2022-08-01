@IsTest
public with sharing class SCH_MonthlySalesCreater_Test {
    @IsTest
    public static void test(){
        
        SCH_MonthlySalesCreater mscs = new SCH_MonthlySalesCreater();
        String sch = '0 0 0 1 ';
        sch += String.valueOf(Date.today().month() + 1);
        sch += ' ?';
        
        Test.startTest();
        
        system.schedule('MonthlySalesCreateSchedulerTest', sch, mscs);

        Test.stopTest();

    }
}
