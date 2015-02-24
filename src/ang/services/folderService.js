(function(){
    var FolderService = function ($q, PageService) {
    	var folders = {};
    	
    	this.record = {folder: {}, mode: 'new', folderType: 'App'};
    	
    	//add folder 
    	this.saveFolder = function (folderType, folder) {
    		console.log('saveFolder-->' + folder);
        	var deferred = $q.defer();
        	Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.saveFolder, folderType, folder, function(result, event) {
        	    try {
                    console.log('<--saveFolderSequence  status = '+ event.status);
                    if (event.status) {
                    	folders[folderType] = result;
    	                deferred.resolve(folders[folderType]);
    	                
    				} else {
    					deferred.reject(event);
    				}
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
            );
    		 
    		return deferred.promise;
    		
        }
    	
    	//delete folder
    	this.deleteFolder = function (folderType, folder) {
        	var deferred = $q.defer();
        	Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.deleteFolder, folderType, folder, function(result, event) {
        	    try {
                    console.log('<--saveFolderSequence  status = '+ event.status);
                    if (event.status) {
                    	folders[folderType] = result;
    	                deferred.resolve(folders[folderType]);
    	                
    				} else {
    					deferred.reject(event);
    				}
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
            );
    		 
    		return deferred.promise;
    		
        }
    	
    	//save folder item sequence
    	this.saveFolderSequence = function (folderType, modifiedItems) {
        	var deferred = $q.defer();
        	Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.saveFolderSequence, folderType, modifiedItems, function(result, event) {
        	    try {
                    console.log('<--saveFolderSequence  status = '+ event.status);
                    if (event.status) {
                    	folders[folderType] = result;
    	                deferred.resolve(folders[folderType]);
    	                
    				} else {
    					deferred.reject(event);
    				}
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
            );
    		 
    		return deferred.promise;
    		
        }
    	
    	//reset list, so that it is reloaded
    	this.reset = function () {
    		folders = undefined;
    	}
    	
    	//load folders
    	this.getFolders = function (folderType) {
    		if (folders[folderType]) {
    			return $q.when(folders[folderType]);
    		}

        	var deferred = $q.defer();

        	Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.getFolders, folderType, function(result, event) {
    	    	try {
                    console.log('<--getFolders status = '+ event.status);
                    if (event.status) {
                    	folders[folderType] = result;
    	                deferred.resolve(folders[folderType]);
    	                
    				} else {
    					deferred.reject(event);
    				}
    				//$rootScope.$broadcast('datarecieved');
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
             );
    		
    		return deferred.promise;
    		
    	};
    	    
    };
    
    FolderService.$inject = ['$q', 'PageService'];    

    angular.module('mainApp').service('FolderService', FolderService);
    
}());