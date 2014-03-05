package gadget.dao
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.states.OverrideBase;
	
	public class SubSyncDAO extends SimpleTable {
		
		private var stmtSelectAll:SQLStatement = null;
		private var stmtFind:SQLStatement = null;
		private var stmtFindEnabled:SQLStatement = null;
		private var stmtFindByEntity:SQLStatement = null;
		private var stmtUpdate:SQLStatement = null;
		private var stmtUpdateAllByEnity:SQLStatement = null;
		
		public function SubSyncDAO(sqlConnection:SQLConnection, workerFunction:Function)
		{
			
			super(sqlConnection, workerFunction, {
				table:"subsync",
				index: [ 'entity', 'sub' ],
				columns: { 'TEXT' : textColumns ,'BOOLEAN' : ['enabled']}
			});
			stmtSelectAll = new SQLStatement();
			stmtSelectAll.sqlConnection = sqlConnection;
			stmtSelectAll.text ="select * from subsync order by num";
			
			stmtFind = new SQLStatement();
			stmtFind.sqlConnection = sqlConnection;
			stmtFind.text = "SELECT * FROM subsync WHERE entity = :entity AND sub = :sub";
			
			stmtFindEnabled = new SQLStatement();
			stmtFindEnabled.sqlConnection = sqlConnection;
			stmtFindEnabled.text = "SELECT * FROM subsync WHERE entity = :entity AND enabled = 1";
		
			stmtFindByEntity = new SQLStatement();
			stmtFindByEntity.sqlConnection = sqlConnection;
			stmtFindByEntity.text = "SELECT * FROM subsync WHERE entity = :entity";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE subsync SET enabled = :enabled" + 
							" WHERE entity = :entity AND sub = :sub";
			
			stmtUpdateAllByEnity = new SQLStatement();
			stmtUpdateAllByEnity.sqlConnection = sqlConnection;
			stmtUpdateAllByEnity.text = "UPDATE subsync SET enabled = :enabled" + 
				" WHERE entity = :entity";
		}
		
		public function selectAll():ArrayCollection{
			exec(stmtSelectAll);
			return new ArrayCollection(stmtSelectAll.getResult().data);
		}
		
		public function _delete(data:Object):void {
			delete_({entity: data.entity, column_name: data.column_name});
		}
		
		public function findDepthStructure(where:String):ArrayCollection {
			return new ArrayCollection(select_order("*", where, null, "num", null));
		}
		
		public function find(entity:String,sub:String):Object{
			stmtFind.parameters[":entity"] = entity;
			stmtFind.parameters[":sub"] = sub;
			exec(stmtFind);
			var result:SQLResult = stmtFind.getResult();
			if(result.data==null || result.data.length==0) return null;
			return result.data[0];
		}
		
		public function findByEntity(entity:String):Array{
			stmtFindByEntity.parameters[":entity"] = entity;
			exec(stmtFindByEntity);
			var result:SQLResult = stmtFindByEntity.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		public function updateEnabled(obj:Object):void{
			stmtUpdate.parameters[":entity"] = obj.entity;
			stmtUpdate.parameters[":sub"] = obj.sub;
			stmtUpdate.parameters[":enabled"] = obj.enabled;
			exec(stmtUpdate);
		}
		
		public function updateEnabledAll(entity:String,enabled:int):void{
			stmtUpdateAllByEnity.parameters[":entity"] = entity;
			stmtUpdateAllByEnity.parameters[":enabled"] = enabled;
			exec(stmtUpdateAllByEnity);
		}
		
		public function listSubEnabledTransaction(entity:String):Array{
			stmtFindEnabled.parameters[":entity"] = entity;
			exec(stmtFindEnabled);
			var result:SQLResult = stmtFindEnabled.getResult();
			if(result.data==null || result.data.length==0) return new Array();
			return result.data;
		}
		
		override public function insert(data:Object):SimpleTable {
			
			return super.insert(data);
		}
		
	
		private var textColumns:Array = [
			"entity",
			"sub",
			"sodname"
			
		];
		
	}
}