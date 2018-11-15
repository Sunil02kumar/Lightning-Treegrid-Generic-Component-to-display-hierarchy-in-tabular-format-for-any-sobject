public class SK_GenericTreeGridController {
    
    @AuraEnabled
    public static dataWrapper findHierarchyData(string recId,string parentFieldAPIName,
                                                string objectAPIname,List<string> columnLabelList,
                                                List<string> fieldAPINameList,string hyperlinkColumn){
        dataWrapper returnData = new dataWrapper();
		try{
            if(fieldAPINameList.size()>0 && columnLabelList.size()>0 && columnLabelList.size()==fieldAPINameList.size()){
                integer indexCount=0;
                List<columnsHeaderWrapper> headerdata = new List<columnsHeaderWrapper>();
                for(string ss : fieldAPINameList){
                    if(ss != null && ss != ''){
                        columnsHeaderWrapper headerinfo= new columnsHeaderWrapper();
                        if(ss.equalsignorecase(hyperlinkColumn)){
                        	headerinfo.type='url';
                        	headerinfo.fieldName='RecordURL';
                        	headerInfo.label=columnLabelList[indexCount]; 
                            headerInfo.typeAttributes.label.fieldName=ss;
                        }else{
                        	headerinfo.type='text';
                        	headerinfo.fieldName=ss;
                        	headerInfo.label=columnLabelList[indexCount];    
                        }
                        
                        headerdata.add(headerInfo);
                    }
                    indexCount++;
                }
                returnData.headerList =headerdata;
            }
			string queryString = 'select id,ParentId ,'+string.join(fieldAPINameList,',')+' from '+objectAPIname;
			//Section to get all child account details from ultimate parent starts-------------------------
			List<String> currentParent      = new List<String>{};
				Integer level               = 0;
			Boolean endOfStructure      = false;
			//method to find ultimate parent of account
			string topMostparent = GetUltimateParentId(recId,objectAPIname,parentFieldAPIName );
			system.debug('*******topMostparent:'+topMostparent);
			currentParent.add(topMostparent);
			system.debug('**********topMostparent:'+ currentParent);
			//Loop though all children
			string finalQueryString = '';
			List<sObject>  queryOutput = new List<sObject> ();
			while ( !endOfStructure ){  
				if( level == 0 ){
					finalQueryString = queryString + ' where id IN : CurrentParent ORDER BY '+parentFieldAPIName+' Limit 1000';
				} 
				else {
					finalQueryString = queryString + ' where '+parentFieldAPIName+' IN : CurrentParent ORDER BY '+parentFieldAPIName+' Limit 1000';
				}
				system.debug('********finalQueryString:'+finalQueryString);
				if(finalQueryString != null && finalQueryString !=''){
					try{
						if(Limits.getLimitQueries()-Limits.getQueries()>0){
							queryOutput = database.query(finalQueryString);
							system.debug('***hierarchy level:'+level);
						}else{
							system.debug('****endOfStructure is true as SOQL limit reaches:');
							endOfStructure = true;
						}
					}catch(exception ex){ 
						endOfStructure = true;
					}
				}
				system.debug('**queryOutput size:'+queryOutput);
				if( queryOutput.size() == 0 ){
					endOfStructure = true;
				}
				else{
					currentParent.clear();
					//iterating through query output
					for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
						string recordId= string.valueof(queryOutput[i].get('Id'));
						currentParent.add(recordId);
						returnData.recordList.add(queryOutput[i]);
					}
				}
				level++;
			}
			system.debug('**********returnData.recordList:'+returnData.recordList);
			system.debug('**********returnData.headerList:'+returnData.headerList);
			
		}catch(exception ex){
			system.debug('***exception:'+ex.getMessage());
		}                                            
		return returnData;
	}
    
    // Find the tom most element in Heirarchy  
     public static String GetUltimateParentId( string recId, string sObjectName, string parentFieldAPIname ){
        Boolean top = false;
        while ( !top ) {
            string queryString = 'select id , ' +parentFieldAPIname+ ' from '+sObjectName + ' where Id =:recId LIMIT 1';
            system.debug('**********queryString GetUltimateParentId:'+queryString);
            sobject sb = database.query(queryString);
            
            if ( sb.get(parentFieldAPIname) != null ) {
                recId = string.valueof(sb.get(parentFieldAPIname));
            }else {
                top = true;
            }
        }
        return recId ;
    }
    
    public class dataWrapper{
        @AuraEnabled
        public List<columnsHeaderWrapper> headerList;
        @AuraEnabled
        public List<sObject> recordList;
        public dataWrapper(){
            recordList=new List<sObject>();
            headerList=new List<columnsHeaderWrapper>();
        }
    }
    public class columnsHeaderWrapper{
        @AuraEnabled
        public string type;
        @AuraEnabled
        public string fieldName;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public TypeAttributes typeAttributes;
        public columnsHeaderWrapper(){
            typeAttributes=new TypeAttributes();
        }
    }
    public class TypeAttributes {
        @AuraEnabled
		public Label label; 
        public TypeAttributes(){
            label=new Label();
        }
	}
	public class Label {
        @AuraEnabled
		public String fieldName ;
	}
    
}