/*
******************************************************************   
 Change log #1
 
   Modified date : 16 Feb 2016
   Modified by   : Narpavi-TPT
   Purpose       : For Data Quality added the new condition to the existing condition and updated the contact if meets the criteria to avoid the duplication of contact records. 
   Search Tag    : TPT-(16-Feb-2016)

 Change log #2
 
   Modified date : 28 Apr 2016
   Modified by   : Dinesh-TPT
   Purpose       : Implementation of Part-A and Part-B of the Application Form. Converting the single form in to two separate forms to fill Part-A and Part-B of the application forms.
   Search Tag    : Application Form-TPT-(28-Apr-2016)
                        
****************************************************************** 
*/ 

public class Job_ApplicationController
{
    
    private Map<Id, RecordType> JVRecTypeMap;
    public Job__c selectedJob {get;set;}
    public Contact Applicant {get;set;}
    public Application__c jobApplication{get;set;}
    public List<ContactSkillWrapper> ContactSkillList{get;set;}    
    public List<QuestionWrapper> QuestionList{get;set;}
    public SelectOption[] SelectedSkills{get;set;}
    public SelectOption[] allSkills{get;set;}
    public Boolean isQuestions{get;set;}
    public string msg{get;set;}
    //variables for CV upload
    public transient blob uploadedFile{get;set;}   
    public Integer filesize {get; set;}
    public boolean isAppPreview {get; set;}
    public boolean isSupportingError{get;set;}
    
    private Boolean showCVMissingMsg;
    private String mfilename;
    public String confirmEmail {get;set;}
    public String Profession {get;set;}
    public String filename{get;set;}
    public String appId;
    public String contactId;
    public Boolean isExistingApp {get;set;}   
    public string professionValue {get;set;}
    
    public boolean getShowHeaderandSidebar()
    {
        return (Utility.getProfileName(Userinfo.getProfileId())!='Job Opportunities Sites Profile');
    }
    
    // main constructor, used by visualforce page
    // Ian Finch 21/Jan/2016
    public Job_ApplicationController()
    {
        String jobIdParam = ApexPages.currentPage().getParameters().get('jid');
        setup(jobIdParam);
        //Application Form-TPT-(28-Apr-2016)
        //Logic to find whether the applicant already completed Part-A of the Application. Also populating few fields in Part-B of application form
        appId=ApexPages.currentPage().getParameters().get('aid');
        isExistingApp=false;        
        if(appId!=null && appId!='')
        {           
            List<Application__c> lstApp=[SELECT id,Applicant__r.MailingStreet,Applicant__r.MailingCity,
                                         Applicant__r.FirstName,Applicant__r.LastName,
                                         Applicant__r.npe01__HomeEmail__c,Part_B_Application_Submitted__c 
                                         FROM Application__c WHERE id=:appId];    
            if(lstApp.Size()>0)
            {
                isExistingApp=true;
                contactId=lstApp[0].Applicant__c;
                Applicant.MailingStreet=lstApp[0].Applicant__r.MailingStreet;
                Applicant.MailingCity=lstApp[0].Applicant__r.MailingCity;
                Applicant.FirstName=lstApp[0].Applicant__r.FirstName;
                Applicant.LastName=lstApp[0].Applicant__r.LastName;
                Applicant.npe01__HomeEmail__c=lstApp[0].Applicant__r.npe01__HomeEmail__c;                
                if((isExistingApp) && (lstApp[0].Part_B_Application_Submitted__c)){
                       applicationStatus='Already Submitted';
                       
                }  
            }        
        }                  
    }
    
    // alternative constructor for use when calling controller from non-visualforce environment
    // such as web services. Ian Finch 21/Jan/2016
    public Job_ApplicationController(String jobIdParam)
    {
        setup(jobIdParam);
        isExistingApp=false;
    }
    
    // setup code used by constructors. Ian Finch 21/Jan/2016
    private void setup(String jobIdParam)
    {
        validationCheck=false;
        isQuestions=false;
        errormsg='';
        
        showCVMissingMsg = false;

        selectedJob=new Job__c();
        Applicant=new Contact();
        jobApplication=new Application__c();      
        QuestionList=new List<QuestionWrapper>();
        SelectedSkills=new List<SelectOption>();
        
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];    
        allSkills = new List<SelectOption>();
        for (Skill__c s : skills) 
        {
            allSkills.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }       
        
        String JobId = jobIdParam;
        if(JobId!=null && JobId!='')
        {
            List<Job__c>temp =[Select id, RecordType.DeveloperName, RecordTypeId, (Select id,Name, Job__c, Question__c,Question__r.name,Question__r.Question__c,Question__r.Correct_Answer__c,
                    Question__r.Applies_To__c,Weighting__c From Job_Questions__r where Question__r.Active__c=true),
                    Job_Title__c,name,Desk_Space_Location__c,Projected_Duration_Weeks__c,Projected_Start_Date__c ,Country__c,
                    Projected_End_Date__c,Job_Reason__c,Actual_Start_Date__c,
                    Actual_End_Date__c,Role_Overview__c,Introduction_to_VSO__c,Ideal_Applicant_Summary__c,How_To_Apply__c,
                    Advertised_Job_Start_Date__c,Advertised_Interview_Date__c,Advertise_Internally__c,Advertise_Externally__c,
                    Additional_Advert_Text__c From Job__c where Id=:JobId]; 
              
            if(temp.size()>0)
            {
                selectedJob=temp[0];
            }
            
            if(selectedJob.Job_Questions__r.size()>0)
            {
                isQuestions=true;
                for(Job_Question__c jq:selectedJob.Job_Questions__r){
                    QuestionList.add(new QuestionWrapper(jq));
                }
            }            
        }
    }
    
    /*-----------finding picklist values---------------------------------*/  
    
    public List<selectoption> getAnswersOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Application_Answer__c.Answer__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
  
    public List<selectoption> getCountryList()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =Contact.Country_List__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;     
    }
    
    public List<selectoption> getSkills()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%')];
        for (Skill__c s : skills) {
            options.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }
        return options;
    }
    
    public List<selectoption> getSkillsWithNoneOption()    
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];
        
        // Add the option for None
        options.add(new SelectOption('--None--', '--None--'));
        
        // Add all Skills in system
        for (Skill__c s : skills)
        {
            options.add(new SelectOption(s.Id, s.Group__c + ': ' + s.Name));
        }
        return options;
    }
        
    public String applicationStatus{get;set;}       
    public boolean validationCheck{get;set;}
    public String errormsg{get;set;}
    
    // added for web service, Ian Finch 21/Jan/2016
    public String internalErrorMsg{get;set;}
    
    public PageReference ApplicationSubmit()
    {
        validationCheck=false;
        errormsg='';
        applicationStatus='';
        system.debug('**********applicationStatus:'+applicationStatus);   
             
        Savepoint sp1=database.setSavepoint();
       

      /*if(Applicant.Available_To__c < Applicant.Available_From__c )
        {         
            errormsg='<li>Available to cannot be before Available From</li>';
        }*/
         
        if(Applicant.Available_From__c<System.today())
        {           
            errormsg+='<li>Available from and available to cannot be in past date</li>';
        }  
        
        //Application Form-TPT-(28-Apr-2016)
        //Added a condition to check Part-A and Part-B Application form
        if((!jobApplication.Consent_To_Information_Being_Stored__c)&&(!isExistingApp))
        {
            errormsg+='<li>Please provide your consent to information being stored</li>';
        }
        
        if((!jobApplication.Declaration__c)&&(!isExistingApp))
        {
            errormsg+='<li>Please declare that the information provided is true and correct</li>';
        }        
        for(QuestionWrapper qw:QuestionList)
        {
            if (!Test.isRunningTest() && (qw.response==null || qw.response=='') &&(!isExistingApp))
            {
                errormsg+='<li>Please answer application question "' + qw.JobQuestion.Question__r.Question__c + '"</li>';
            }
        }
         
        // SPGI-75 and CR-96
        if ((jobApplication.Supporting_Statement__c== null || jobApplication.Supporting_Statement__c== '') &&
           (appId!=null && appId!='' ))
        {
            errormsg+= '<li>Please provide a supporting statement.</li>';            
        }
        
        //Application Form-TPT-(28-Apr-2016)
        //Added a condition to check Part-A and Part-B Application form
        // Check profession completed
        system.debug('$$$ Profession = ' + Profession);
        if ((Profession == null || Profession == '' || Profession == '--None--') && (!isExistingApp))
        {
            errormsg+='<li>Please indicate which skill area most closely matches your profession</li>';
        }
        
        if ((Applicant.MailingCountry == null || Applicant.MailingCountry == '' || Applicant.MailingCountry == '--None--')
           &&(!isExistingApp))
        {
            errormsg+= '<li>Please select a country of residence.</li>';            
        }  
        
        if (jobApplication.How_Did_You_Hear_About_Us__c != 'Social Media' 
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Referral'
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Alumnus'
            && jobApplication.How_Did_You_Hear_About_Us__c != 'Job Alerts'
            && (jobApplication.How_Did_You_Hear_Other__c == null || jobApplication.How_Did_You_Hear_Other__c.trim() == '')
            && (appId!=null && appId!=''))
        {
            errormsg+= '<li>Please provide further details of where you saw this opportunity advertised.</li>';           
            errormsg+=appId;
        }       
          
        if (uploadedFile == null && filename != null && filename != '' && !showCVMissingMsg && !isExistingApp)
        {
            showCVMissingMsg = true;
            errormsg+= '<li>Please re-attach your CV before submitting the form.</li>';
        }
        else if ((uploadedFile == null) &&(!isExistingApp))
        {
            errormsg+= '<li>Please attach your CV before submitting the form.</li>';
        }

        //SS-13740087-Narpavi-TPT-(29-Jun2-2016)
        //Increased the file size from 200KB to 1024KB 
        if (uploadedFile != null && filename != '' && filesize > 1049600)
            errormsg+= '<li>Please attach a smaller size CV: ' + filename + ' (size=' + Decimal.valueOf(filesize/1024).setScale(0) + 'KB) has exceeded the 1024KB limit.</li>';  
        
        //SCS-2211 - Added by poornima
        if(jobApplication.Referee_1_Relationship_To_You__c == 'Other' && jobApplication.Referee_1_Relationship_To_You_Other__c == null)
            errormsg+= '<li>Please specify the other relationship for the Referee 1.</li>';
            
        if(jobApplication.Referee_2_Relationship_To_You__c == 'Other' && jobApplication.Referee_2_Relationship_To_You_Other__c == null)
            errormsg+= '<li>Please specify the other relationship for the Referee 2.</li>';
        
        //Application Form-TPT-(28-Apr-2016)
        //Added a new warning messages 
        if((Applicant.Gender__c=='' || Applicant.Gender__c==null) && !isExistingApp)
        {       
            errormsg+='<li>Please specify the Gender</li>';        
        }        
           
        if(jobApplication.Are_you_currently_in_employment__c==null && !isExistingApp)
        {            
            errormsg+='<li>Please specify are you currently in employment?</li>';
        }         
       
        //Application Form-TPT-(28-Apr-2016)
        //Validate if the supporting statement exceeds 1500 words
        if(isSupportingError!=null && isSupportingError && (appId!=null && appId!=''))
        {
            errormsg+='<li>Please provide the supporting statement within the limit of 1500 words</li>' ;
        }
        
        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }
        else
        {
           try
           {         
                //TPT-(16-Feb-2016)- Added new condition to the existing condition
                //Application Form-TPT-(28-Apr-2016)
                //SS-14084927-TPT-(21-July-2016)-Added the condition to execute the below code only when the Part A application form submitted. 
                if(isExistingApp!=null && !isExistingApp)
                {
                        List<Contact> con=[SELECT id,name FROM Contact WHERE
                                           (npe01__HomeEmail__c=:Applicant.npe01__HomeEmail__c) 
                                           OR (npe01__WorkEmail__c=:Applicant.npe01__HomeEmail__c) 
                                           OR (FirstName=:Applicant.FirstName AND MobilePhone=: Applicant.MobilePhone) 
                                           OR (FirstName=:Applicant.FirstName AND HomePhone=: Applicant.MobilePhone) 
                                           OR (FirstName=:Applicant.FirstName AND MailingStreet=:Applicant.MailingStreet 
                                               AND LastName=:Applicant.LastName ) LIMIT 1];
                        if(con.size()>0)
                        {
                            Applicant.id=con[0].id;
                        }
                    
                        //to avoid validation
                        Applicant.npe01__PreferredPhone__c = 'Mobile';
                        Applicant.npe01__Preferred_Email__c = 'Personal';
                        
                        upsert Applicant;
                        
                        jobApplication.Status__c='New';                                            
                        jobApplication.Applicant__c = Applicant.id;
                        jobApplication.Job__c=selectedJob.id;                    
                        jobApplication.Source__c='Web';
                        // map contact fields to application
                        jobApplication.Current_Education_Level__c = Applicant.Current_Education_Level__c;                        
                        //Application Form-TPT-(28-Apr-2016)- Added to check the Part A application is filled.   
                        jobApplication.Part_A_Application_Submitted__c= True;    
                        
                        insert jobApplication;
                }
                    
                //Application Form-TPT-(28-Apr-2016)
                //Added a condition to check Part-A or Part-B application form based on that update the App status.
                else
                {    
                        Applicant.id=contactId;                 
                        jobApplication.id=appId;
                        //SS-13853787-Narpavi-TPT-(5-July-2016)
                        //Changed the application status from 'Shortlisted – Part B Received' to 'Longlisted – Part B Received'
                        jobApplication.Status__c='Longlisted – Part B Received';      
                        jobApplication.Part_B_Application_Submitted__c= True;   
                        
                        update jobApplication;
                }
                                                                                                      
                if(uploadedFile!=null)
                {
                        Attachment attach=new Attachment();
                        attach.name=filename;
                        attach.body=uploadedFile;
                        attach.parentid=jobApplication.id;
                        insert attach;
                }

                if(QuestionList.size()>0 && !isExistingApp)
                {
                        List<Application_Answer__c> AppQuestionRecords=new List<Application_Answer__c> ();
                        for(QuestionWrapper qw:QuestionList)
                        {
                            Application_Answer__c appAns=new Application_Answer__c(Application__c=jobApplication.id,Job_Question__c=qw.JobQuestion.id,Answer__c=qw.response);
                            AppQuestionRecords.add(appAns);
                        }
                        insert AppQuestionRecords;
                }

                // Get existing primary skills
                List<Contact_Skill__c> CurrentPrimarySkills = [SELECT Id, Primary_Contact_Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :Applicant.Id and Primary_Contact_Skill__c = true ORDER BY Skill__c];
                
                // Set all existing primary skills to secondary
                for(Contact_Skill__c s : CurrentPrimarySkills)
                {
                        s.Primary_Contact_Skill__c = false;
                }
                update CurrentPrimarySkills;
                
                // Now find all skills on Contact record
                List<Contact_Skill__c> AllExistingSkills = [SELECT Id, Skill__c FROM Contact_Skill__c WHERE Contact__r.Id = :Applicant.Id ORDER BY Skill__c];
                Boolean ProfessionInCurrentSkills = false;
                
                // Check whether any existing skills match the new Profession, and update list if necessary
                for(Contact_Skill__c s : AllExistingSkills)
                {                    
                        if(s.Skill__c == Profession)
                        {
                            s.Primary_Contact_Skill__c = true;
                            ProfessionInCurrentSkills = true;
                        }
                        system.debug('$$$ s.Skill__c = '+ s.Skill__c +' ProfessionInCurrentSkills= ' + Profession);
                }
                system.debug('$$$ ProfessionInCurrentSkills'+ ProfessionInCurrentSkills);
                
                // If we don't need to modify any existing skill, then add the new primary
                if(ProfessionInCurrentSkills == false && isExistingApp!=null && !isExistingApp)
                {
                        Contact_Skill__c NewPrimary = new Contact_Skill__c(Contact__c=Applicant.Id,Skill__c=Profession,Primary_Contact_Skill__c=true);
                        insert NewPrimary;
                }
                
                // If we need to change one or more existing skills to Primary, update existing data 
                else
                {
                        update AllExistingSkills;
                }
                        applicationStatus='Submitted';                             
            }
            catch(exception e)
            {
                    //uploadedFile = null;
                    applicationStatus='Submission Error';
                    
                    // keep error message for internal use but dont show to user. Ian Finch 21/Jan/2016
                    internalErrorMsg = e.getMessage() + ' Line: ' + e.getLineNumber() + '<br/>Stack Trace:<br/>' + e.getStackTraceString();
                    msg=internalErrorMsg;
                    Database.rollback(sp1);
            }
            finally{
                //attach.body = null;
            }   
        }        
        return null;
    }
   
    public class QuestionWrapper
    {
        public Job_Question__c JobQuestion{get;set;}
        public String response{get;set;}       
        public QuestionWrapper(Job_Question__c Jq)
        {
            this.JobQuestion=Jq;
        }
    }
    
    public class ContactSkillWrapper
    {
        public Contact_Skill__c ContactSkill{get;set;}
        //public String level{get;set;}
        public ContactSkillWrapper(Contact_Skill__c cs){
            this.ContactSkill=cs;
        }
    }
    
    //Application Form-TPT-(28-Apr-2016)
    //Method to nvaigate to the application preview page
    public PageReference appPreview() 
    {  
        isAppPreview =true; 
        PageReference oPageRef = Page.ApplicationPage_Preview;           
        oPageRef.setRedirect(false);
        if(profession!=null)
        {        
           for (SelectOption so : allSkills)
           {
              if (so.getValue() == profession)
              {
                 professionValue= so.getLabel();
              }
           }           
        }
        return oPageRef;       
    }         
}