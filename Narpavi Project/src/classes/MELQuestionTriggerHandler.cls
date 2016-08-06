/* * Created By: Dinesh -TPT
   * Project Name: M&E Implementation
   * Created Date: (4-Mar-2016)
*/

public without sharing class MELQuestionTriggerHandler{

    private MELQuestionTriggerHandler(){        
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
     public void execute(){             
        if(trigger.isAfter){
            if(trigger.isInsert){
                this.checkRelatedQCount();                              
            }
            if(trigger.isDelete){                              
                this.unCheckRelatedQCount();                               
            }
        }
    }
    
    //Method to check atleast one related question is linked with 'MEL Question' or not.
    //If atleast one record exist then set the help field to be ticked
    public void checkRelatedQCount()
    {
        List<MEL_Question__c> scope= Trigger.new;
        List<MEL_Question__c> lstToUpdate=new List<MEL_Question__c>();
        
        for(MEL_Question__c rq:scope)
        {
            if((rq.Help_Type__c=='Related_Question')&&(rq.Composite_Relationship__c=='Sum / Contributing Amount')
               &&(rq.Composite_Indicator_Question__r.Help_Atleast_One_Related_Question_Sum__c==false))
            {   
                MEL_Question__c mq=new MEL_Question__c(id=rq.Composite_Indicator_Question__c,Help_Atleast_One_Related_Question_Sum__c=true);
                lstToUpdate.add(mq);
            }  
            if((rq.Help_Type__c=='Related_Question')&&(rq.Composite_Relationship__c=='Percentage Base')
               &&(rq.Composite_Indicator_Question__r.Help_Atleast_One_Related_Question_Percen__c==false))
            {   
                MEL_Question__c mq1=new MEL_Question__c(id=rq.Composite_Indicator_Question__c,Help_Atleast_One_Related_Question_Percen__c=true);
                lstToUpdate.add(mq1);
            }        
        }  
        if(lstToUpdate.size()>0){
            update lstToUpdate;
        }  
    }
    
     //Method to check atleast one related question is linked with 'MEL Question' or not
     //If atleast one record does not exist then set the help field to be unticked
    public void unCheckRelatedQCount()
    {
        List<MEL_Question__c> scope= Trigger.old;
        List<MEL_Question__c> lstToUpdate=new List<MEL_Question__c>();
         
        for(MEL_Question__c rq:scope)
        {
            if((rq.Help_Type__c=='Related_Question')&&(rq.Composite_Relationship__c=='Sum / Contributing Amount'))
            {
                List<MEL_Question__c> mqList=[SELECT id,Help_Type__c,Composite_Indicator_Question__c FROM MEL_Question__c 
                                              WHERE Composite_Indicator_Question__c=:rq.Composite_Indicator_Question__c 
                                              AND Composite_Relationship__c='Sum / Contributing Amount'];
                if(mqList.Size()==0)
                {
                   MEL_Question__c mq=new MEL_Question__c(id=rq.Composite_Indicator_Question__c,Help_Atleast_One_Related_Question_Sum__c=false,Active__c=false);
                   lstToUpdate.add(mq);
                }
            } 
            if((rq.Help_Type__c=='Related_Question')&&(rq.Composite_Relationship__c=='Percentage Base'))
            {
                List<MEL_Question__c> mqList=[SELECT id,Help_Type__c,Composite_Indicator_Question__c FROM MEL_Question__c 
                                              WHERE Composite_Indicator_Question__c=:rq.Composite_Indicator_Question__c 
                                              AND Composite_Relationship__c='Percentage Base'];
                if(mqList.Size()==0)
                {
                   MEL_Question__c mq=new MEL_Question__c(id=rq.Composite_Indicator_Question__c,Help_Atleast_One_Related_Question_Percen__c=false,Active__c=false);
                   lstToUpdate.add(mq);
                }
            }        
        }    
        if(lstToUpdate.size()>0){
            update lstToUpdate;
        }
    }
    

    public static MELQuestionTriggerHandler getHandler(){
        if(handler == null){
            handler = new MELQuestionTriggerHandler();
        }
    return handler;
    }
    
    private static MELQuestionTriggerHandler handler;


}