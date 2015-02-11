/**
 * BetterSideClr a controller class for BetterSide page
 * @author ddas
 * @copyright DistinctData Inc.
 */
public with sharing class FolderSyncUtil {
	
	private static final String FOLDER_TYPE_APP = 'App';
	private static final String FOLDER_TYPE_BOOKMARK = 'Bookmark';

	/**
	 * create folders from app 
	 */
	public static void createAppFolders(){
		List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
		Integer seq = 1;
		List<Folder__c> folders = new List<Folder__c>();
		for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
			
		    // Get more information for the Sales app
		    Folder__c folder = new Folder__c();
		    folder.Label__c = tsr.getLabel();
		    folder.Type__c = FOLDER_TYPE_APP;
		    folder.Logo__c = tsr.getLogoUrl();
		    folder.Sequence__c = seq++;
		    folders.add(folder);
		    
		}
		
		insert folders;
		
		//now create the tab items for each folder
		createTabItems();
		
	}
	
	/**
	 * create folders from app 
	 */
	public static void createBookmarkFolder(String label) {
		Integer lastSeq = 1;
		for (AggregateResult res :[SELECT MAX(Sequence__c) MAX_SEQ FROM Folder__c WHERE CreatedById = :UserInfo.getUserId()]) {
			lastSeq = Integer.valueOf(res.get('MAX_SEQ'));
			
		}
		Folder__c folder = new Folder__c();
		folder.Label__c = label;
	    folder.Type__c = FOLDER_TYPE_BOOKMARK;
	    folder.Logo__c = null;
	    folder.Sequence__c = lastSeq + 1;
	    
		insert folder;
		
	}
	
	
	/**
	 * create Folder Item from tabs in apps
	 */
	private static void createTabItems(){
		List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
		
		List<Folder__c> folders = [SELECT Id, Label__c FROM Folder__c WHERE CreatedById = :UserInfo.getUserId()];
		Map<String, Folder__c> folderMap = new Map<String, Folder__c>();
		for(Folder__c folder : folders){
		    folderMap.put(folder.Label__c, folder);
		    
		}
		List<Item__c> items = new List<Item__c>();
		for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
		    // Get more information for the Sales app
		    Folder__c folder = folderMap.get(tsr.getLabel());
		    Integer seq = 1;
		    for(Schema.DescribeTabResult tab : tsr.getTabs()){
		        Item__c item = new Item__c(folderId__c = folder.Id);
		        item.TargetUrl__c = tab.getUrl();
		        item.IconUrl__c = tab.getMiniIconUrl();
		        item.Label__c = tab.getLabel();
		        item.Sequence__c = seq++;
		        items.add(item);
		    }                                             
		    
		}
		insert items;
	
	}


}