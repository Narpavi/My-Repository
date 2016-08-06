@isTest
public class ApplicationFormAPIWebService2Test {


static testMethod void ExampleMethodTest() {

   
    
    String result = ApplicationFormAPIWebService2.exampleMethod('blah');
    System.assertEquals('it works', result);

}

static testMethod void getBlankApplicationForJobTest() {

    Job__c testJob = setupJob();

    ApplicationFormAPIWebService2.AppDetails ad = ApplicationFormAPIWebService2.getBlankApplicationForJob(testJob.id);
    
    System.assertEquals(testJob.id, ad.jobId);
    System.assertEquals(2, ad.questionList.size(), 'expecting 2 questions to be returned');
    System.assertEquals('TestQ1Text', ad.questionList[0].Question__r.Question__c, 'check of q1 text');
    System.assertEquals('TestQ2Text', ad.questionList[1].Question__r.Question__c, 'check of q2 text');
    

}

static testMethod void submitApplicationTest1() {

    Job__c testJob = setupJob();
    
    ApplicationFormAPIWebService2.AppDetails ad = ApplicationFormAPIWebService2.getBlankApplicationForJob(testJob.id);
    
    fillInApplication(ad);
    
    ApplicationFormAPIWebService2.ApplicationSubmitResponse resp = ApplicationFormAPIWebService2.submitApplication(ad);
    
    
    System.assertEquals(null, resp.debugErrorMessage, 'expecting no debug error message');
    System.assertEquals(null, resp.userErrorMessage, 'expecting no user error message');
    System.assertEquals(true, resp.success, 'expecting response to say success');


}

static testMethod void submitApplicationTest2_MandatoryMessage() {

    Job__c testJob = setupJob();
    
    ApplicationFormAPIWebService2.AppDetails ad = ApplicationFormAPIWebService2.getBlankApplicationForJob(testJob.id);
    
    fillInApplication(ad);
    // clear something that should cause a validation complaint
    ad.application.Consent_To_Information_Being_Stored__c = false;
    
    ApplicationFormAPIWebService2.ApplicationSubmitResponse resp = ApplicationFormAPIWebService2.submitApplication(ad);
    
  
    System.assertEquals(false, resp.success, 'expecting response to say NOT success');
    System.assertEquals(false, resp.userErrorMessage == null, 'expecting user error message to be filled in');
    System.assertEquals(true, resp.userErrorMessage.Contains('Please provide your consent to information being stored'), 'expecting user error message to mention what is missing'); 


}

static testMethod void submitApplicationTest3_ErrorMessage() {

    Job__c testJob = setupJob();
    
    ApplicationFormAPIWebService2.AppDetails ad = ApplicationFormAPIWebService2.getBlankApplicationForJob(testJob.id);
    
    fillInApplication(ad);
    // do something likely to cause an error
    ad.profession = 'not an id, its a string';
    
    ApplicationFormAPIWebService2.ApplicationSubmitResponse resp = ApplicationFormAPIWebService2.submitApplication(ad);
    
  
    System.assertEquals(false, resp.success, 'expecting response to say NOT success');
    System.assertEquals(false, resp.debugErrorMessage==null,'expecting debugErrorMessage to be filled in');
    System.assertEquals(true, resp.debugErrorMessage.Contains('Invalid id'), 'expecting debug error message to mention invalid id'); 
 


}


static testMethod void submitJobAlertTest1() {

    Job__c testJob = setupJob();
    
    ApplicationFormAPIWebService2.JobAlertDetails jad = new ApplicationFormAPIWebService2.JobAlertDetails();
    
    fillInJobAlert(jad);
    
    ApplicationFormAPIWebService2.JobAlertSubmitResponse resp = ApplicationFormAPIWebService2.submitJobAlert(jad);
    
    System.assertEquals(null, resp.errorMessage, 'expecting no error message');
    System.assertEquals(true, resp.success, 'expecting response to say success');


}

static testMethod void getAppFormStaticDataTest() {

    ApplicationFormAPIWebService2.AppFormStaticData statdata = ApplicationFormAPIWebService2.getAppFormStaticData();
    
    System.assertEquals(true, statdata.addressCountryOptions.size() > 10, 'expecting address country list');
    

}


static testMethod void getJobAlertStaticDataTest() {

    ApplicationFormAPIWebService2.JobAlertStaticData statdata = ApplicationFormAPIWebService2.getJobAlertStaticData();
    
    System.assertEquals(true, statdata.addressCountryOptions.size() > 10, 'expecting address country list');
    

}

private static void fillInApplication(ApplicationFormAPIWebService2.AppDetails ad)
{
    // need to create a skill for this
    Skill__c testSkill = new Skill__c(Name='TestSkill', Group__c='Test', Active__c=true);
    insert testSkill;
    
    ad.contact.FirstName = 'Timothy';
    ad.contact.LastName = 'TestPerson';
    ad.contact.MobilePhone = '123456789';
    ad.contact.npe01__HomeEmail__c = 'timothy@example.com';
    ad.confirmEmail = 'timothy@example.com';
    
    ad.contact.MailingStreet = '12 Acacia Avenue\nBriddleport';
    ad.contact.MailingCity = 'Heathumpton';
    ad.contact.MailingState = 'Briddleshire';
    ad.contact.MailingPostalCode = 'BS6 8RT';
    ad.contact.MailingCountry = 'United Kingdom';
    
    // need skill id
    ad.profession = testSkill.Id;
    
   
    // here we need to generate a Yes for each question
    ad.answerList = new List<ApplicationFormAPIWebService2.ApplicationAnswer>();
    for(Job_Question__c jq:ad.questionList)
    {
        ApplicationFormAPIWebService2.ApplicationAnswer ans = new ApplicationFormAPIWebService2.ApplicationAnswer();
        ans.questionId = jq.Id;
        ans.response = 'Yes';
        ad.answerList.add(ans);
    }
    
    
    
    ad.application.Are_you_currently_in_employment__c = 'Yes';
    ad.application.Current_Most_Recent_Job_Title__c = 'Nurse';
    ad.contact.Available_From__c = date.newInstance(2016,9,25);
    ad.application.How_Long_are_You_Available__c = '2 Years';

    ad.application.Worked_for_VSO__c = 'Never Worked for VSO';
    ad.contact.Certificate_Programme_Name__c = 'Blue Peter Badge';
    ad.contact.Certificate_Programme_Date_Obtained__c = date.newInstance(1986,4,20);
    
    // Curriculum Vitae
    Blob cvBlob = Blob.valueof('this is a text file lets pretend its a CV');
    ad.cvFileBase64 = EncodingUtil.base64Encode(cvBlob);
    ad.cvFilename = 'TimothyCV.doc';
    
    // Equal opportunities and diversity
    ad.contact.Gender__c = 'Male';
    ad.application.Current_Education_Level__c = 'Graduate';
    ad.contact.Age_Range__c = '31-40';
    ad.contact.Nationality_1__c = 'English';
    
    // Declaration
    ad.application.Declaration__c = true;
    
    // Data protection
    ad.application.Consent_To_Information_Being_Stored__c = true;
    

}

private static void fillInJobAlert(ApplicationFormAPIWebService2.JobAlertDetails jad)
{
    jad.contact = new Contact();
    jad.contact.Salutation = 'Mr.';
    jad.contact.FirstName = 'Timothy';
    jad.contact.LastName = 'TestPerson';
    jad.contact.MobilePhone = '123456789';
    jad.contact.Email = 'timothy@example.com';
    jad.confirmEmail = 'timothy@example.com';
    
    jad.contact.MailingCountry = 'United Kingdom';
    jad.contact.Consent_To_Information_Being_Stored__c = true;

    jad.savedSearch = new SavedSearch__c();
    jad.savedSearch.JobType__c = 'Employee Job; Volunteer Job';
    jad.savedSearch.SkillGroup__c = 'Doctors; Health Management; Management';
   
}


private static Job__c setupJob() {

    List<RecordType> jobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND (Developername='Approved_Volunteer_Job')];
    RecordType volApproved = jobRecordTypes[0];

    Country__c country=new Country__c(Name='TestClassCountry', Region__c='Europe', Country_People_Manager__c=userinfo.getuserId(), Country_Director__c=userinfo.getuserId());
    insert country;
    
    Question__c q1 = new Question__c(Name='TestQ1',Question__c='TestQ1Text',Correct_Answer__c='Yes', Active__c=true);
    insert q1;
    Question__c q2 = new Question__c(Name='TestQ2',Question__c='TestQ2Text',Correct_Answer__c='Yes', Active__c=true);
    insert q2;
    
    
    Job__c job = new Job__c(Hiring_Manager__c=userinfo.getuserId(),RecordTypeid=volApproved.id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name='testjob',
        Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,
        Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
    insert job;
    
    Job_Question__c jq1 = new Job_Question__c(Job__c=job.Id, Question__c=q1.Id);
    insert jq1;
    Job_Question__c jq2 = new Job_Question__c(Job__c=job.Id, Question__c=q2.Id);
    insert jq2;
    
    return job;

}

}