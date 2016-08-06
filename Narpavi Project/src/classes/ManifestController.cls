/* * Created By: Poornima -TPT
   * Project Name: M&E Implementation
   * Created Date: (24-Dec-2015)
   * Description:
        1. To update the manifest file to update the browser cache and local storage
*/

public class ManifestController
{   
    public string url{get;set;}    
    string siteurl;
    public String frameworkId;
    public Integer frameworkVersion {get; set;}
    public string lastChanged {get;set;}
    
    public ManifestController()
    {   
        url=''; 
        frameworkId=ApexPages.currentPage().getParameters().get('pfid');        
        if(frameworkId!=null)
        {
            Results_Framework__c rf=[select id,Version__c,lastmodifieddate  from Results_Framework__c  where id=:frameworkId];
            VSO_Site_Settings__c site = VSO_Site_Settings__c.getInstance('Results Framework');
            if(site != null){
                siteurl = site.Site_URL__c;        
            }
                             
            url += '\n'+siteurl+'?pfID='+ frameworkId;
            frameworkVersion =Integer.valueof(rf.Version__c);    
        }
        updateManifestFile();
    }
    
    public void updateManifestFile()
    {
        
        List<Results_Framework__c> pfList=[select id,lastmodifieddate from Results_Framework__c];        
        if(pfList.size()>0)
        {            
            for(Results_Framework__c pf:pfList)
            {   
                lastChanged+= string.valueof(pf.lastmodifieddate);
            }
        }            
        
    }
}