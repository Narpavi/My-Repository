/* * Created By: Dinesh and Poornima -TPT
   * Project Name: M&E Implementation
   * Created Date: (24-Dec-2015)
   * Description:
        1. Generates the 'Results Framework Form' from the custom objects.
        2. Stores the 'Results Framework Form' responses to the custom objects on submission (both insert & update operations).
*/

public class ResultFrameworkController{

    public String navigator            {get; set;}
    public Integer allQuestionsSize    {get; set;}
    public String  qQuestion           {get; set;}
    public Boolean qRequired           {get; set;}
    public String  qChoices            {get; set;}
    public string PFName               {get; set;}
    public string pfID                 {get; set;}
    public string partner              {get; set;}    
    public string volunteerName        {get; set;} 
    public string reportingPeriod      {get; set;}
    public List<questionWrapper> allQuestions  {get; set;}
    public List<selectOption> partnerOptions   {get; set;}
    public List<selectOption> teamMembers      {get; set;}
    public List<selectOption> reportingOptions {get; set;}
    public string renderedPick                 {get; set;}
    public string error                        {get; set;}
    
        
    List<Indicator_Question_Response__c> insertResponseList {get; set;}
    List<Indicator_Question_Response__c> updateResponseList {get; set;}
    
    public Date startDate;         
    public Date endDate;
    public string partnerValue;
    public List<Results_Framework_Partner__c> lstPartner {get; set;}    
    public List<String> strList                          {get; set;}
    public List<Results_Framework__c> lstRF              {get; set;}
    public String questionsJSON                          {get; set;}
    public String responseJSON                           {get ;set;}
    public Integer version                               {get; set;}
    public boolean isSubmitted                           {get; set;}
    public String countryInfo                            {get; set;}
    public String projectInfo                            {get; set;}
    public String frequencyInfo                          {get; set;}
     
     public ResultFrameworkController()
    {
        init();       
        string pid;
        pid=ApexPages.currentPage().getParameters().get('pfID');
        isSubmitted=false;
          
        lstRF=   [SELECT id,Country__r.Name,Reporting_Frequency__c,Results_Framework_Start_Date__c,
                 No_of_Months__c,Version__c,VSO_Project__r.Name FROM Results_Framework__c WHERE id=:pid];
        lstPartner=   [SELECT id,Partner__r.id, Partner__r.Name FROM Results_Framework_Partner__c 
                                                          WHERE Results_Framework__c=:pid];
                 
        partnerOptions=getPartnersWithOptions(pid,lstPartner);
        teamMembers =getTeamMembers(pid,lstRF,lstPartner);
        reportingOptions=getReportingOptions(lstRF);
        version=Integer.valueof(lstRF[0].Version__c);        
        countryInfo=lstRF[0].Country__r.Name;
        projectInfo =lstRF[0].VSO_Project__r.Name;
        frequencyInfo=lstRF[0].Reporting_Frequency__c;
        
        insertResponseList = new List<Indicator_Question_Response__c >();
        updateResponseList = new List<Indicator_Question_Response__c >();       
    }

    public void init()
    {
        allQuestionsSize=setupQuestionList(); 
    }       
        
    public Integer setupQuestionList()
    {
        questionsJSON = getAQuestion();
        return allQuestions.size();
    }
    
    public Date setDate()
    {
        
        return null;
    }
    
    //Method to populate the Reporting Period values in the picklist
    public List<selectoption> getReportingOptions(List<Results_Framework__c> lstRF)
    {       
        List<SelectOption> options = new List<SelectOption>();  
        Map<string,string> optionsMap=new Map<string,string>();  
                   
        if(lstRF.size()>0)
        {  
            options.add(new SelectOption('', '')); 
            DateTime startDate=lstRF[0].Results_Framework_Start_Date__c;   
            string monthName;
            
            //Reporting Period - Monthly calculation
            if(lstRF[0].Reporting_Frequency__c=='Monthly')
            {
                string beginMonthName=startDate.format('MMM')+' '+startDate.format('YYYY');
                options.add(new SelectOption(beginMonthName,beginMonthName));  
                
                for(integer i=1;i<lstRF[0].No_of_Months__c;i++)
                {
                    startDate=startDate.addMonths(1);
                    monthName= startDate.format('MMM')+' '+startDate.format('YYYY');
                    options.add(new SelectOption(monthName,monthName));
                }                
            }
            
            //Reporting Period - Quarterly calculation
            else if(lstRF[0].Reporting_Frequency__c=='Quarterly')
            {            
                for(integer i=1;i<lstRF[0].No_of_Months__c;i++)
                {
                    startDate=startDate.addMonths(1);                
                    integer monthNo=startDate.Month();
                    
                    if((monthNo>=1)&&(monthNo<=3)){
                        monthName='Jan - Mar'+' '+startDate.format('YYYY');
                    }
                    else if((monthNo>=4)&&(monthNo<=6)){
                        monthName='Apr - Jun'+' '+startDate.format('YYYY');
                    }
                    else if((monthNo>=7)&&(monthNo<=9)){
                        monthName='Jul - Sep'+' '+startDate.format('YYYY');
                    }
                    else if((monthNo>=10)&&(monthNo<=12)){
                        monthName='Oct - Dec'+' '+startDate.format('YYYY');
                    }
                    if(monthName!=''){
                        optionsMap.put(monthName,monthName);
                    }
                }
                //Add the values from Map to the Options list        
                for (string id : optionsMap.keySet()){        
                        options.add(new SelectOption(id,optionsMap.get(id)));
                }
            }
        }
        return options;
    }
    
   
     //Method to set the partner names to the 'Partner' picklist
    public List<selectoption> getPartnersWithOptions(string pid,List<Results_Framework_Partner__c> lstPartner)
    {    
        List<SelectOption> options = new List<SelectOption>();
    
        options.add(new SelectOption('', ''));         
        if(lstPartner.Size()>0)
        {                 
             for(Results_Framework_Partner__c r:lstPartner)
             {
                 options.add(new SelectOption(r.Partner__c, r.Partner__r.Name));                
             }
        }
        options.sort();
        options.add(new SelectOption('Not related to a specific partner', 'Not related to a specific partner'));              
        return options;
    }
    
     //Method to populate the Team members names in the picklist
    public List<selectoption> getTeamMembers(string pid,List<Results_Framework__c> lstRF,List<Results_Framework_Partner__c> lstPartner)
    {
        List<SelectOption> options = new List<SelectOption>();        
        if(lstRF.size()>0)
        {    
            options.add(new SelectOption('', ''));
            //Load the team members for 'Various Countries'  
            if(lstRF[0].Country__r.Name=='Various Countries')
            {
                List<fHCM2__Team_Member__c> lstTM1=[SELECT id,name,fHCM2__Job_Title__c,Country__c FROM fHCM2__Team_Member__c 
                                                    WHERE fHCM2__Job_Title__c LIKE '%Country Director%' 
                                                    OR fHCM2__Job_Title__c LIKE '%Executive Director%'];     
                if(lstTM1.Size()>0)
                {       
                    for(fHCM2__Team_Member__c t:lstTM1){
                        options.add(new SelectOption(t.Name, t.Name));
                   }             
                }                                          
            }
            //Load the team members for other Countries             
            else
            {            
                   List<fHCM2__Team_Member__c> lstTM2=[SELECT id,name,Country__c FROM fHCM2__Team_Member__c 
                                                       WHERE Country__c=:lstRF[0].Country__r.Name];
                   if(lstTM2.Size()>0)
                   {       
                         for(fHCM2__Team_Member__c t:lstTM2)
                         {
                             options.add(new SelectOption(t.Name, t.Name));
                         }             
                   }                 
            }
            //Load the partner values
            if(lstPartner.Size()>0)
            {                 
                 for(Results_Framework_Partner__c r:lstPartner)
                 {
                     options.add(new SelectOption(r.Partner__r.Name, r.Partner__r.Name));                
                 }
            }        
        }        
        options.sort();
        return options;
    }
    
    public String  getAQuestion() 
    {
        qQuestion = '';
 
        //Get the record id from the query string
        pfID=ApexPages.currentPage().getParameters().get('pfID');
        Map<Id,List<MEL_Question__c>> melRQRecords=buildRelatedQuestions();
                                                        
        List<Framework_Question__c> allQuestionsObject=[SELECT id,Name,
        Help_Type__c,MELQuestion_Text_on_Form__c,Results_Framework__r.Name,        
        Indicator_Question__r.Indicator_Level__c,Indicator_Question__r.Question_Text_on_Form__c,        
        Indicator_Question__c,Indicator_Question__r.Core_Programme__c,
        Indicator_Question__r.help_type__c,Indicator_Question__r.Indicator_Question_Type__c,
        Indicator_Question__r.Indicator_Question_Picklist_Options__c,       
        Indicator_Question__r.Active__c,
        Question_No_Order__c,Guidance_Notes_on_Form__c
        
        FROM Framework_Question__c WHERE Results_Framework__c=:pfID AND Active__c=true AND Include_on_Form__c=true 
        ORDER BY Question_No_Order__c NULLS LAST ];
        
        allQuestions = new List<questionWrapper>();            
        
        for(Framework_Question__c q:allQuestionsObject)
        {            
            if((PFName=='')||(PFName==null))
            {
                PFName=q.Results_Framework__r.Name;   
            }
            //Get the 'MEL Related Question' records linked to the 'MEL Question' records
            List<MEL_Question__c> melRQRecordsList=melRQRecords.get(q.Indicator_Question__c);            
            questionWrapper theQ = new questionWrapper(q,melRQRecordsList); 
            if(theQ.id!=null) 
            {       
                allQuestions.add(theQ);               
            }
        }
        String qJSON = JSON.serializePretty(allQuestions);

        return qJSON;  
    } 
    
    
    //Wrapper class to build the related questions
    public class relatedQuestionWrapper
    {
        public String id               {get; set;}
        public String relQuestionName  {get; set;}
        public String relatedResponse  {get; set;}
        public String relOptions       {get; set;}      
        public String rType            {get; set;}
        public List<String> strList    {get; set;}
        public String relatedQuestion  {get; set;}  
        public string relatedHelpTxt   {get; set;}
        
        public relatedQuestionWrapper(MEL_Question__c rq)
        {
            id=rq.id;
            relQuestionName=rq.Name;            
            rType=rq.Composite_Indicator_Question__r.Indicator_Question_Type__c;                        
            relatedQuestion=rq.Question_Text_on_Form__c;            
              
            if(rq.Indicator_Question_Type__c=='Picklist')
            {
                relOptions=rq.Indicator_Question_Picklist_Options__c;
            }
        }
    }
    
    public class questionResponses
    {
         public List<questionWrapper> questionResp;
    }
   
    //Wrapper class to build the questions
    public class questionWrapper
    {
        public String id                 {get; set;}
        public String question           {get; set;}        
        public string renderRQ1FreeText  {get; set;}        
        public string renderRQ1Picklist  {get; set;}
        public string questionRecordType {get; set;}        
        public string qType              {get; set;}
        public string qid                {get; set;}
        public string fqType             {get; set;}
        public string fqInfoType         {get; set;}
        public string relatedQuestion    {get; set;} 
        public string response           {get; set;}
                
        public string indicatorLevel   {get; set;}
        public string corePgmArea      {get; set;}
        public string Name             {get; set;}       
        
        public String multiOptions     {get; set;}
        public List<String> strList              {get; set;} 
        public Integer relatedQuestionSize       {get; set;}           
        public List<relatedQuestionWrapper> allRelatedQuestions {get; set;}
        public string helpTxt {get;set;}
        
        
        public questionWrapper(Framework_Question__c iq,List<MEL_Question__c> melRQRecordsList) 
         {     
                 renderRQ1FreeText='false';              
                 renderRQ1Picklist='false'; 
                 
                 id=iq.id;
                 Name=iq.Name;
                 fqType=iq.help_type__c;    
                 
                 try
                 {
                     //'Framework Question' object 'Indicator/Question' record type
                     if(iq.help_type__c=='Indicator_Question')
                     {
                         
                         questionRecordType=iq.Indicator_Question__r.help_type__c;                     
                     
                         //'MEL Question' object 'Composite Indicator' record type   
                         if((questionRecordType=='Composite_Indicator')&&(iq.Indicator_Question__r.Active__c))
                         { 
                             qid=iq.Indicator_Question__r.Id;
                             qType=iq.Indicator_Question__r.Indicator_Question_Type__c;
                             corePgmArea=iq.Indicator_Question__r.Core_Programme__c;
                             indicatorLevel=iq.Indicator_Question__r.Indicator_Level__c; 
                             helpTxt=iq.Guidance_Notes_on_Form__c;
                     
                             if(melRQRecordsList!=null)
                             {                                  
                                  allRelatedQuestions= new List<relatedQuestionWrapper>();                                                        
                                  for(MEL_Question__c rq:melRQRecordsList)
                                  {                     
                                      relatedQuestionWrapper rqw=new relatedQuestionWrapper(rq);
                                      if(rqw.id!=null) 
                                      {       
                                          allRelatedQuestions.add(rqw);                                          
                                      }                            
                                  } 
                                  relatedQuestionSize=allRelatedQuestions.size();
                              }                          
                          }                        

                         //'MEL Question' object 'Indicator' and 'Question' record type
                        else if(((questionRecordType=='Indicator')||(questionRecordType=='Question'))&&(iq.Indicator_Question__r.Active__c))
                         {  
                             qid=iq.Indicator_Question__r.Id;
                             qType=iq.Indicator_Question__r.Indicator_Question_Type__c;
                             corePgmArea=iq.Indicator_Question__r.Core_Programme__c;
                             indicatorLevel=iq.Indicator_Question__r.Indicator_Level__c; 
                             helpTxt=iq.Guidance_Notes_on_Form__c;
                         
                             if(qType!='Picklist')
                             {   
                                 renderRQ1FreeText ='true';
                                 relatedQuestion=iq.Indicator_Question__r.Question_Text_on_Form__c;                             
                             }                 
                             else if(qType=='Picklist')
                             {
                                  renderRQ1Picklist='true';                     
                                  relatedQuestion=iq.Indicator_Question__r.Question_Text_on_Form__c;
                                  multiOptions = iq.Indicator_Question__r.Indicator_Question_Picklist_Options__c;      
                             } 
                         }
                     }
                 }
                 catch(Exception ex)
                 {
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Problem in Form Generation'+ex));
                       system.debug('Form Generation Exception '+ex);
                
                       string errorMsg='Problem in Results Framework Form Generation \n'+Ex.getmessage();
                       string errorClass='ResultFrameworkController';
                       string errorStack=Ex.getStackTraceString();
                       string errorType=Ex.getTypeName();
                       //log the exception
                       ApplicationErrorLogController obj=new ApplicationErrorLogController();
                       obj.logError(errorClass,errorMsg,errorStack,errorType);    
                 }   
        }
    }
    
    //Method to save the submitted data to salesforce objects
    public pageReference submitResults()
    {
       
        try
        {
            String response;            
            String newFormResponse='';
            String existingFormResponse='';
            List<SelectOption> mOptions;
            //deserialize JSON Response
            String responseJSON = ApexPages.currentPage().getParameters().get('myParam');                 
            questionResponses Responses=new questionResponses();
            if(responseJSON!=null)     
            {          
                Responses = (questionResponses)JSON.deserialize('{ \"questionResp\" : ' + responseJSON + '}', ResultFrameworkController.questionResponses.class);                                                    
            }
        
            if(partner==null || partner=='Not related to a specific partner')
                partnerValue=null;
            else
                partnerValue=partner;
        
            Map<String,Integer> monthNumeric = new Map<String,Integer> {'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12};
       
            //Set reporting start date and end date from reporting frequency
            if(lstRF[0].Reporting_Frequency__c=='Monthly')
            {
                Integer month= monthNumeric.get(reportingPeriod.substring(0,3));
                Integer year=Integer.valueOf(reportingPeriod.substring(4,8));
                Integer noOfDays=Date.daysInMonth(year, month);
                startDate=Date.newInstance(year, month, 1);
                endDate=Date.newInstance(year, month, noOfDays);
            }
            else if(lstRF[0].Reporting_Frequency__c=='Quarterly')
            {
                Integer startMonth= monthNumeric.get(reportingPeriod.substring(0,3));
                Integer endMonth= monthNumeric.get(reportingPeriod.substring(6,9));
                Integer year=Integer.valueOf(reportingPeriod.substring(10,14));
                Integer noOfDays=Date.daysInMonth(year, endMonth);
                startDate=Date.newInstance(year, startMonth, 1);
                endDate=Date.newInstance(year, endMonth, noOfDays);
            }
           
            Map<Id,List<Results_Framework_Form_Response__c>> formResponses = buildFormResponses();   
            List<Results_Framework_Form_Response__c> existingFormResponses = formResponses.get(pfID);
            if(existingFormResponses!=null && existingFormResponses.size()>0)
            { 
                existingFormResponse=existingFormResponses[0].id;
                Results_Framework_Form_Response__c res=new Results_Framework_Form_Response__c();
                res.id=existingFormResponses[0].id;
                res.Review_Status__c='To be Reviewed';
                update res;
            }
            else
            {                 
                Results_Framework_Form_Response__c partnerDetail=new Results_Framework_Form_Response__c();
                partnerDetail.Results_Framework__c=pfID;               
                partnerDetail.Partner_Organisation__c=partnerValue;
                partnerDetail.Reporting_Period_End_Date__c=endDate;
                partnerDetail.Reporting_Period_Start_Date__c=startDate;
                partnerDetail.Respondent_Name_text__c=volunteerName;  
                partnerDetail.Reporting_Period__c= reportingPeriod; 
                insert partnerDetail;
                newFormResponse = partnerDetail.id;                                    
            }
           
            Map<Id,List<Indicator_Question_Response__c>> indicatorQuestionResponses = buildQuestionResponses(existingFormResponse);
            if(Responses.questionResp.size()>0)
            {
                for(questionWrapper q:Responses.questionResp)                
                {                    
                    if(q.fqType=='Indicator_Question')
                    { 
                        //Update responses when the form is re-submitted
                        List<Indicator_Question_Response__c> updateIndicatorResponse=indicatorQuestionResponses.get(q.id);
                        if(updateIndicatorResponse!=null)
                        {                       
                            //update questions of type 'composite indicator'
                            if(q.questionRecordType=='Composite_Indicator')
                            {                              
                                for(relatedQuestionWrapper rq:q.allRelatedQuestions)
                                {                                      
                                     if(rq.relatedResponse!=null && rq.relatedResponse!='')
                                     {                                                
                                         for(Indicator_Question_Response__c res:updateIndicatorResponse)
                                         { 
                                            //check if the response for related question is already submitted and update                                                                                   
                                            if(res.Related_Question__c!=null && res.Related_Question__c == rq.id)
                                            {                                              
                                                response=rq.relatedResponse;                                                                                                           
                                                updatesResponses(res.id,response,rq.rType);                                                                                                                                      
                                            }
                                         }                                     
                                     }                                       
                                }
                            }
                            //update questions of type 'Question' & 'Indicator'
                            else
                            {
                                for(Indicator_Question_Response__c res:updateIndicatorResponse)
                                {
                                    if(res.Indicator_Question__c == q.qid && q.response!=null && q.response!='')
                                    {                                      
                                        response=q.response;                                                                                                                                              
                                        updatesResponses(res.id,response,q.qType);                                                                                     
                                    }                                  
                                }
                            }
                        }
                        //Insert new responses when form responses are submitted for first time                            
                        else
                        {                               
                            if(q.questionRecordType=='Composite_Indicator')
                            {                               
                                for(relatedQuestionWrapper rq:q.allRelatedQuestions)
                                {
                                    if(rq.relatedResponse!=null && rq.relatedResponse!='')
                                    {                         
                                        response=rq.relatedResponse;                                                
                                        insertResponses(q.qid,q.id,newFormResponse,rq.id,response,rq.rType);
                                    }
                                } 
                            }                     
                            else
                            {
                                if(q.response!=null && q.response!='')
                                {
                                    if(q.qType == 'Picklist'){                                             
                                             response=q.response;}
                                        else{
                                            response=q.response;}
                                    insertResponses(q.qid,q.id,newFormResponse,null,response,q.qType);  
                                }
                            }                        
                        }
                    }  
               }
                if(updateResponseList.size()>0){
                     update updateResponseList;
                    
                    }
                if(insertResponseList.size()>0){           
                    insert insertResponseList;
                   
                   }              
                isSubmitted=True;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The form has been submitted. Thank you for your feedback.'));                
                updateResponseList.clear();
                insertResponseList.clear();
                if(isSubmitted)
                {
                    VSO_Settings__c setting=VSO_Settings__c.getOrgDefaults();
                    string redirectURL=setting.Site_URL__c+'/ResultFrameworkThankYouPage?pfID='+pfID;
                    PageReference pageref=new PageReference(redirectURL); 
                    pageref.setRedirect(True);
                    return pageref;
                }               
            }
         }
         
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception'+ex));
            isSubmitted=false;
            
            string errorMsg='Problem in Results Framework Form Storage Online \n'+Ex.getmessage();
            string errorClass='ResultFrameworkController';
            string errorStack=Ex.getStackTraceString();
            string errorType=Ex.getTypeName();
            //log the exception
            ApplicationErrorLogController obj=new ApplicationErrorLogController();
            obj.logError(errorClass,errorMsg,errorStack,errorType); 
        }      
      return null;
    }
       
    //Method to Updated the existing form responses
    private void updatesResponses(String responseID,String response,String responsetype)
    {
       if(response!=null && response!='')
       {
          Indicator_Question_Response__c updateRes=new Indicator_Question_Response__c(); 
          updateRes.Id=responseID;
          if((responseType!='Number')&&(responseType!='Percentage'))
                updateRes.Response__c=response;
            else
                updateRes.Response_Numeric__c= Decimal.valueOf(response);
          
          updateResponseList.add(updateRes);
       } 
    }
    
    //Method to Insert a new form responses
    private void insertResponses(String indicatorQuestionID,String frameworkID,String partnerResponseID,String relatedQuestionID,String response,String responseType)
    {                                                 
        if(response!=null && response!='')
        {
            Indicator_Question_Response__c Iqr=new Indicator_Question_Response__c();
            Iqr.Indicator_Question__c=indicatorQuestionID;
            Iqr.Framework_Question__c=frameworkID;
            Iqr.Results_Framework_Response__c=partnerResponseID;
            Iqr.Related_Question__c=relatedQuestionID;           
            if((responseType!='Number')&&(responseType!='Percentage'))
                Iqr.Response__c=response;
            else
                Iqr.Response_Numeric__c= Decimal.valueOf(response);
            insertResponseList.add(Iqr);
        }            
    } 
    
    //Method to build the submitted form responses
    private Map<Id,List<Results_Framework_Form_Response__c>> buildFormResponses()
    {
        Map<Id,List<Results_Framework_Form_Response__c>> formResponseList = new Map<Id,List<Results_Framework_Form_Response__c>>();
        
        List<Results_Framework_Form_Response__c> responses=[SELECT id,Partner_Organisation__c,Results_Framework__c,Reporting_Period_End_Date__c,
                                                            Reporting_Period_Start_Date__c,Respondent_Name_text__c from Results_Framework_Form_Response__c
                                                            WHERE Respondent_Name_text__c=:volunteerName AND Reporting_Period_Start_Date__c=:startDate AND 
                                                            Reporting_Period_End_Date__c=:endDate AND Partner_Organisation__c=:partnerValue];
        if(responses.size()>0){
        for (Results_Framework_Form_Response__c res:responses) 
        {   
            List<Results_Framework_Form_Response__c> fList=formResponseList.get(res.Results_Framework__c);
            if(fList==null)
            {
                fList=new List<Results_Framework_Form_Response__c>();
                formResponseList.put(res.Results_Framework__c, fList);
            }
           fList.add(res);
        } 
        }          
        return formResponseList ;  
    }
    
    private Map<Id,List<Indicator_Question_Response__c>> buildQuestionResponses(String partnerOrg)
    {
        Map<Id,List<Indicator_Question_Response__c>> questionResponse = new Map<Id,List<Indicator_Question_Response__c>>();
        
        List<Indicator_Question_Response__c> responses=[SELECT id,Response__c,Response_Numeric__c,Indicator_Question__c,
                                                        Framework_Question__c,Results_Framework_Response__c,Related_Question__c,
                                                        Framework_Question__r.Results_Framework__c FROM Indicator_Question_Response__c
                                                        WHERE Framework_Question__r.Results_Framework__c=:pfID AND 
                                                        Results_Framework_Response__c =:partnerOrg];
        
        for (Indicator_Question_Response__c res:responses) 
        {
            List<Indicator_Question_Response__c> resList = questionResponse.get(res.Framework_Question__c);
            if(resList == null)
            {
                resList= new List<Indicator_Question_Response__c>();
                questionResponse.put(res.Framework_Question__c, resList);
            }
            resList.add(res);           
        }     
        return questionResponse ;  
    } 
    
    //Method to fetch the 'MEL Related question' records linked with the 'MEL Question'
    private Map<Id,List<MEL_Question__c>> buildRelatedQuestions()
    {
        Map<Id,List<MEL_Question__c>> relatedQuestions=new Map<Id,List<MEL_Question__c>>();
        
        List<MEL_Question__c> rqList=[SELECT id,Name,Active__c,Composite_Indicator_Question__c,Help_Type__c,
                                      Question_Text_on_Form__c,Indicator_Question_Type__c,
                                      Composite_Indicator_Question__r.Indicator_Question_Type__c FROM MEL_Question__c 
                                      WHERE Help_Type__c='Related_Question' AND Active__c=true];
        if(rqList!=null)
        {
            for(MEL_Question__c rq:rqList)
            {
                List<MEL_Question__c> rlst= relatedQuestions.get(rq.Composite_Indicator_Question__c);
                if(rlst==null)
                {
                    rlst=new List<MEL_Question__c>();
                    relatedQuestions.put(rq.Composite_Indicator_Question__c,rlst);
                }
                rlst.add(rq);
            }            
        }
        return relatedQuestions;
    }
   
}