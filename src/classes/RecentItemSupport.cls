/**
 * RecentItemSupport a support class to handle RecentItems
 * @author ddas
 * @copyright DistinctData Inc.
 */
public abstract with sharing class RecentItemSupport {

    /**
     * returns recently viewed objects
     */
    public static List<RecentlyViewed> getRecentObjects(){
        List<ID> recentIds = new List<ID>();
        for(RecentlyViewed viewed : [SELECT Id FROM RecentlyViewed 
                                        ORDER BY LastViewedDate
                                        LIMIT 200]) {
             recentIds.add(viewed.Id);
        }

        List<ID> readIds = new List<ID>();
        for(UserRecordAccess userAccess : [SELECT RecordId 
                                            FROM UserRecordAccess 
                                            WHERE HasEditAccess = true 
                                                AND UserId = :UserInfo.getUserId() 
                                                AND RecordId IN :recentIds]) { 
              readIds.add(userAccess.RecordId);
              
        }


        List<RecentlyViewed> recentItems = [SELECT Id, Name, type, IsActive, LastViewedDate 
                                                FROM RecentlyViewed 
                                                WHERE Id IN :readIds                
                                                //ORDER BY Type, LastViewedDate];
                                                ORDER BY LastViewedDate];
                    
        return recentItems;            
    }

    /**
     * returns recently viewed objects
     */
    public static List<RecentlyViewed> getLatestRecentObjects(){
        List<ID> recentIds = new List<ID>();
        for(RecentlyViewed viewed : [SELECT Id FROM RecentlyViewed 
                                        ORDER BY LastViewedDate
                                        LIMIT 200]) {
             recentIds.add(viewed.Id);
        }

        List<ID> readIds = new List<ID>();
        for(UserRecordAccess userAccess : [SELECT RecordId 
                                            FROM UserRecordAccess 
                                            WHERE HasEditAccess = true 
                                                AND UserId = :UserInfo.getUserId() 
                                                AND RecordId IN :recentIds]) { 
              readIds.add(userAccess.RecordId);
              
        }

        List<RecentlyViewed> recentItems = [SELECT Id, Name, type, IsActive, LastViewedDate 
                                                FROM RecentlyViewed 
                                                WHERE Id IN :readIds                
                                                ORDER BY LastViewedDate
                                                LIMIT 200];
                    
        return recentItems;            
    }


}