/* * Created By: Dinesh -TPT
   * Project Name: Refactoring Phase-2,Iteration-2
   * Created Date: (03-Aug-2016)
   * Description:Test class created to test the Upload Conditional/Unconditional Offer Letter functionality.
*/
@IsTest
public class UploadOfferLetterControllerTest{

    Static testMethod void testCondOfferLetterUpload()
    {
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
         Profile p1 = [SELECT id FROM profile where name='System Administrator'];  
         User u1 = new User(alias = 'RefDoc', email='TestOfferLetter@vsoint.org',emailencodingkey='UTF-8', 
                            lastname='TestRefDoc', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id, 
                            timezonesidkey='America/Los_Angeles', username='TestOfferLetter@vsoint.org');
        
        Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser,
                                          Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND 
                        (Developername='Consultant_Job')];

        List<RecordType> OffRecordTypes=new List<RecordType>();
        OffRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Offer__c' AND 
                        Developername IN ('Consultant_Offer','Volunteer_Offer')];
                        
        
        System.runAs(u1) 
        {
            Account acc = new Account(Name='TestAccount');
            insert acc;
            
            Contact con = new Contact(Firstname='TestFName',lastname='TestLName',email='testOffLetter@vsoint.org',Related_Employee__c=u1.id,
                                      Primary_Type__c='Applicant');
            insert con;
            
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,
                                  Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                         
            Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
            insert app;  
            
            Offer__c ConOff=new Offer__c(Applicant__c=con.id,Application__c=app.id,RecordTypeid=OffRecordTypes[0].id,
                                      VSO_Offer_Contact_Person__c=u1.id,Proposed_Start_Date__c=system.today()+10,
                                      Agreed_Work_Pattern__c='test',Fee_Payable__c=25000,Payment_Frequency__c='Weekly');
            insert ConOff;
            
            Contact con1 = new Contact(Firstname='TestFName1',lastname='TestLName1',email='testOffLetter1@vsoint.org',Related_Employee__c=u1.id,
                                      Primary_Type__c='Applicant1');
            insert con1;
            
            Job__c job1=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,
                                  Volunteer_Type__c='E-placement',Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job1;
            
            Application__c app1 = new Application__c(Applicant__c=con1.id ,Job__c=job1.id,Eligibility_To_Work__c='Yes');
            insert app1;  
            
            Offer__c ConOff1=new Offer__c(Applicant__c=con1.id,Application__c=app1.id,RecordTypeid=OffRecordTypes[1].id,
                                      VSO_Offer_Contact_Person__c=u1.id,Proposed_Start_Date__c=system.today()+10,
                                      Agreed_Work_Pattern__c='test',Fee_Payable__c=25000,Payment_Frequency__c='Weekly');
            insert ConOff1;


            
            Pagereference pageRef = Page.UploadOfferLetter;
            pageRef.getParameters().put('conditionalOfferID', ConOff.id);
            Test.setCurrentPageReference(pageRef);

            UploadOfferLetterController myPageCon = new UploadOfferLetterController();            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.HasAccepted=true;
            myPageCon.HasSigned=true;
            myPageCon.FormSubmit();                        

            UploadOfferLetterController myPageCon1 = new UploadOfferLetterController();            
            myPageCon1.uploadedFile=Blob.valueOf('Test');
            myPageCon1.filename='test';
            myPageCon1.HasAccepted=false;
            myPageCon1.filesize=5242885;
            myPageCon1.FormSubmit();   
            
            Pagereference pageRef1 = Page.UploadOfferLetter;
            pageRef1.getParameters().put('conditionalOfferID', ConOff1.id);
            Test.setCurrentPageReference(pageRef1);

            UploadOfferLetterController myPageCon2 = new UploadOfferLetterController();            
            myPageCon2.uploadedFile=Blob.valueOf('Test');
            myPageCon2.filename='test';
            myPageCon2.HasAccepted=true;            
            myPageCon2.EVolAccepted=false;    
            myPageCon2.FormSubmit();                

        }                         
    }
    
    Static testMethod void testUnCondOfferLetterUpload()
    {
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
         Profile p1 = [SELECT id FROM profile where name='System Administrator'];  
         User u1 = new User(alias = 'RefDoc', email='TestOfferLetter@vsoint.org',emailencodingkey='UTF-8', 
                            lastname='TestRefDoc', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id, 
                            timezonesidkey='America/Los_Angeles', username='TestOfferLetter@vsoint.org');
        
        Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser,
                                          Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND 
                        (Developername='Consultant_Job')];

        List<RecordType> OffRecordTypes=new List<RecordType>();
        OffRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Offer__c' AND 
                        (Developername='Consultant_Offer')];
                        
        
        System.runAs(u1) 
        {
            Account acc = new Account(Name='TestAccount');
            insert acc;
            
            Contact con = new Contact(Firstname='TestFName',lastname='TestLName',email='testOffLetter@vsoint.org',Related_Employee__c=u1.id,
                                      Primary_Type__c='Applicant');
            insert con;
            
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,
                                  Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                         
            Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
            insert app;  
            
            Offer__c ConOff=new Offer__c(Applicant__c=con.id,Application__c=app.id,RecordTypeid=OffRecordTypes[0].id,
                                      VSO_Offer_Contact_Person__c=u1.id,Proposed_Start_Date__c=system.today()+10,
                                      Agreed_Work_Pattern__c='test',Fee_Payable__c=25000,Payment_Frequency__c='Weekly');
            insert ConOff;
            
            Pagereference pageRef2 = Page.UploadOfferLetter;
            pageRef2.getParameters().put('unconditionalOfferID', ConOff.id);
            Test.setCurrentPageReference(pageRef2);
            //Submitting the form with Application having PersonalHealthInfo and the uploaded Medical Form
            UploadOfferLetterController myPageCon3 = new UploadOfferLetterController();            
            myPageCon3.uploadedFile=Blob.valueOf('Test');
            myPageCon3.filename='test';
            myPageCon3.HasAccepted=true;
            myPageCon3.HasSigned=true;
            myPageCon3.FormSubmit();            
        }                         
    }
 }