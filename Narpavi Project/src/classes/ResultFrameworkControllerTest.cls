/* * Created By: Dinesh -TPT
   * Project Name: M&E Implementation
   * Created Date: (05-July-2016)
   * Description:Test class created to test the Results Framework form functionalities.
*/
@isTest
public class ResultFrameworkControllerTest {

    static testMethod void resultsFrameworkUnitTest1()
    {
        Id countryUser = [SELECT Id FROM User WHERE UserRoleId!='' AND isActive=true LIMIT 1].Id; 
           
        Profile p = [select id from profile where name='System Administrator'];  
        
        User u = new User(alias = 'RFW', email='Result_FrameWorkTest@testorg.com', 
                          emailencodingkey='UTF-8', lastname='Result_FrameWorkTest', languagelocalekey='en_US', 
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='Result_FrameWorkTest@testorg.com');  
        insert u;

        Country__c c=new Country__c(Name='TestClassCountry', Region__c='Europe', 
                                    Country_People_Manager__c=countryUser, Country_Director__c=countryUser);
        insert c;  
        
        Account acc = new Account(Name='Test');
        insert acc;
        
        system.runAs(u)
        {
            Map<String,Id> mapMelQuestionRecdType=new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='MEL_Question__c']){
             mapMelQuestionRecdType.put(rt.developername,rt.id);
            }
            
            


            //MEL Composite Indicator Question   
            MEL_Question__c melCI=new MEL_Question__c(Name='TestMELQuestion',RecordTypeId=mapMelQuestionRecdType.get('Composite_Indicator'),
                                                      Active__c=false,Definition__c='Test MEL Question',Indicator_Level__c='Outcome',
                                                      Indicator_Question_Type__c='Percentage',Target_Aggregation__c='Non-Cumulative');
            insert melCI;
            
            //Related Question-1
            MEL_Question__c melRQ1=new MEL_Question__c(Name='TestMELRQ1',Question_Text_on_Form__c='Test Q1',
                                                       RecordTypeId=mapMelQuestionRecdType.get('Related_Question'),Active__c=true,
                                                       Composite_Relationship__c='Sum / Contributing Amount',
                                                       Composite_Indicator_Question__c=melCI.id,Definition__c='Test');
            insert melRQ1;
            
            //Related Question-2            
            MEL_Question__c melRQ2=new MEL_Question__c(Name='TestMELRQ2',Question_Text_on_Form__c='Test Q2',
                                                       RecordTypeId=mapMelQuestionRecdType.get('Related_Question'),Active__c=true,
                                                       Composite_Relationship__c='Percentage Base',
                                                       Composite_Indicator_Question__c=melCI.id,Definition__c='Test');
            insert melRQ2;
            
            //MEL Indicator Question        
            MEL_Question__c melInd=new MEL_Question__c(Name='TestMELIndicator',Indicator_Level__c='Impact',
                                                       Indicator_Question_Type__c='Text',Question_Text_on_Form__c='Test Q3',
                                                       Definition__c='Test',RecordTypeId=mapMelQuestionRecdType.get('Indicator'),Active__c=true);
            insert melInd;

            //MEL Indicator Question Picklist       
            MEL_Question__c melIndPick=new MEL_Question__c(Name='TestMELIndicator',Indicator_Level__c='Impact',
                                                           Indicator_Question_Type__c='Picklist',Indicator_Question_Picklist_Options__c='Test1',
                                                           Question_Text_on_Form__c='Test Q4',Definition__c='Test',
                                                           RecordTypeId=mapMelQuestionRecdType.get('Indicator'),Active__c=true);
            insert melIndPick;
            
            //MEL Question record type       
            MEL_Question__c melQue=new MEL_Question__c(Name='TestMELQuestion',Indicator_Level__c='Output',
                                                       Indicator_Question_Type__c='Number',Question_Text_on_Form__c='Test Q5',
                                                       Definition__c='Test',RecordTypeId=mapMelQuestionRecdType.get('Question'),Active__c=true);
            insert melQue;
            
            MEL_Question__c melCIupdate=new MEL_Question__c(id=melCI.id,Active__c=true);
            update melCIupdate;      
            
            List<Framework_Question__c> lstFQ=new  List<Framework_Question__c>();  
            Map<String,Id> mapFWQuestionRecdType=new Map<String,Id> ();
            for(RecordType rt:[select id,name,developername from RecordType where SobjectType='Framework_Question__c']){
                mapFWQuestionRecdType.put(rt.developername,rt.id);
            }

            //Results Framework Record-1      
            Results_Framework__c rf= new Results_Framework__c(Name='TestResultFrameWork',Reporting_Frequency__c='Quarterly',
                                                             Results_Framework_Start_Date__c=Date.newInstance(2016, 2, 1),
                                                             Description__c='Test ResultFrameWork',Results_Framework_End_Date__c=Date.newInstance(2017, 2, 1),
                                                             Country__c=c.id);
            insert rf;
            
            //Framework Question-1
            Framework_Question__c fq1=new Framework_Question__c(RecordTypeId=mapFWQuestionRecdType.get('Indicator_Question'),
                                                               Indicator_Question__c=melCI.id,Results_Framework__c=rf.id,
                                                               Active__c=true,Data_Source__c='Test');
            lstFQ.add(fq1);
            
            //Framework Question-2
            Framework_Question__c fq2=new Framework_Question__c(RecordTypeId=mapFWQuestionRecdType.get('Indicator_Question'),
                                                               Indicator_Question__c=melInd.id,Results_Framework__c=rf.id,
                                                               Active__c=true,Data_Source__c='Test');
            lstFQ.add(fq2);
            
            //Framework Question-3
            Framework_Question__c fq3=new Framework_Question__c(RecordTypeId=mapFWQuestionRecdType.get('Indicator_Question'),
                                                               Indicator_Question__c=melIndPick.id,Results_Framework__c=rf.id,
                                                               Active__c=true,Data_Source__c='Test');
            lstFQ.add(fq3);

            //Framework Question-4
            Framework_Question__c fq4=new Framework_Question__c(RecordTypeId=mapFWQuestionRecdType.get('Indicator_Question'),
                                                               Indicator_Question__c=melQue.id,Results_Framework__c=rf.id,
                                                               Active__c=true,Data_Source__c='Test');
            lstFQ.add(fq4);
            
            if(lstFQ.Size()>0){
                insert lstFQ;
            }

            Results_Framework_Partner__c rfp=new Results_Framework_Partner__c(Name='TestPartner',
                                                                              Partner__c=acc.id,
                                                                              Results_Framework__c=rf.id);
            insert rfp;
            
            //Results Framework Record-2      
            Results_Framework__c rf1= new Results_Framework__c(Name='TestResultFrameWork-2',Reporting_Frequency__c='Monthly',
                                                             Results_Framework_Start_Date__c=Date.newInstance(2016, 2, 1),
                                                             Description__c='Test ResultFrameWork',Results_Framework_End_Date__c=Date.newInstance(2017, 2, 1),
                                                             Country__c=c.id);
            insert rf1;
            
            //Framework Question-1 for RF Record-2
            Framework_Question__c fq5=new Framework_Question__c(RecordTypeId=mapFWQuestionRecdType.get('Indicator_Question'),
                                                               Indicator_Question__c=melCI.id,Results_Framework__c=rf1.id,
                                                               Active__c=true,Data_Source__c='Test');
            lstFQ.add(fq5);            
            
            Results_Framework_Partner__c rfp1=new Results_Framework_Partner__c(Name='TestPartner-1',
                                                                              Partner__c=acc.id,
                                                                              Results_Framework__c=rf1.id);
            insert rfp1;
                                 
            fHCM2__Employment__c er=new fHCM2__Employment__c(Notice_Period_months__c=decimal.valueof('2'),fHCM2__Basis__c='Volunteer',Country__c=c.id);
            insert  er; 
           
            fHCM2__Department__c Dept=new fHCM2__Department__c(name='TestDepartment');
            insert Dept;            
            
            fHCM2__Team_Member__c tm=new fHCM2__Team_Member__c(fHCM2__First_Name__c='Test',fHCM2__Surname__c='Member',
                                                               Recruitment_Partner__c=acc.id,Relationship_Manager__c=u.id,
                                                               fHCM2__Department__c=Dept.id,fHCM2__Current_Employment__c=er.id);
            insert tm;         
           
           //Submitting RF1 Form 
           Pagereference pagref=Page.ResultFrameworkPage;
           pagref.getParameters().put('pfID',rf.Id);
           //hard coded the json string to submit a response
           string a='[{"response":"1","questionRecordType":"Indicator","qType":"Number","qid":"'+melInd.id+'","id":"'+lstFQ[1].id+'","fqType":"Indicator_Question"}]';
           pagref.getParameters().put('myParam',a);
           Test.setCurrentPageReference(pagref);
           ResultFrameworkController myPageCon =new ResultFrameworkController();
           myPageCon.volunteerName='Test Vol Name';
           myPageCon.partner=acc.id;
           myPageCon.reportingPeriod='Jan - Mar 2016';
           myPageCon.setDate();             
           myPageCon.submitResults();  

           //Resubmitting the RF1 Form second time to test update      
           Pagereference pagref1=Page.ResultFrameworkPage;
           pagref1.getParameters().put('pfID',rf.Id);
           pagref.getParameters().put('myParam',a);
           Test.setCurrentPageReference(pagref1);
           ResultFrameworkController myPageCon1 =new ResultFrameworkController();
           myPageCon1.volunteerName='Test Vol Name';
           myPageCon1.partner=acc.id;
           myPageCon1.reportingPeriod='Jan - Mar 2016';          
           myPageCon1.setDate();             
           myPageCon1.submitResults();  

           //Submitting RF2 Form 
           Pagereference pagref2=Page.ResultFrameworkPage;
           pagref2.getParameters().put('pfID',rf1.Id);
           Test.setCurrentPageReference(pagref2);
           ResultFrameworkController myPageCon2 =new ResultFrameworkController();
           myPageCon2.volunteerName='Test Partner Name';
           myPageCon2.partner=acc.id;
           myPageCon2.reportingPeriod='Jun 2016';                  
           myPageCon2.setDate();             
           myPageCon2.submitResults();  
           
           //Submitting RF2 Form 
           Pagereference pagref3=Page.ResultFrameworkPage;
           pagref3.getParameters().put('pfID',rf1.Id);
           Test.setCurrentPageReference(pagref3);
           ResultFrameworkController myPageCon3 =new ResultFrameworkController();
           myPageCon3.volunteerName='Test Partner Name';
           myPageCon3.partner='Not related to a specific partner';
           myPageCon3.reportingPeriod='Jun 2016';           
           myPageCon3.setDate();             
           myPageCon3.submitResults();  
                   
        }
    }
  
}