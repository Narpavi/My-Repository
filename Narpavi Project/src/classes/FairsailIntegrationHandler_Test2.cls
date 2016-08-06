@isTest
public class FairsailIntegrationHandler_Test2 {

    static testMethod void CanMakeOnboardingDataList()
    {
        List<OnboardingCheck__c> onbList = SetupOnboardingObjects(false,'Test1','Test2');
        List<FairsailIntegrationHandler.OnboardingData> odb = FairsailIntegrationHandler.getHandler().GetOnboardingDataList(onbList);
        
        System.assertEquals(2, odb.size());
    }
    
    

    static testMethod void CanOnboardingCompleteTriggerFire(){

        List<OnboardingCheck__c> onbList = SetupOnboardingObjects(false,'Test1','Test2');
        OnboardingCheck__c onb1 = onbList[0];
        OnboardingCheck__c onb2 = onbList[1];
        FairsailIntegrationHandler.ClearRunOnce();
        
        // make update to trigger change
        Test.startTest();
        onb1.Onboarding_Status__c = 'Cleared to Start';
        onb1.Entitled_to_HCFA__c = 'Yes';
        onb1.Criminal_Check_Type__c='Police Check';
        onb1.Continuing_Assessment_Status__c='No Concern';
        onb2.Onboarding_Status__c = 'Cleared to Start';
        onb2.Entitled_to_HCFA__c = 'Yes';
        onb2.Criminal_Check_Type__c='Police Check';
        onb2.Continuing_Assessment_Status__c='No Concern';
        
        update onbList;
        Test.stopTest();
        
        OnboardingCheck__c onbafter1 = [select Id, Contact__c, Helper_Ready_For_Transfer_To_Fairsail__c, Transferred_to_Fairsail__c from OnboardingCheck__c where Id=:onb1.Id];
        
        System.assertEquals(true, onbafter1.Helper_Ready_For_Transfer_To_Fairsail__c);
        System.assertEquals(true, onbafter1.Transferred_to_Fairsail__c);
        
        OnboardingCheck__c onbafter2 = [select Id, Contact__c, Helper_Ready_For_Transfer_To_Fairsail__c, Transferred_to_Fairsail__c from OnboardingCheck__c where Id=:onb2.Id];
        
        System.assertEquals(true, onbafter2.Helper_Ready_For_Transfer_To_Fairsail__c);
        System.assertEquals(true, onbafter2.Transferred_to_Fairsail__c);
        
        
        Contact c1 = [select Id, Team_Member__c from Contact where Id=:onbafter1.Contact__c];
        
        fHCM2__Team_Member__c tm1 = [select Id, fHCM2__First_Name__c, fHCM2__Surname__c 
                    from fHCM2__Team_Member__c
                    where Id=: c1.Team_Member__c];
        
        System.assert(tm1!=null);
        
        
        
        
        
    
    }
    
    static testMethod void CanEditUnrelatedTeamMemberFieldsWithoutTriggeringContactSync()
    {
        List<fHCM2__Team_Member__c> tmList = SetupTeamMemberContactObjects('Test1','Test2');
        FairsailIntegrationHandler.ClearRunOnce();  
        TeamMemberTrigger.ClearRunOnce();      
        Test.startTest();
        
        // these fields are not synced to contact so changing them should not cause contact update
        tmList[0].fHCM2__Job_Title__c = 'Something';
        tmList[1].fHCM2__Location__c = 'Cameroon';
        
        update tmList;
        Test.stopTest();
        
        // check debug collection to see if contacts were updated
        List<Id> debugInfo = FairsailIntegrationHandler.getHandler().debugContactIdsChanged;
        
        System.assertEquals(true, debugInfo!=null,'expecting debugContactIdsChanged to return a list');
        System.assertEquals(0, debugInfo .size(), 'expecting debugContactIdsChanged to have no items');
    }
    
    static testMethod void CanEditSyncedTeamMemberFieldsAndTriggerContactSync()
    {
        List<fHCM2__Team_Member__c> tmList = SetupTeamMemberContactObjects('Test1','Test2');
        FairsailIntegrationHandler.ClearRunOnce();
        TeamMemberTrigger.ClearRunOnce();
        Test.startTest();
        
        // these fields are not synced to contact so changing them should not cause contact update
        tmList[0].fHCM2__First_Name__c = 'Terry';
        tmList[1].fHCM2__First_Name__c = 'Billy';
        
        update tmList;
        Test.stopTest();
        
        // check debug collection to see if contacts were updated
        List<Id> debugInfo = FairsailIntegrationHandler.getHandler().debugContactIdsChanged;
        
        System.assertEquals(true, debugInfo!=null,'expecting debugContactIdsChanged to return a list');
        System.assertEquals(2, debugInfo .size(), 'expecting debugContactIdsChanged to have 2 items');
        
        // fetch contacts
        Contact c0 = [select id, FirstName from Contact where Id=:tmList[0].VSO_Recruit_Contact_Record__c];
        Contact c1 = [select id, FirstName from Contact where Id=:tmList[1].VSO_Recruit_Contact_Record__c];
        System.assertEquals('Terry',c0.FirstName, 'expecting 1st contact name to be changed');
        System.assertEquals('Billy',c1.FirstName, 'expecting 2nd contact name to be changed');
    }
    


    private static List<OnboardingCheck__c> SetupOnboardingObjects(boolean useClearedToStart, String testLabel1, String testLabel2)
    {
        Account acc = new Account();
        acc.Name = 'Dummy Recruitment Partner';
        insert acc;
    
        Country__c country = new Country__c();
        country.Name = 'Dummy Country';
        country.Country_People_Manager__c =userinfo.getUserId();
        country.Country_Director__c=userinfo.getUserId();
        insert country;
    
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
        
        List<RecordType> jobRecordTypes=[select id,developername,name from RecordType where SobjectType='Job__c' AND Developername='Approved_Volunteer_Job'];
        List<RecordType> offerRecordTypes=[select id,developername,name from RecordType where SobjectType='Offer__c' AND Developername='Volunteer_Offer'];    

        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Firstname=testLabel1,lastname='user1',email='test@testorg.com',Primary_Type__c='Applicant',MailingStreet='123 Acacia Avenue'));
        contactList.add(new Contact(Firstname=testLabel2,lastname='user1',email='test@testorg.com',Primary_Type__c='Applicant',MailingStreet='123 Acacia Avenue'));
        insert contactList;
    
        List<Job__c> jobList = new List<Job__c>();     
        jobList.add(new Job__c(RecordTypeid=jobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name=testLabel1,Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,
            Job_Title__c='JT',Country__c=country.id,Job_Status__c='Candidate Sourced'));
        jobList.add(new Job__c(RecordTypeid=jobRecordTypes[0].id,Ready_To_Publish__c=true,External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,Name=testLabel2,Projected_Start_Date__c=system.today()+10,Projected_End_Date__c=system.today()+20,Demand_Sign_Off_Date__c=null,
            Job_Title__c='JT',Country__c=country.id,Job_Status__c='Candidate Sourced'));
        insert jobList;
        
        // temportaty
        Contact c = contactList[0];
        Job__c j = jobList[0];
        
        List<Application__c> appList = new List<Application__c>();
        appList.add(new Application__c(Applicant__c=contactList[0].id ,Job__c=jobList[0].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',
            Consent_Date__c=system.today(),Declaration_Date__c=system.today(), Status__c = 'Onboarding in Progress'));
        appList.add(new Application__c(Applicant__c=contactList[1].id ,Job__c=jobList[1].id,Send_Decline_Email__c=false,Submission_Date__c=system.today(),Eligibility_To_Work__c='Yes',
            Consent_Date__c=system.today(),Declaration_Date__c=system.today(), Status__c = 'Onboarding in Progress'));
        insert appList; 
    
        List<Offer__c> offerList = new List<Offer__c>();
        offerList.add(new Offer__c(Applicant__c=contactList[0].id ,Application__c=appList[0].id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=offerRecordTypes[0].Id,
            Payroll_Office_processing_location__c=country.id, Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today()));             
        offerList.add(new Offer__c(Applicant__c=contactList[1].id ,Application__c=appList[1].id,Status__c='Sent',VSO_Offer_Contact_Person__c=userinfo.getUserId(),RecordTypeid=offerRecordTypes[0].Id,
            Payroll_Office_processing_location__c=country.id, Offer_Status__c='Conditional Offer Accepted',Conditional_Offer_Date__c=system.today(),Conditional_Offer_Response__c='Accepted',Conditional_Offer_Response_Date__c=system.today()));             
        insert offerList;    
            
        // link offers back tp application
        appList[0].Help_Offer__c=offerList[0].Id;
        appList[0].Help_Offer_Status__c = 'Conditional Offer Accepted';
        appList[1].Help_Offer__c=offerList[1].Id;
        appList[1].Help_Offer_Status__c = 'Conditional Offer Accepted';
        update appList;
        
        List<OnboardingCheck__c> onboardingList = new List<OnboardingCheck__c>();
        onboardingList.add(new OnboardingCheck__c(Offer__C=offerList[0].Id, Application__C=appList[0].Id, Contact__c = contactList[0].Id,
            Transferred_to_Fairsail__c = false, Onboarding_Status__c = 'Onboarding in Progress', Confirmed_Start_of_Service_Date__c =  date.today().addDays(5), Cleared_to_Start_Date__c = date.today(),
            References_Overall_Status__c = 'References Satisfactory', Medical_Clearance_Type__c = 'Medically cleared for any job', Medical_Clearance_Date__c = date.today().addDays(-10),
            Criminal_Background_Clearance_Status__c = 'Cleared', Criminal_Background_Clearance_Date__c =date.today().addDays(-10), Criminal_Background_Reviewer__c = UserInfo.getUserId(),
            Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a', VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon',
            Entitled_to_HCFA__c='No', Nationality__c='Test', Continuing_Assessment_Status__c='No Concern', Recruitment_Partner__c = acc.Id,
            Relationship_Manager__c = userinfo.getUserId(), Criminal_Check_Type__c='Police Check'));
        onboardingList.add(new OnboardingCheck__c(Offer__C=offerList[1].Id, Application__C=appList[1].Id, Contact__c = contactList[1].Id,
            Transferred_to_Fairsail__c = false, Onboarding_Status__c = 'Onboarding in Progress', Confirmed_Start_of_Service_Date__c =  date.today().addDays(5), Cleared_to_Start_Date__c = date.today(),
            References_Overall_Status__c = 'References Satisfactory', Medical_Clearance_Type__c = 'Medically cleared for any job', Medical_Clearance_Date__c = date.today().addDays(-10),
            Criminal_Background_Clearance_Status__c = 'Cleared', Criminal_Background_Clearance_Date__c =date.today().addDays(-10), Criminal_Background_Reviewer__c = UserInfo.getUserId(),
            Vol_Accomp_Partner_Criminally_Cleared__c = 'n/a', VSO_People_HR_Department__c = 'Vol - VSO UK / Cameroon',
            Entitled_to_HCFA__c='No', Nationality__c='Test', Continuing_Assessment_Status__c='No Concern', Recruitment_Partner__c = acc.Id,
            Relationship_Manager__c = userinfo.getUserId(), Criminal_Check_Type__c='Police Check'));
        insert onboardingList ;
        
        
        //onb.Application__r = a;
        //onb.Contact__r = c;
      
        
        
        return onboardingList ;
    
    }

    private static List<fHCM2__Team_Member__c> SetupTeamMemberContactObjects(String testLabel1, String testLabel2)
    {
        fHCM2__Department__c dept = new fHCM2__Department__c();
        dept.name  = 'Vol - VSO UK / Cameroon';
        insert dept;
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Firstname=testLabel1,lastname='user1',email='test@testorg.com',Primary_Type__c='Applicant',MailingStreet='123 Acacia Avenue'));
        contactList.add(new Contact(Firstname=testLabel2,lastname='user2',email='test@testorg.com',Primary_Type__c='Applicant',MailingStreet='123 Acacia Avenue'));
        insert contactList;
        
        List<fHCM2__Team_Member__c> tmList = new List<fHCM2__Team_Member__c>();
        tmList.add(new fHCM2__Team_Member__c(fHCM2__First_Name__c=testLabel1, fHCM2__Surname__c = 'user1', fHCM2__Home_Email__c='test@testorg.com',
            fHCM2__Home_Address_1__c = '123 Acacia Avenue', fHCM2__Department__c=dept.Id, VSO_Recruit_Contact_Record__c=contactList[0].Id));
        tmList.add(new fHCM2__Team_Member__c(fHCM2__First_Name__c=testLabel2, fHCM2__Surname__c = 'user2', fHCM2__Home_Email__c='test@testorg.com',
            fHCM2__Home_Address_1__c = '123 Acacia Avenue', fHCM2__Department__c=dept.Id, VSO_Recruit_Contact_Record__c=contactList[1].Id));
        insert tmList;
        
        return tmList;
    }

}