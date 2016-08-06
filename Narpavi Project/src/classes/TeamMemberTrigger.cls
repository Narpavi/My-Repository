/*
* Change History:
* Developer : Raghu Ramanujam
* Date      : 22/0/2015
* Comments  : Nationality Field was not updating when editing Team Member Record.
* Change Search : SS-707458
*
* Developer: Ian Finch
* Date: 23/06/2016
* Comments: Added updateContactViaFairsailIntegration()
*/
public without sharing class TeamMemberTrigger
{

    private TeamMemberTrigger(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
    public void execute(){
        if(trigger.isAfter){            
            if(trigger.isUpdate)
            {
                updateContactViaFairsailIntegration();           
                updateNationality();              
            }            
        }        
    }
 
    //SCS-1372 - TPT Added - Update Nationality1 field from HCM Forms
    //Poornima : Code bulkified for SS-10986082 Fix dated 22/04/2016
    public void updateNationality()
    {
        List<fHCM2__Team_Member__c> lstToUpdateTM=new List<fHCM2__Team_Member__c>();
        List<fHCM2__Team_Member__c> lstTeamMember=[SELECT id,Nationality_1__c,Help_NationalityText__c FROM fHCM2__Team_Member__c WHERE id IN:trigger.new];      
        if(lstTeamMember.size()>0)
        {
            for(fHCM2__Team_Member__c teammember:lstTeamMember)
            {
                fHCM2__Team_Member__c tm=new  fHCM2__Team_Member__c ();
                tm.Id=teammember.Id;
                //Start of changes for SS-707458: Not able to update Nationality
                //tm.Nationality_1__c= tm.Help_NationalityText__c;
                    
                if(teammember.Help_NationalityText__c <> NULL) 
                {    
                    tm.Nationality_1__c= teammember.Help_NationalityText__c;
                    lstToUpdateTM.add(tm);
                }
                //End of Changes for for SS-707458: Not able to update Nationality              
            } 
            if(lstToUpdateTM.size()>0)           
                update lstToUpdateTM;
        }                      
    }
    
    // When team member changes, copy relevant fields to linked contacts
    // existing FairsailIntegrationHandler code now being called from TeamMemberTrigger
    // rather than via its own trigger
    // Ian Finch 23/Jun/2016
    public void  updateContactViaFairsailIntegration()
    {
        List<fHCM2__Team_Member__c> scope = Trigger.new;
        List<fHCM2__Team_Member__c> tmsLinkedToContacts =new List<fHCM2__Team_Member__c>();
        for (fHCM2__Team_Member__c tm: scope)
        {
            if (tm.VSO_Recruit_Contact_Record__c != null)
            {
                tmsLinkedToContacts.add(tm);
            }
        }
        // call code in FairsailIntegrationHandler to do the actual sync
        FairsailIntegrationHandler.getHandler().ProcessTeamMemberChanged(tmsLinkedToContacts);
    }
 
    public static TeamMemberTrigger getHandler()
    {
        if(handler == null){
            handler = new TeamMemberTrigger();
        }
        return handler;
    }
    
    private static TeamMemberTrigger handler;
    
    
    private static boolean trueFirstTimeOnly = true;
    
    // static function will only return true once in each transaction
    // used to avoid trigger recursion
    // see http://help.salesforce.com/apex/HTViewSolution?id=000133752&language=en_US
    public static boolean runOnce()
    {
         if(trueFirstTimeOnly){
            trueFirstTimeOnly = false; 
            return true;
        }else{
            return false;
        }
    }
    
    // for testing
    public static void ClearRunOnce()
    {
        trueFirstTimeOnly = true;
    }

}