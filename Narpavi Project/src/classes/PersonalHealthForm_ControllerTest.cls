@isTest
public class PersonalHealthForm_ControllerTest{

static testMethod void PersonalHealthFormControllerUnitTest1() 
{

        Id countryUser = [SELECT Id FROM User WHERE UserRoleId != '' AND isActive=true LIMIT 1 ].Id;      
        
        Profile PGMProfile = [SELECT id FROM Profile WHERE name = 'System Administrator' ];  
        
        User u1 = new User(alias = 'UserT',email = 'testPolicies@vsoint.org',emailencodingkey = 'UTF-8',firstname='f1',
                          lastname = 'TestUser',languagelocalekey = 'en_US',localesidkey = 'en_US',profileid = PGMProfile.Id, 
                          timezonesidkey = 'America/Los_Angeles',username = 'testPolicies@vsoint.org');
        insert u1;        
        
        Country__c country = new Country__c(Name = 'TestClassCountry',Region__c = 'Europe',Country_People_Manager__c = countryUser, 
                                            Country_Director__c = countryUser);        
        insert country;
                
        System.runAs(u1) {
            
            Contact con = new Contact(firstName = 'Test',lastName = 'Test',email='testPolicies1@test.com');
            insert con;
            
            Account acc = new Account(Name = 'Test');
            insert acc;
                                           
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            //Volunteer job
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,People_Group_Manager__c=u1.id,People_Group_Admin__c=u1.id,
                                  Job_Reason__c='jobtest',RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,
                                  Job_Title__c='IT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                        
            Application__c appln=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id,
                                                    Submission_Date__c=system.today());
            insert appln; 
       
       List<Health_Problem__c> lstHP=new List<Health_Problem__c>();
       Health_Problem__c hp=new Health_Problem__c(Health_Problem__c='High Blood Pressure',Is_Women_Only__c=false); 
       lstHP.add(hp);      
       Health_Problem__c hp1=new Health_Problem__c(Health_Problem__c='Heart attack',Is_Women_Only__c=false);       
       lstHP.add(hp1);      
       Health_Problem__c hp2=new Health_Problem__c(Health_Problem__c='Current contraception',Is_Women_Only__c=true);       
       lstHP.add(hp2);      
       Health_Problem__c hp3=new Health_Problem__c(Health_Problem__c='Any problems during pregnancy',Is_Women_Only__c=true);                     
       lstHP.add(hp3);  
       insert lstHP;
      
       Pagereference pageRef1 = Page.ApplicantPersonalHealthPage;
       pageRef1.getParameters().put('appid', appln.id);
       Test.setCurrentPageReference(pageRef1);
       
       //Submit the forms with all the health problems with Null values 
       PersonalHealthForm_Controller phiCon= new PersonalHealthForm_Controller();
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_allergies__c=''; 
       phiCon.PersonalHealthInfo.Volunteer_Or_Employee__c='Volunteer';
       phiCon.PersonalHealthInfo.How_Long_Working_Overseas_With_VSO__c='3 months or less';
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_allergies__c='No significant allergies';
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_health_probl__c='No';
       phiCon.PersonalHealthInfo.Do_you_have_a_current_medical_condition__c='No';
       phiCon.PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c='No';
       phiCon.PersonalHealthInfo.Are_you_taking_any_regular_prescription__c='No';
       phiCon.PersonalHealthInfo.Any_special_dietary_requirements__c='No';
       phiCon.PersonalHealthInfo.Do_you_smoke_tobacco__c='No';
       phiCon.PersonalHealthInfo.Do_you_drink_alcohol__c='No';
       phiCon.PersonalHealthInfo.Problem_controlling_drinking_habits__c='No';
       phiCon.PersonalHealthInfo.Declaration__c=true;
       phiCon.PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c='No';
       //phiCon.PersonalHealthInfo.healthProblem1Error='';
       //phiCon.PersonalHealthInfo.healthProblem6Err='';
       phiCon.PersonalHealthFormSubmit();
       
       //Submit the forms with all the health problems with '' empty values       
       PersonalHealthForm_Controller phiCon1= new PersonalHealthForm_Controller();
       phiCon1.PersonalHealthInfo.Do_you_have_any_significant_allergies__c='Test';
       phiCon1.PersonalHealthInfo.Significant_Allergy_Details__c='';
       phiCon1.PersonalHealthInfo.Do_you_carry_an_adrenalin_pen__c='';
       phiCon1.PersonalHealthInfo.Do_you_have_any_significant_health_probl__c=''; 
       phiCon1.PersonalHealthInfo.Do_you_have_a_current_medical_condition__c='';         
       phiCon1.PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c='';    
       phiCon1.PersonalHealthInfo.Are_you_taking_any_regular_prescription__c='';
       phiCon1.PersonalHealthInfo.Any_special_dietary_requirements__c='';
       phiCon1.PersonalHealthInfo.Do_you_smoke_tobacco__c='';
       phiCon1.PersonalHealthInfo.Do_you_drink_alcohol__c='';
       phiCon1.PersonalHealthInfo.Problem_controlling_drinking_habits__c='';
       phiCon1.PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c='';
       phiCon1.PersonalHealthFormSubmit();

       PersonalHealthForm_Controller phiCon2= new PersonalHealthForm_Controller();       
       phiCon2.PersonalHealthInfo.Do_you_have_any_significant_health_probl__c='yes';       
       phiCon2.PersonalHealthInfo.Significant_Health_Problem_Details__c='';
       phiCon2.PersonalHealthInfo.Do_you_have_a_current_medical_condition__c='yes';
       phiCon2.PersonalHealthInfo.Current_Medical_Condition_Details__c='';       
       phiCon2.PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c='yes';
       phiCon2.PersonalHealthInfo.Current_Dental_Treatment_Details__c='';
       phiCon2.PersonalHealthInfo.Are_you_taking_any_regular_prescription__c='yes';
       phiCon2.PersonalHealthInfo.Regular_Prescription_Details__c='';
       phiCon2.PersonalHealthInfo.Any_special_dietary_requirements__c='yes';
       phiCon2.PersonalHealthInfo.Special_Dietary_Details__c='';
       phiCon2.PersonalHealthInfo.Do_you_smoke_tobacco__c='yes';
       phiCon2.PersonalHealthInfo.Smoke_Tobacco_Details__c='';
       phiCon2.PersonalHealthInfo.Do_you_drink_alcohol__c='yes';
       phiCon2.PersonalHealthInfo.Drink_Alcohol_Details__c='';
       phiCon2.PersonalHealthInfo.Problem_controlling_drinking_habits__c='yes';
       phiCon2.PersonalHealthInfo.Drinking_Habits_Details__c='';
       phiCon2.PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c='yes';
       phiCon2.PersonalHealthInfo.Recreational_Drugs_Details__c='';
       phiCon2.PersonalHealthFormSubmit();
       
       PersonalHealthForm_Controller phiCon3= new PersonalHealthForm_Controller();       
       phiCon3.PersonalHealthInfo.Do_you_have_any_significant_health_probl__c='yes';       
       phiCon3.PersonalHealthInfo.Significant_Health_Problem_Details__c='test';
       phiCon3.PersonalHealthInfo.Do_you_have_a_current_medical_condition__c='yes';
       phiCon3.PersonalHealthInfo.Current_Medical_Condition_Details__c='test';       
       phiCon3.PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c='yes';
       phiCon3.PersonalHealthInfo.Current_Dental_Treatment_Details__c='test';
       phiCon3.PersonalHealthInfo.Are_you_taking_any_regular_prescription__c='yes';
       phiCon3.PersonalHealthInfo.Regular_Prescription_Details__c='test';
       phiCon3.PersonalHealthInfo.Any_special_dietary_requirements__c='yes';
       phiCon3.PersonalHealthInfo.Special_Dietary_Details__c='test';
       phiCon3.PersonalHealthInfo.Do_you_smoke_tobacco__c='yes';
       phiCon3.PersonalHealthInfo.Smoke_Tobacco_Details__c='test';
       phiCon3.PersonalHealthInfo.Do_you_drink_alcohol__c='yes';
       phiCon3.PersonalHealthInfo.Drink_Alcohol_Details__c='test';
       phiCon3.PersonalHealthInfo.Problem_controlling_drinking_habits__c='yes';
       phiCon3.PersonalHealthInfo.Drinking_Habits_Details__c='test';
       phiCon3.PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c='yes';
       phiCon3.PersonalHealthInfo.Recreational_Drugs_Details__c='test';
       phiCon3.PersonalHealthFormSubmit(); 
     }       
}

static testMethod void PersonalHealthFormControllerUnitTest2() 
{

        Id countryUser = [SELECT Id FROM User WHERE UserRoleId != '' AND isActive=true LIMIT 1 ].Id;      
        
        Profile PGMProfile = [SELECT id FROM Profile WHERE name = 'System Administrator' ];  
        
        User u1 = new User(alias = 'UserT',email = 'testPolicies@vsoint.org',emailencodingkey = 'UTF-8',firstname='f1',
                          lastname = 'TestUser',languagelocalekey = 'en_US',localesidkey = 'en_US',profileid = PGMProfile.Id, 
                          timezonesidkey = 'America/Los_Angeles',username = 'testPolicies@vsoint.org');
        insert u1;        
        
        Country__c country = new Country__c(Name = 'TestClassCountry',Region__c = 'Europe',Country_People_Manager__c = countryUser, 
                                            Country_Director__c = countryUser);        
        insert country;
                
        System.runAs(u1) {
            
            Contact con = new Contact(firstName = 'Test',lastName = 'Test',email='testPolicies1@test.com');
            insert con;
            
            Account acc = new Account(Name = 'Test');
            insert acc;
                                           
            List<RecordType> JobRecordTypes=new List<RecordType>();
            JobRecordTypes=[SELECT id,developername,name FROM RecordType WHERE SobjectType='Job__c' AND (Developername='Employee_Job_Approved' OR Developername='Approved_Volunteer_Job')];
            
            //Volunteer job
            Job__c job=new Job__c(Hiring_Manager__c=u1.id,People_Group_Manager__c=u1.id,People_Group_Admin__c=u1.id,
                                  Job_Reason__c='jobtest',RecordTypeid=JobRecordTypes[1].id,Ready_To_Publish__c=true,
                                  External_Advert_Start_Date__c=system.today()-30,External_Advert_End_Date__c=system.today()+30,
                                  Name='TestJob',Projected_Start_Date__c=system.today()+10, Demand_Sign_Off_Date__c=null,
                                  Job_Title__c='IT',Country__c=country.id,Job_Status__c='Approved for Recruitment');
            insert job;
                        
            Application__c appln=new Application__c(Applicant__c=con.id ,Send_Decline_Email__c=false, Job__c=job.Id,
                                                    Submission_Date__c=system.today());
            insert appln; 
       
       List<Health_Problem__c> lstHP=new List<Health_Problem__c>();
       Health_Problem__c hp=new Health_Problem__c(Health_Problem__c='High Blood Pressure',Is_Women_Only__c=false); 
       lstHP.add(hp);      
       Health_Problem__c hp1=new Health_Problem__c(Health_Problem__c='Heart attack',Is_Women_Only__c=false);       
       lstHP.add(hp1);      
       Health_Problem__c hp2=new Health_Problem__c(Health_Problem__c='Current contraception',Is_Women_Only__c=true);       
       lstHP.add(hp2);      
       Health_Problem__c hp3=new Health_Problem__c(Health_Problem__c='Any problems during pregnancy',Is_Women_Only__c=true);                     
       lstHP.add(hp3);  
       
      
       Pagereference pageRef1 = Page.ApplicantPersonalHealthPage;
       pageRef1.getParameters().put('appid', appln.id);
       Test.setCurrentPageReference(pageRef1);
       
       //Submit the forms with all the health problems with Null values 
       PersonalHealthForm_Controller phiCon= new PersonalHealthForm_Controller();
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_allergies__c=''; 
       phiCon.PersonalHealthInfo.Volunteer_Or_Employee__c='Volunteer';
       phiCon.PersonalHealthInfo.How_Long_Working_Overseas_With_VSO__c='3 months or less';
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_allergies__c='No significant allergies';
       phiCon.PersonalHealthInfo.Do_you_have_any_significant_health_probl__c='No';
       phiCon.PersonalHealthInfo.Do_you_have_a_current_medical_condition__c='No';
       phiCon.PersonalHealthInfo.Are_you_currently_receiving_any_dental_t__c='No';
       phiCon.PersonalHealthInfo.Are_you_taking_any_regular_prescription__c='No';
       phiCon.PersonalHealthInfo.Any_special_dietary_requirements__c='No';
       phiCon.PersonalHealthInfo.Do_you_smoke_tobacco__c='No';
       phiCon.PersonalHealthInfo.Do_you_drink_alcohol__c='No';
       phiCon.PersonalHealthInfo.Problem_controlling_drinking_habits__c='No';
       phiCon.PersonalHealthInfo.Declaration__c=true;
       phiCon.PersonalHealthInfo.Problem_Controlling_Recreational_Drugs__c='No';
       phiCon.PersonalHealthFormSubmit();
    
     }       
}

static testMethod void testgetHealthOptions()
{
  PersonalHealthForm_Controller phi= new PersonalHealthForm_Controller();
  phi.getHealthOptions();
  phi.getWomenHealthOptions();
  phi.getGPOptions();
  phi.getSpecialistOptions();
  phi.getVolOrEmpOptions();
  phi.getWorkingWithVSOOptions();
  phi.getRuralOrUrbanOptions(); 
  phi.getSignificantHealthProblemOptions();
  phi.getCurrentMedicalCondtOptions();
  phi.getDentalTandCOptions();
  phi.getRegularPrescriptionOptions();
  phi.getSignificantAllergiesOptions();
  phi.getAdrenalinPenOptions();
  phi.getSpecialDietaryOptions();
  phi.getSmokeTobaccoOptions();
  phi.getDrinkAlcoholOptions();
  phi.getControllingDrinkingOptions();
  phi.getControllingDrugsOptions();
  phi.getCountryList();
}



}