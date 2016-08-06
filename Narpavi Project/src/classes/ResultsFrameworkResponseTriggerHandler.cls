/* * Created By: Dinesh -TPT
   * Project Name: M&E Implementation
   * Created Date: (14-Mar-2016)
*/

public without sharing class ResultsFrameworkResponseTriggerHandler {
       
    private ResultsFrameworkResponseTriggerHandler(){
           if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){        
        if(trigger.isAfter){           
            if(trigger.isUpdate)
            {
                updateFrameworkResponse();                                            
            }
        }
    }
    
    //Set the help field in 'Framework Question Response' object to check whether the form responses is reviewed or not.
    //if reviewed then tick the check box field 'Is_Response_Reviewed__c' in 'Framewrok Question Response' object, once the 
    //'Framework Question Response' record updated then the target met fields in 'Framework Quesion' object is updated/calculated
    //from process builder.
    public void updateFrameworkResponse()
    {
        List<Results_Framework_Form_Response__c> newRes=trigger.new;
        List<Results_Framework_Form_Response__c> oldRes=trigger.old;
        
        List<Indicator_Question_Response__c> lstFQR=[SELECT id, Is_Response_Reviewed__c,Results_Framework_Response__c 
                                                  FROM Indicator_Question_Response__c WHERE Results_Framework_Response__c=:newRes[0].id];
        
        if(lstFQR.size()>0)
        {
             if(oldRes[0].Review_Status__c!=newRes[0].Review_Status__c)
            {
                List<Indicator_Question_Response__c> lstUpdatefqr=new List<Indicator_Question_Response__c>();
            
                for(Indicator_Question_Response__c fq:lstFQR)
                {
                    Indicator_Question_Response__c fqr=new Indicator_Question_Response__c(id=fq.id,Is_Response_Reviewed__c=true);
                    lstUpdatefqr.add(fqr);
                }                         
            
                if(lstUpdatefqr.size()>0)
                    update lstUpdatefqr;                                          
            }
        }
    }
        
    public static ResultsFrameworkResponseTriggerHandler getHandler(){
        if(handler == null){
            handler = new ResultsFrameworkResponseTriggerHandler();
        }
    return handler;
    }
    
    private static ResultsFrameworkResponseTriggerHandler handler;
     
}