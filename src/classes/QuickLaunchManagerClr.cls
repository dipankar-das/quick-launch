/**
 * QuickLaunchManagerClr a controller class for QuickLaunchManager page
 * @author ddas
 * @copyright DistinctData Inc.
 */
public with sharing class QuickLaunchManagerClr {

    public String jsonDataProperty{get; set;}     

    public QuickLaunchManagerClr() {
    
    }
    
    private Integer tabIndex,menuIndex;
   
    public void setTabIndex(Integer tabIndex) {
        this.tabIndex=tabIndex;
    }

    public Integer getTabIndex(){
        return this.tabIndex;
    }
    
    public void setMenuIndex(Integer menuIndex){
        this.menuIndex = menuIndex;
    }

    public Integer getMenuIndex(){
        return this.menuIndex;
    }
    
    public List<Schema.DescribeTabSetResult> getTabInfos(){
      return Schema.describeTabs();
    
    }
    
    /**
     * insert itemid before beforeItemId
     */
    private static void moveItem(ID dragId, Id dropId){
    	List<ID> ids = new ID[]{dragId, dropId};
    	List<Item__c> items = [SELECT Id, FolderId__c, IconUrl__c, IsDeleted__c, IsHighlight__c, Label__c, Sequence__c, TargetUrl__c, Type__c 
    							FROM Item__c WHERE Id IN : ids]; //select all fields so we can clone, when needed
    	Boolean reSequenceTarget = false;						
    	Item__c dragItem;
    	Item__c dropItem;
    	for (Item__c item : items) {
    		if(item.Id == dragId){	
    			dragItem = item;	
    		} else if(item.Id == dropId){	
    			dropItem = item;	
    		}
    		
    	}
    	
    	if (dragItem == null || dropItem == null) {
    		return;
    	}
    	
    	
    	//same folder
    	if (dragItem.folderId__c == dropItem.folderId__c) {
    		Integer dragSequence = dragItem.Sequence__c.intValue();
    		Integer dropSequence = dropItem.Sequence__c.intValue();
    		
    		if (dragSequence == dropSequence) { //same item, should not happen
	    		return;
	    	}
    		List<Item__c> folderItems = [SELECT Id, Sequence__c, FolderId__c FROM Item__c WHERE folderId__c =:dragItem.folderId__c ORDER BY Sequence__c];
    		Integer size = folderItems.size();
    		
    		Boolean moveUp = (dragSequence > dropSequence);
    		for (Item__c item : folderItems) {
    			if (item.Id == dragItem.Id) {
    				item.Sequence__c = dropSequence;
    				continue;
    			}
    			if (moveUp) {
	    			if (item.Sequence__c < dragSequence && item.Sequence__c >= dropSequence) {	
	    				item.Sequence__c = item.Sequence__c + 1;
	    			}
    			} else {//move down
    				if (item.Sequence__c > dragSequence && item.Sequence__c <= dropSequence) {	
	    				item.Sequence__c = item.Sequence__c - 1;
	    			}
    				
    			}
    		}
    		upsert folderItems;
    		
    	} else { //different folder
    		Integer foundCount = [SELECT COUNT() FROM Item__c WHERE folderId__c =:dropItem.folderId__c AND TargetUrl__c = :dragItem.TargetUrl__c];
    		if (foundCount > 0) { //already in target folder
    			dragItem.IsDeleted__c = true;
    			List<Item__c> updateList = new List<Item__c>(); 
    			updateList.add(dragItem);
    			if (dropItem.IsDeleted__c == true) {
    				dropItem.IsDeleted__c = false;
    				updateList.add(dropItem);
    			
    			}
    			upsert updateList;
    			
    		} else { //clone dragItem and move to drop folder
    			Item__c clonedItem = dragItem.clone();
    			clonedItem.FolderId__c = dropItem.FolderId__c;
    			clonedItem.Sequence__c = dropItem.Sequence__c;
    			
    			dragItem.IsDeleted__c = true;//mark drag item as deleted
    			List<Item__c> updateList = new List<Item__c>(); 
    			updateList.add(dragItem);
    			updateList.add(clonedItem);
    			
    			upsert updateList;
    			reSequenceTarget = true;
    			//TODO: sequence clonedItem correctly
    			
    		}
    		
    		
    	}
    	
    	//fix sequence errors
    	
    	if(reSequenceTarget){ //when dragItem is cloned and placed into target folder
    		resequenceItem(dropItem.FolderId__c);
    		
    	} else {
    		resequenceItem(dragItem.FolderId__c);
    		
    	}
    
    }
	
	/** 
	 * resequence
	 */   
    private static void resequenceItem(ID folderId) {
    	Integer seq = 1;
    	List<Item__c> folderItems = [SELECT Id, Sequence__c, FolderId__c FROM Item__c WHERE folderId__c =:folderId ORDER BY Sequence__c];
   		for (Item__c item : folderItems) {
  			item.Sequence__c = seq++;
	    		
   		}
   		upsert folderItems;
    	
    }
    
   /**
     * changes folder sequence based on drag and drop 
     */
    private static void moveFolder(ID dragId, Id dropId){
    	List<ID> ids = new ID[]{dragId, dropId};
    	List<Folder__c> folders = [SELECT Id, IsDeleted__c, Label__c, Sequence__c, Type__c 
    							FROM Folder__c WHERE Id IN : ids]; //select all fields so we can clone, when needed
    	Folder__c dragItem;
    	Folder__c dropItem;
    	
    	for (Folder__c item : folders) {
    		if(item.Id == dragId){	
    			dragItem = item;	
    		} else if(item.Id == dropId){	
    			dropItem = item;	
    		}
    		
    	}
    	
    	if (dragItem == null || dropItem == null) {
    		return;
    	}
    	
    	String folderType = dropItem.Type__c;//drag and drop item should of same type
    	
		Integer dragSequence = dragItem.Sequence__c.intValue();
		Integer dropSequence = dropItem.Sequence__c.intValue();
		
		if (dragSequence == dropSequence) { //same item, should not happen
    		return;
    	}
    	
		List<Folder__c> folderItems = [SELECT Id, Sequence__c FROM Folder__c WHERE Type__c = :folderType ORDER BY Sequence__c];
		Integer size = folderItems.size();
		
		Boolean moveUp = (dragSequence > dropSequence);
		for (Folder__c item : folderItems) {
			if (item.Id == dragItem.Id) {
				item.Sequence__c = dropSequence;
				continue;
			}
			if (moveUp) {
    			if (item.Sequence__c < dragSequence && item.Sequence__c >= dropSequence) {	
    				item.Sequence__c = item.Sequence__c + 1;
    			}
			} else {//move down
				if (item.Sequence__c > dragSequence && item.Sequence__c <= dropSequence) {	
    				item.Sequence__c = item.Sequence__c - 1;
    			}
				
			}
		}
		//TODO: fix sequence gaps, like in resequence items
		
		
		upsert folderItems;
    	
    
    }
	
    /**
     * Remote action to return all folder and tab items in JSON format 
     */
    @RemoteAction
    public static List<Folder__c> getFolders(String folderType){
    	System.debug('*** getFolders folderType=' + folderType);
         return [SELECT Id, Label__c, Type__c, Sequence__c, Logo__c
                FROM Folder__c 
                WHERE CreatedById = :UserInfo.getUserId()
                AND Type__c = :folderType   //:folderType 
                ORDER BY Sequence__c];

    }
    
    /**
     * saves folder sequence returns the latest updated folder list (no folder items) 
     */
    @RemoteAction   
    public static List<Folder__c> saveFolderSequence(String folderType, String jsonData){
    	System.debug('jsonData = ' + jsonData);
		JSONParser parser = JSON.createParser(jsonData);
		while (parser.nextToken() != null) {
		    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		        String dragId = parser.getText();
		        parser.nextToken();
		        String dropId = parser.getText();
				System.debug(dragId +' = '+ dropId);
				moveFolder((ID) dragId, (ID)dropId);
			}
		
		}
		
		return getFolders(folderType);
    	 
    }
    
    
    /**
     * Remote action to return all folder and tab items in JSON format 
     */
    @RemoteAction
    public static List<Folder__c> getFolderWithItems(String folderType){
         return [SELECT Id, Label__c, Sequence__c, Logo__c,
                    (SELECT Id, Label__c, Sequence__c, TargetUrl__c, IconUrl__c
                        FROM Items__r
                        WHERE IsDeleted__c = false 
                        ORDER BY Sequence__c) 
                FROM Folder__c 
                WHERE CreatedById = :UserInfo.getUserId()
                AND Type__c = :folderType    //:folderType
                ORDER BY Sequence__c];

    }
    
    /**
     * saves item sequence returns the latest updated list with folder items 
     */
    @RemoteAction   
    public static List<Folder__c> saveItemSequence(String folderType, String jsonData){
    	System.debug('jsonData = ' + jsonData);
    	//TODO: update sequence and item move or remove based on jsonData
    	//String str = '{"a0Ci000000NAHKJEA5": "a0Ci000000NAHKKEA5", "a0Ci000000NAHKKEA5": "a0Ci000000NAHKJEA5"}';
		JSONParser parser = JSON.createParser(jsonData);
		while (parser.nextToken() != null) {
		    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		        String dragId = parser.getText();
		        parser.nextToken();
		        String dropId = parser.getText();
				System.debug(dragId +' = '+ dropId);
				moveItem((ID) dragId, (ID)dropId);
			}
		
		}
		
		return getFolderWithItems(folderType);
    	 
    }
    
    /**
     * saves folder and returns the latest updated list
     */
    @RemoteAction   
    public static List<Folder__c> saveFolder(String folderType, String jsonData){
    	//System.debug('jsonData = ' + jsonData);
    	//jsonData = {"Logo__c":"https://na15.salesforce.com/img/seasonLogos/2015_winter_aloha.png","Sequence__c":6,"Label__c":"High Volume","Id":"a0Bi000000TzpxaEAB","$$hashKey":"object:9"}
    	
    	Map<String, String> fieldValueMap = new Map<String, String>();
		//parse json data
		JSONParser parser = JSON.createParser(jsonData);
		while (parser.nextToken() != null) {
		    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		        String fieldName = parser.getText();
		        parser.nextToken();
		        String fieldValue = parser.getText();
				fieldValueMap.put(fieldName, fieldValue);
			}
		
		}
		//create folder object
		ID folderId = fieldValueMap.get('Id');
		if (folderId != null) {
			Folder__c folder = new Folder__c(Id = FolderId, Label__c = fieldValueMap.get('Label__c'));
			update folder;
			
		} else {
			//TODO get max folder sequence, get default folder icon
			Integer seq = [SELECT COUNT() FROM Folder__c WHERE Type__c =:folderType AND CreatedById = :UserInfo.getUserId()];
			seq = seq + 1;
			Folder__c folder = new Folder__c(Id = FolderId, Label__c = fieldValueMap.get('Label__c'), 
											Type__c = fieldValueMap.get('Type__c'), Sequence__c = seq);
			insert folder;
		}
		
		return getFolders(folderType);
    	 
    }
    
    /**
     * deletes folder returns the latest list
     */
    @RemoteAction   
    public static List<Folder__c> deleteFolder(String folderType, String jsonData){
    	Map<String, String> fieldValueMap = new Map<String, String>();
		//parse json data
		JSONParser parser = JSON.createParser(jsonData);
		while (parser.nextToken() != null) {
		    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
		        String fieldName = parser.getText();
		        parser.nextToken();
		        String fieldValue = parser.getText();
				fieldValueMap.put(fieldName, fieldValue);
			}
		
		}
		//create folder object
		ID folderId = fieldValueMap.get('Id');
		if (folderId != null) {
			if (folderType == 'Bookmark') {
				delete [SELECT Id FROM Folder__c WHERE Id = :folderId];
				
			} else {//mark ap folder as deleted instead of deleting it completely, so that during synch they stay the same
				Folder__c folder = new Folder__c(Id = FolderId, IsDeleted__c = true);
				upsert folder;
				
			}
			
		}
		 
		
		//resequence folder
		resequenceFolder(folderType);
		
		return getFolders(folderType);
    	 
    }
    
    /** 
	 * resequence
	 */   
    private static void resequenceFolder(String folderType) {
    	Integer seq = 1;
    	List<Folder__c> folders = [SELECT Id, Sequence__c FROM Folder__c 
    								WHERE Type__c =:folderType AND CreatedById = :UserInfo.getUserId() 
    								Order By Sequence__c];
    								
   		for (Folder__c folder : folders) {
  			folder.Sequence__c = seq++;
	    		
   		}
   		upsert folders;
    	
    }
    
    
  
}