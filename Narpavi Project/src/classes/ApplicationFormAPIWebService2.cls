global class ApplicationFormAPIWebService2 {

    webService static String exampleMethod(String something)
    {
        return 'it works';
    }
    
    
    
    webService static AppDetails getBlankApplicationForJob(String jobId)
    {
        Job_ApplicationController cont = new Job_ApplicationController(jobId);
        
        AppDetails ret = new AppDetails();
        ret.jobId = jobId;
        ret.jobTitle = cont.selectedJob.Job_Title__c;
        ret.contact = new Contact();
        ret.application = new Application__c();
        
        ret.questionList=new List<Job_Question__c>();
        // get QuestionList from Job_ApplicationController and transform 
        if (cont.QuestionList != null)
        {
            for(Job_ApplicationController.QuestionWrapper qw:cont.QuestionList){
                ret.questionList.add(qw.JobQuestion);
            }
        }
                
        return ret;
    }
    
    /*
    private static List<Job_Question__c> getQuestions(String jobId)
    {
        List<Job_Question__c> ret = new List<Job_Question__c>();
        Job__c tempJob = null;
        List<Job__c> tempList =[Select id, RecordType.DeveloperName, RecordTypeId, (Select id,Name, Job__c, Question__c,Question__r.name,Question__r.Question__c,Question__r.Correct_Answer__c,
                    Question__r.Applies_To__c,Weighting__c From Job_Questions__r where Question__r.Active__c=true),
                    Job_Title__c,name,Desk_Space_Location__c,Projected_Duration_Weeks__c,Projected_Start_Date__c ,Country__c,
                    Projected_End_Date__c,Job_Reason__c,Actual_Start_Date__c,
                    Actual_End_Date__c,Role_Overview__c,Introduction_to_VSO__c,Ideal_Applicant_Summary__c,How_To_Apply__c,
                    Advertised_Job_Start_Date__c,Advertised_Interview_Date__c,Advertise_Internally__c,Advertise_Externally__c,
                    Additional_Advert_Text__c From Job__c where Id=:jobId];
        if(tempList.size()>0){
            tempJob=tempList[0];
        }
        if(tempJob.Job_Questions__r.size()>0){
            
            for(Job_Question__c jq:tempJob.Job_Questions__r){
                ret.add(jq);
            }
        } 
        return ret;
    }
    */
    
    webService static ApplicationSubmitResponse submitApplication(AppDetails appd)
    {
        ApplicationSubmitResponse res = new ApplicationSubmitResponse();
    
    
        Job_ApplicationController cont = null;
        // wrap interactions with controller in try/catch 
        try {
            cont = new Job_ApplicationController(appd.jobId);
            cont.Applicant = appd.contact;
            cont.jobApplication = appd.application;
            cont.confirmEmail = appd.confirmEmail;
            cont.Profession = appd.profession;
    
            
            // empty collection may come via soap as null so check for null
            if (appd.answerList != null)
            {
                // match answers back to QuestionList/QuestionWrappers from controller
                for (ApplicationAnswer a: appd.answerList) {
                    Job_ApplicationController.QuestionWrapper matchWrapper = findQuestionWrapper(cont.QuestionList, a.questionId);
                    if (matchWrapper != null)
                        matchWrapper.response = a.response;
                }
                
            }   
             
            // extract the uploaded file to correct place for controller
            if (appd.cvFileBase64 != null)
            {
                Blob cvFile = EncodingUtil.base64Decode(appd.cvFileBase64);
                cont.uploadedFile = cvFile;
                cont.filesize = cvFile.size();
                cont.filename = appd.cvFilename;
            }
             
            // available from is passed in from form but available to is not
            // this can cause problems with existing records that already have from/to dates
            // hence we need to set available to to blank
            // Ian Finch 30/Jun/2016
            cont.applicant.Available_To__c = null; 
            
            PageReference dummy = cont.ApplicationSubmit();
        } catch(Exception ex)
        {
            res.success = False;
            res.statusMessage = 'Error in Application processing';
            res.debugErrorMessage = ex.getMessage() + '<br/>' + ex.getStackTraceString();
            return res;
        
        }
             
        if (cont.applicationStatus == 'Submitted')
        {
            res.success = True;
            res.statusMessage = 'Success';
            res.applicationId = cont.jobApplication.Id;
            return res;
        }
          
        // otherwise return problem
        res.success = False;
        res.statusMessage = 'Application Failed';
        String problems = '';
        if (!String.isEmpty(cont.applicationStatus))
            problems = cont.applicationStatus + '<br/>';
            
        if (!String.isEmpty(cont.errormsg))
            problems = problems + cont.errormsg;
        
        res.userErrorMessage = problems;   
         
        if (!String.isEmpty(cont.internalErrorMsg))
            res.debugErrorMessage = cont.internalErrorMsg;
         
        return res;
    }
    
    webService static JobAlertSubmitResponse submitJobAlert(JobAlertDetails jad)
    {
        JobAlertSubmitResponse res = new JobAlertSubmitResponse();
        
        JobAlertSignupController cont = null;
        try
        {
            cont = new JobAlertSignupController('False');
            cont.submitedContact = jad.contact;
            cont.savedSearch  = jad.savedSearch;
            cont.confirmEmail = jad.confirmEmail;
            
            PageReference dummy = cont.save();
        } catch(Exception ex)
        {
            res.success = False;
            res.statusMessage = 'Error in JobAlertSignupController';
            res.errorMessage = ex.getMessage() + '<br/>' + ex.getStackTraceString();
            return res;
        }
         
        if (cont.jobAlertSignupStatus == 'Submitted')
        {
            res.success = True;
            res.statusMessage = cont.jobAlertSignupStatus;
            res.savedSearchId = cont.savedSearch.Id;
            return res;
        }
          
        // otherwise return problem
        res.success = False;
        res.statusMessage = 'Submission Error';
        // nB: way controller works, this could be a user friendly validation error or
        // a salesforce error message
        res.errorMessage = cont.errormsg;
        
        
        return res;
    }
    
    webService static AppFormStaticData getAppFormStaticData()
    {
        AppFormStaticData res = new AppFormStaticData();
        res.salutationOptions = getPicklistValues('Contact','Salutation');
        res.addressCountryOptions = getPicklistValues('Contact','Country_List__c');
        res.engageWithVSOOptionsMulti = getPicklistValues('Contact','How_would_you_like_to_engage_with_VSO__c');
        res.currentNoticePeriodOptions = getPicklistValues('Contact','What_is_your_current_notice_period__c');
        res.howDidYouHearAboutUsOptions = getPicklistValues('Contact','How_Did_You_Hear_About_Us__c');
        res.howDidYouHearSocialOptions = getPicklistValues('Contact','How_did_you_hear_social__c');
        res.howDidYouHearReferralOptions = getPicklistValues('Contact','How_did_you_hear_referral__c');
        res.howDidYouHearAlumnusOptions = getPicklistValues('Contact','How_did_you_hear_Alumnus__c');
        res.languageOptions = getPicklistValues('Contact','Language_1__c');
        res.skillOptions = getSkillOptions();

        res.employmentStatusOptions = getPicklistValues('Application__c','Employment_Status__c');
        res.refereeRelationshipOptions = getPicklistValues('Application__c','Referee_1_Relationship_To_You__c');
        res.refereeApproachOptions = getPicklistValues('Application__c','Referee_1_Approach_Before_Offer__c');
        res.currentEducationLevelOptions = getPicklistValues('Contact','Current_Education_Level__c');
        res.eligibilityToWorkOptions = getPicklistValues('Application__c','Eligibility_To_Work__c');
        res.genderOptions = getPicklistValues('Contact','Gender__c');
        res.nationalityOptions = getPicklistValues('Contact','Nationality_1__c');
        res.ageRangeOptions = getPicklistValues('Contact','Age_Range__c');


        return res;
    }
    
    webService static JobAlertStaticData getJobAlertStaticData()
    {
        JobAlertStaticData res = new JobAlertStaticData();
        res.jobTypeOptions = getPicklistValues('SavedSearch__c','JobType__c');
        res.skillGroupOptions = getPicklistValues('SavedSearch__c','SkillGroup__c');
        res.addressCountryOptions = getPicklistValues('Contact','Country_List__c');
        return res;
    }
   
    
    private static Job_ApplicationController.QuestionWrapper findQuestionWrapper(List<Job_ApplicationController.QuestionWrapper> qwList, String qId)
    {
        Job_ApplicationController.QuestionWrapper ret = null;
        for (Job_ApplicationController.QuestionWrapper qw: qwList) {
            if (qw.JobQuestion.Id == qId)
            {
                ret = qw;
            }
        }
        return ret;
    }
    
    
    // based on how the Job_ApplicationController constructor does it
    private static List<SelectOptionTuple> getSkillOptions()
    {
        List<SelectOptionTuple> options = new List<SelectOptionTuple>();
        List<Skill__c> skills = [SELECT Id, Name, Group__c FROM Skill__c WHERE Active__c=true AND (NOT Group__c LIKE '%Migrated Skill%') ORDER BY Group__c, Name];
        
        // Add all Skills in system
        for (Skill__c s : skills) {
            options.add(new SelectOptionTuple(s.Id, s.Group__c + ': ' + s.Name));
        }
        return options;
    }
    
    // library fn to return picklist values as string
    // from http://salesforce.stackexchange.com/a/4993/4126
    private static List<String> getPicklistValues(String objectApi_name,String field_name){ 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApi_name);//From the Object Api name retrieving the SObject
        Sobject object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
        
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    }


    // collection of info that is needed for an Application Form submission
    global class AppDetails {

        webService String jobId; 
        webService String jobTitle;       
        webService Contact contact;
        webService Application__c application;
        webService List<Job_Question__c> questionList;
        webService List<ApplicationAnswer> answerList;
        webService String confirmEmail;
        webService String profession;
        webService String cvFileBase64;
        webService String cvContentType;
        webService String cvFilename;

    }
    
    // collection of info that is needed for a Job Alert submission
    global class JobAlertDetails {

        webService Contact contact;
        webService SavedSearch__c savedSearch;
        webService String confirmEmail;

    }
    
    
    global class ApplicationAnswer {
        webService String questionId;
        webService String response;
    }
    
    
    
    
    /*
    global class ChosenSkill {
        webService String skillId;
    }*/
    
    global class ApplicationSubmitResponse {
        webService Boolean success;
        webService String applicationId;
        webService String statusMessage;
        webService String userErrorMessage;
        webService String debugErrorMessage;
    }
    
    global class JobAlertSubmitResponse {
        webService Boolean success;
        webService String savedSearchId;
        webService String statusMessage;
        webService String errorMessage;
    }
    
    
    global class AppFormStaticData {
        webService List<String> salutationOptions;
        webService List<String> addressCountryOptions;
        webService List<String> engageWithVSOOptionsMulti;
        webService List<String> currentNoticePeriodOptions;
        webService List<String> howDidYouHearAboutUsOptions;
        webService List<String> howDidYouHearSocialOptions;
        webService List<String> howDidYouHearReferralOptions;
        webService List<String> howDidYouHearAlumnusOptions;
        webService List<String> languageOptions;
        webService List<SelectOptionTuple> skillOptions; 
        webService List<String> employmentStatusOptions;
        webService List<String> refereeRelationshipOptions;
        webService List<String> refereeApproachOptions;
        webService List<String> currentEducationLevelOptions;
        webService List<String> eligibilityToWorkOptions;
        webService List<String> genderOptions;
        webService List<String> nationalityOptions;
        webService List<String> ageRangeOptions;
        
    }
    
    global class JobAlertStaticData {
       webService List<String> jobTypeOptions;
       webService List<String> skillGroupOptions;
       webService List<String> addressCountryOptions;
    }
    
    global class SelectOptionTuple {
        webService String label;
        webService String value;
        
        public SelectOptionTuple(String pval, String plab)
        {
            label = plab;
            value = pval;
        }
    }
    
}