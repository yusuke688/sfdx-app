public with sharing class VFP_DeleteSomeOpportunities_CTRL {
    public List<Opportunity> selectedOpportunities {get;set;}
    public Integer oppsCount {get; set;}
    
    // Constructor
    public VFP_DeleteSomeOpportunities_CTRL(ApexPages.StandardSetController controller) {
        List<Opportunity> opportunities = controller.getSelected();
        this.selectedOpportunities = [SELECT Id, Account.Name, Name, StageName, Owner.Name FROM Opportunity WHERE Id IN :(new Map<Id, Opportunity>(opportunities)).keySet()];
        this.oppsCount = this.selectedOpportunities.size();
    }

    public void execute() {
        
        delete selectedOpportunities;
    }

    public void back() {

    }
}