package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.CacheUtils;
	
	import mx.collections.ArrayCollection;
	
	public class FilterDAO extends BaseSQL {
		private var stmtListColumns:SQLStatement;
		private var stmtListFilters:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtList:SQLStatement;
		private var stmtExists:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		
		private var stmtListDefaultFilters:SQLStatement;
		private var stmtListDashboardFilters:SQLStatement;
		private var stmtDefaultFilter:SQLStatement;
		private var stmtFindFilter:SQLStatement;
		private var stmtIncreaseType:SQLStatement;
		
		public function FilterDAO(sqlConnection:SQLConnection) {
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO filter (name, entity, predefined, type) VALUES (:name, :entity, :predefined, :type)";
			
			stmtListFilters = new SQLStatement();
			stmtListFilters.sqlConnection = sqlConnection;
			stmtListFilters.text = "SELECT * FROM filter WHERE entity = :entity ORDER BY predefined desc, type desc";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE filter SET name = :name, entity = :entity, predefined = :predefined, type = :type WHERE id = :id";
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM filter WHERE id = :id";	
			
			stmtList = new SQLStatement();
			stmtList.sqlConnection = sqlConnection;
			stmtList.text = "SELECT * FROM filter";
			
			stmtExists = new SQLStatement();
			stmtExists.sqlConnection = sqlConnection;
			stmtExists.text = "SELECT * FROM filter WHERE name = :name";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = "DELETE FROM filter";
			
			stmtListDefaultFilters = new SQLStatement();
			stmtListDefaultFilters.sqlConnection = sqlConnection;
			stmtListDefaultFilters.text = "SELECT * FROM filter WHERE predefined = 1";
			
			stmtListDashboardFilters = new SQLStatement();
			stmtListDashboardFilters.sqlConnection = sqlConnection;
			stmtListDashboardFilters.text = "SELECT * FROM filter WHERE entity = :entity AND predefined = 0";
			
			stmtDefaultFilter = new SQLStatement();
			stmtDefaultFilter.sqlConnection = sqlConnection;
			stmtDefaultFilter.text = "SELECT * FROM filter WHERE entity = :entity AND type = :type";
			
			stmtFindFilter = new SQLStatement();
			stmtFindFilter.sqlConnection = sqlConnection;
			stmtFindFilter.text = "SELECT * FROM filter WHERE id = :id";
			
			stmtIncreaseType = new SQLStatement();
			stmtIncreaseType.sqlConnection = sqlConnection;
			stmtIncreaseType.text = "SELECT MAX(type) AS type FROM filter WHERE entity = :entity";
			
		}
		
		public function insert(filter:Object):Number {
			stmtInsert.parameters[":name"] = filter.name;
			stmtInsert.parameters[":entity"] = filter.entity;
			stmtInsert.parameters[":predefined"] = filter.predefined;
			stmtInsert.parameters[":type"] = filter.type;
			//			stmtInsert.parameters[":bookmarked"] = filter.bookmarked;
			exec(stmtInsert);
			return stmtInsert.getResult().lastInsertRowID;
		}
		
		public function update(filter:Object):void {
			
			var cache:CacheUtils = new CacheUtils("Filter_DAO");
			var key:String = filter.entity + "_" + filter.type;
			cache.set(key, filter);
			
			stmtUpdate.parameters[":id"] = filter.id;
			stmtUpdate.parameters[":name"] = filter.name;
			stmtUpdate.parameters[":entity"] = filter.entity;
			stmtUpdate.parameters[":predefined"] = filter.predefined;
			stmtUpdate.parameters[":type"] = filter.type;
			//			stmtUpdate.parameters[":bookmarked"] = filter.bookmarked;
			exec(stmtUpdate);
		}
		
		public function delete_(filter:Object):void	{
			var cache:CacheUtils = new CacheUtils("Filter_DAO");
			var key:String = filter.entity + "_" + filter.type;
			cache.del(key);
			
			stmtDelete.parameters[":id"] = filter.id;
			exec(stmtDelete);
		}
		
//		public function listFilters(entity:String):ArrayCollection {
//			var filters:ArrayCollection = new ArrayCollection();
//			for each(var objectFilter:Object in listFiltersCriteria(entity)){
//				var object:Object = new Object();
//				object.name = objectFilter.name;
//				object.id = objectFilter.type;
//				object.entity = objectFilter.entity;
//				filters.addItem(object);
//			}
//			return filters;
//		}
		
		public function listFiltersCriteria(entity:String):ArrayCollection{
			stmtListFilters.parameters[":entity"] = entity;
			exec(stmtListFilters);
			return new ArrayCollection(stmtListFilters.getResult().data);
		}
		
		
		public function listFilters():Array {
			exec(stmtList);
			return stmtList.getResult().data;
		}
		
		public function exists(name:String):Boolean {
			stmtExists.parameters[":name"] = name;
			exec(stmtExists);
			return stmtExists.getResult().data != null;
		}
		
		public function deleteAll():void{
			exec(stmtDeleteAll);
		}
		
		public function listDefaultFilters():ArrayCollection{
			exec(stmtListDefaultFilters);
			return new ArrayCollection(stmtListDefaultFilters.getResult().data);
		}
		
		public function listDashboardFilters(entity:String):ArrayCollection {
			stmtListDashboardFilters.parameters[":entity"] = entity;
			exec(stmtListDashboardFilters);
			var listDashboard:ArrayCollection = new ArrayCollection(stmtListDashboardFilters.getResult().data);
			listDashboard.addItemAt({id: "", enitty: "", name: "", predefined: "", type: ""}, 0);
			return listDashboard;
		}
		
		public function getObjectFilter(entity:String, type:int):Object{
			var cache:CacheUtils = new CacheUtils("Filter_DAO");
			var key:String = entity + "_" + type;
			var objectFilter:Object = cache.get(key);
			if(objectFilter == null){
				stmtDefaultFilter.parameters[":entity"] = entity;
				stmtDefaultFilter.parameters[":type"] = type;
				exec(stmtDefaultFilter);
				var result:SQLResult = stmtDefaultFilter.getResult();
				if(result.data == null || result.data.length==0){
					return null;
				}
				objectFilter = result.data[0];
				cache.set(key, objectFilter);
			}
			return objectFilter;
		}
		
		public function findFilter(id:String):Object{
			stmtFindFilter.parameters[":id"] = id;
			exec(stmtFindFilter);
			var result:SQLResult = stmtFindFilter.getResult();
			if(result.data==null || result.data.length==0){
				return null;
			}
			return result.data[0];
		}
		
		public function increaseType(entity:String):int{
			stmtIncreaseType.parameters[":entity"] = entity;
			exec(stmtIncreaseType);
			return stmtIncreaseType.getResult().data[0].type + 1;
		}
		
	}
}
