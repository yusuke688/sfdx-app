public with sharing class VFP_DeleteSomeOpportunities_CTRL {
    public List<Opportunity> selectedOpportunities {get;set;}
    public Integer oppsCount {get; set;}
    public String errorMsg {get; set;}
    
    // Constructor
    public VFP_DeleteSomeOpportunities_CTRL(ApexPages.StandardSetController controller) {
        List<Opportunity> opportunities = controller.getSelected();
        this.selectedOpportunities = [SELECT Id, Account.Name, Name, StageName, Owner.Name FROM Opportunity WHERE Id IN :(new Map<Id, Opportunity>(opportunities)).keySet()];
        this.oppsCount = this.selectedOpportunities.size();
    }

    public void execute() {
        
        try {
            delete selectedOpportunities;
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(message);
        }
    }

    public void back() {

    }
}