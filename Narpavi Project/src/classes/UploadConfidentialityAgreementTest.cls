/* * Created By: Dinesh -TPT
   * Project Name: Refactoring Phase-2,Iteration-2
   * Created Date: (04-Aug-2016)
   * Description:Test class created to test the Upload Confidentiality Agreement in Onboarding record.
*/
@IsTest
public class UploadConfidentialityAgreementTest{

   static testMethod void testSendMedicalRequestEmail()
   {       
        Id countryUser = [ SELECT Id FROM User WHERE UserRoleId != '' AND isActive=true LIMIT 1 ].Id;      
        
        Profile PGMProfile = [ SELECT id FROM Profile WHERE name = 'System Administrator' ];  
        
        User u1 = new User(alias = 'UserT',email = 'testConfAgree@vsoint.org',emailencodingkey = 'UTF-8',firstname='f1',
                          lastname = 'TestUser',languagelocalekey = 'en_US',localesidkey = 'en_US',profileid = PGMProfile.Id, 
                          timezonesidkey = 'America/Los_Angeles',username = 'testConfAgree@vsoint.org');
        insert u1;        
        
        Country__c country = new Country__c(Name = 'TestClassCountry',Region__c = 'Europe',Country_People_Manager__c = countryUser, 
                                            Country_Director__c = countryUser);        
        insert country;
                
        System.runAs(u1) {
            
            Contact con = new Contact(firstName = 'Test',lastName = 'Test',email='testConfAgree1@test.com');
            insert con;
            
            Account acc = new Account(Name = 'Test');
            insert acc;
                                           
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,People_Group_Manager__c=u1.id,People_Group_Admin__c=u1.id,
                                  Job_Reason__c='jobtest',RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,
                                  Job_Title__c='IT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                        
            Application__c appln=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id,
                                                    Submission_Date__c=system.today());
            insert appln; 
            
            List<RecordType> OfferRecordTypes=new List<RecordType>(); 
            OfferRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Offer__c' 
                              AND Developername='Employee_Offer'];    
        
            Offer__c offer= new Offer__c(Applicant__c=con.id ,Application__c=appln.id,Status__c='Sent',
                                         VSO_Offer_Contact_Person__c=u1.id,RecordTypeid=OfferRecordTypes[0].id,
                                         Payroll_Office_processing_location__c=country.id,Offer_Status__c='Verbal Offer Accepted');             
            insert offer;    
         
            Offer__c offr=new Offer__c (id=offer.id,Offer_Status__c= 'Conditional Offer Accepted');
            update offr;
            
            Map<String,Id> mapOnBoardingCheckRecdType = new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='OnBoardingCheck__c']){
                               mapOnBoardingCheckRecdType.put(rt.developername,rt.id);}
            
            OnBoardingCheck__c OnboardCheck = new OnBoardingCheck__c(RecordTypeId=mapOnBoardingCheckRecdType.get('Employee_Consultant'),
                                                                     Application__c=appln.id,Contact__c=con.id,Recruitment_Partner__c=acc.id,
                                                                     Relationship_Manager__c=u1.id);
            insert OnboardCheck;
            
            Pagereference pageRef = Page.UploadConfidentialityAgreement;
            pageRef.getParameters().put('OnboardingID', OnboardCheck.id);
            Test.setCurrentPageReference(pageRef);

            UploadConfidentialityAgreementController myPageCon = new UploadConfidentialityAgreementController();            
            myPageCon.HasAccepted=true;
            myPageCon.FormSubmit();                        

            //Resubmitting the form without accepting the agreement
            UploadConfidentialityAgreementController myPageCon1 = new UploadConfidentialityAgreementController();            
            myPageCon1.HasAccepted=false;
            myPageCon1.FormSubmit();                        
        }        
   }
}