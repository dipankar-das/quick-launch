public abstract with sharing class FolderItemSupport {
	
	public static final String ITEM_TYPE_BOOKMARK = 'Bookmark';
	public static final String ITEM_TYPE_RECENT = 'Recent';
	

    public static void addFolder(){
    
    
    }
    
    /**
     * return app folder map
     */
    public static Map<Id, Folder__c> getAppFolderWithSequence(){
        Map<Id, Folder__c> folderMap = new Map<Id, Folder__c>();
        
        for(Folder__c folder : [SELECT Id, Label__c, Sequence__c, Logo__c,
                                    (SELECT Id, Label__c, Sequence__c, TargetUrl__c, IconUrl__c
                                        FROM Items__r 
                                        ORDER BY Sequence__c) 
                                        FROM Folder__c 
                                        WHERE CreatedById = :UserInfo.getUserId()
                                        AND Type__c = 'App'    
                                        ORDER BY Sequence__c]){
             folderMap.put(folder.Id, folder);
            
         }
         //for(Folder__c folder: folderMap.values()) { System.debug('*************** Current folers: ' + folder.Label__c + 'ID is '+ folder.ID + 'Sequence is '+ folder.Sequence__c ); }
         return folderMap;       
    
    }
    
    /**
     * update sequence of folder and item
     */
    public static void updateSequence(Map<Id, Folder__c> folderMap){
        
        List<Folder__c> folders = folderMap.values();
        System.debug('List starts....');
       System.debug(',,,,,,,, '+folders ); 
        upsert folders; //updates folder sequence
        
        List<Item__c> items = new List<Item__c>();
        //move items from one folder to another.
        for(Folder__c folder : folderMap.values()) {
            for(Item__c item : folder.Items__r){
                items.add(item);
            }
        
        }    
        
        upsert items;
    
    }
    
    /**
     * adds the most recent item to default bookmark folder if it is not aleardy added
     */
    public static List<Item__c> addRecentItemsToBookmark() {
    	//get recent items(latest 20)
    	List<RecentlyViewed> recentList = RecentItemSupport.getLatestRecentObjects();
    	Map<Id, RecentlyViewed> recentMap = new Map<Id, RecentlyViewed>(recentList);
    	
    	//find the ones that are not yet added
    	Set<ID> addedIds = new Set<ID>();
    	for (Item__c item : [SELECT TargetUrl__c 
    							FROM Item__c 
    							WHERE TargetUrl__c IN :recentMap.keySet()]) {
    		addedIds.add(ID.valueOf(item.TargetUrl__c));							
		}
    	
    	Set<ID> notAddedIds = new Set<ID>();
    	for(Id id : recentMap.keySet()){
    	 	if (!addedIds.contains(id)) {
    	 		notAddedIds.add(id);
    	 	}
    	}
    	
    	//folder items
    	Folder__c folder = getDefaultFolder();
    	List<Item__c> folderItems = new List<Item__c>(); 
    	for (RecentlyViewed recent : recentList) {
    		if (recent.Type == 'ListView') {
    			continue;
    		}
    		if (notAddedIds.contains(recent.Id)) {
    			folderItems.add(createRecentBookmarkItem(recent, folder.Id));
    			
    		}
    		
    	}
    	
    	insert folderItems;
    	
    	return folderItems;
    	
    }
    
    /**
     * add a recent folder item to default folder
     */
    private static Item__c createRecentBookmarkItem(RecentlyViewed recent, ID defaultFolderId){
        Item__c itemSO = new Item__c(FolderId__c = defaultFolderId, Label__c = recent.Name);
        itemSO.TargetUrl__c = recent.Id;
        itemSO.Sequence__c = 1;
        itemSO.Type__c = ITEM_TYPE_RECENT;
        return itemSO;
    
    }
    
    /**
     * returns the default bookmark folder
     */
    public static Folder__c getDefaultFolder(){
        List<Folder__c> folders = [SELECT Id, Type__c FROM Folder__c 
                                    WHERE CreatedById = :UserInfo.getUserId() 
                                    AND Type__c = :ITEM_TYPE_BOOKMARK
                                    AND IsDefault__c = TRUE
                                    LIMIT 1];
    	
    	//when default is not defined use the first folder
    	if (folders.size() == 0) {
    		folders = [SELECT Id, Type__c FROM Folder__c 
                        WHERE CreatedById = :UserInfo.getUserId() 
                        AND Type__c = :ITEM_TYPE_BOOKMARK
                        ORDER BY Sequence__c LIMIT 1];
    	}
    		
        return folders[0];     
    
    }



}