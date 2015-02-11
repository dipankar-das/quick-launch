/**
 * BetterSideClr a controller class for BetterSide page
 * @author ddas
 * @copyright DistinctData Inc.
 */
public with sharing class BetterSideClr {

    private transient List<Folder__c> appFolders;
    
    public BetterSideClr(){
    
    }
    
    public List<Schema.DescribeTabSetResult> getTabInfos(){
        return Schema.describeTabs();
    
    }
    
    public String getFolderItemSequence(){
        
        return  JSON.serializePretty(getFolders());
    }
    
    private List<Folder__c> getFolders(){
      if (appFolders == null) {
        appFolders = new List<Folder__c>();
        
          for(Folder__c folder : [SELECT Id, Name, Type__c, Sequence__c,
                          (SELECT Id, Name, Sequence__c
                              FROM Items__r 
                              ORDER BY Sequence__c) 
                              FROM Folder__c 
                              WHERE CreatedById = :UserInfo.getUserId()
                              ORDER BY Sequence__c]){
      
        if (folder.Type__c == 'App') {
          appFolders.add(folder);
          
        }                        
                                
        }                                
       
      }                          
                              
      return appFolders;  
    }

}