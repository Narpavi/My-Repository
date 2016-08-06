/* * Created By: Dinesh -TPT
   * Project Name: Refactoring Phase-2,Iteration-2
   * Created Date: (03-Aug-2016)
   * Description:Test class created to test the Upload Medical Form functionality.
*/
@IsTest
public class UploadMedicalFormControllerTest{

    Static testMethod void testMedicalFormUpload()
    {
         Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id;      
         Profile p1 = [SELECT id FROM profile where name='System Administrator'];  
         User u1 = new User(alias = 'RefDoc', email='TestMedicalForm@vsoint.org',emailencodingkey='UTF-8', 
                            lastname='TestRefDoc', languagelocalekey='en_US',localesidkey='en_US', profileid = p1.Id, 
                            timezonesidkey='America/Los_Angeles', username='TestMedicalForm@vsoint.org');
        
        Country__c country=new Country__c(Name='TestCountry', Region__c='Europe', Country_People_Manager__c=countryUser,
                                          Country_Director__c=countryUser);
        insert country;
        
        List<RecordType> JobRecordTypes=new List<RecordType>();
        JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND 
                        (Developername='Employee_Job')];
        
        System.runAs(u1) 
        {
            Account acc = new Account(Name='TestAccount');
            insert acc;
            
            Contact con = new Contact(Firstname='TestFName',lastname='TestLName',email='testMedForm@vsoint.org',Related_Employee__c=u1.id,
                                      Primary_Type__c='Applicant');
            insert con;
            
            Contact con1 = new Contact(Firstname='TestFName1',lastname='TestLName1',email='testMedForm1@vsoint.org',Related_Employee__c=u1.id,
                                      Primary_Type__c='Applicant');
            insert con1;

          
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,RecordTypeid=JobRecordTypes[0].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,
                                  Demand_Sign_Off_Date__c=null,Job_Title__c='JT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                         
            Application__c app = new Application__c(Applicant__c=con.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
            insert app; 
            
            Application__c app1 = new Application__c(Applicant__c=con1.id ,Job__c=job.id,Eligibility_To_Work__c='Yes');
            insert app1; 
            
            Personal_Health_Information__c phi= new Personal_Health_Information__c(ApplicationID__c=app.id);
            insert phi;
            
            Pagereference pageRef = Page.UploadMedicalForm;
            pageRef.getParameters().put('appid', app.id);
            Test.setCurrentPageReference(pageRef);
            //Submitting the form with Application having PersonalHealthInfo and the uploaded Medical Form
            UploadMedicalFormController myPageCon = new UploadMedicalFormController();            
            myPageCon.uploadedFile=Blob.valueOf('Test');
            myPageCon.filename='test';
            myPageCon.FormSubmit();
            
            //Submitting the form without Medical Form
            UploadMedicalFormController myPageCon1 = new UploadMedicalFormController();            
            myPageCon1.FormSubmit();

            //Submitting the form with File name alone
            UploadMedicalFormController myPageCon2 = new UploadMedicalFormController();            
            myPageCon2.filename='test';
            myPageCon2.FormSubmit();
            
            Pagereference pageRef1 = Page.UploadMedicalForm;
            pageRef1.getParameters().put('appid', app1.id);
            Test.setCurrentPageReference(pageRef1);
            
            //Submitting the form with Application having no PersonalHealthInfo and the uploaded Medical Form            
            UploadMedicalFormController myPageCon3 = new UploadMedicalFormController();            
            myPageCon3.uploadedFile=Blob.valueOf('Test');
            myPageCon3.filename='test';
            myPageCon3.filesize=5242885;
            myPageCon3.FormSubmit();

        }    
                                
    
    }
}