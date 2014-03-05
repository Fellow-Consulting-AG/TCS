package gadget.dao
{
	import com.hurlant.util.der.Integer;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.TableFactory;
	
	import mx.collections.ArrayCollection;
	
	public class LastSyncDAO extends BaseSQL {
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtSelect:SQLStatement;
		private var stmtLastSync:SQLStatement;
		private var stmtUpdateStart:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtDeleteAll:SQLStatement;
		private var stmtLastSyncDate:SQLStatement;
		private var stmtCountLastSyncDate:SQLStatement;
		
		public function LastSyncDAO(sqlConnection:SQLConnection, work:Function) {
			
			var self:LastSyncDAO = this;
			
			// NO, THIS IS NOT YET THE RIGHT THING
			// But this hack is needed to get the app started
			TableFactory.create(work, sqlConnection, {
				table: "last_sync",
				index: [ 'task_name' ],
				columns: {
					task_name:"TEXT",
					sync_date:"TEXT",
					start_row:"int",
					start_id:"TEXT"
				}
			});
			
			
			stmtCountLastSyncDate = new SQLStatement();
			stmtCountLastSyncDate.sqlConnection = sqlConnection;
			stmtCountLastSyncDate.text = "Select count(*) from last_sync";

			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			stmtInsert.text = "INSERT INTO last_sync (task_name, sync_date, start_row, start_id) VALUES (:task_name, :sync_date, :start_row, :start_id)";
			
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
			stmtUpdate.text = "UPDATE last_sync SET sync_date = :sync_date, start_row = :start_row, start_id = :start_id WHERE task_name = :task_name";
			
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			stmtSelect.text = "SELECT * FROM last_sync WHERE task_name = :task_name";
			
			stmtLastSync = new SQLStatement();
			stmtLastSync.sqlConnection = sqlConnection;
			// check only administration tasks
			stmtLastSync.text = "SELECT * FROM last_sync WHERE task_name not like 'gadget.sync.tests::%'" +
				" AND task_name not like 'gadget.sync.incoming::IncomingObject%'" +
				" AND task_name not like 'gadget.sync.outgoing::Outgoing%'";
			
			stmtUpdateStart = new SQLStatement();
			stmtUpdateStart.sqlConnection = sqlConnection;
			stmtUpdateStart.text = 'UPDATE last_sync SET start_row = :start_row, start_id = :start_id WHERE task_name = :task_name';
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			//VAHI this ugly statment is my creation:
			stmtDelete.text = "DELETE from last_sync WHERE upper(task_name) like '%'||upper(:task_name)";
			
			stmtDeleteAll = new SQLStatement();
			stmtDeleteAll.sqlConnection = sqlConnection;
			stmtDeleteAll.text = 'DELETE from last_sync';
			
			stmtLastSyncDate = new SQLStatement();
			stmtLastSyncDate.sqlConnection = sqlConnection;
			stmtLastSyncDate.text = "SELECT * FROM last_sync WHERE task_name NOT LIKE '%MSExchange' ORDER BY sync_date DESC LIMIT 1";
		}
		
		//VAHI see IncomingSyncDAO unsync_all!
		public function unsync_all():void {
			exec(stmtDeleteAll);
		}
		
		//VAHI see IncomingSyncDAO unsync!
		public function unsync(task_name:String):void {
			stmtDelete.parameters[':task_name'] = task_name;
			exec(stmtDelete);
		}
		
		public function insert(lastSync:Object):void {
			stmtInsert.parameters[':task_name'] = lastSync.task_name;
			stmtInsert.parameters[':sync_date'] = lastSync.sync_date;
			stmtInsert.parameters[':start_row'] = lastSync.start_row;
			stmtInsert.parameters[':start_id'] = lastSync.start_id;
			exec(stmtInsert);
		}
		
		public function update(lastSync:Object):void {
			stmtUpdate.parameters[':sync_date'] = lastSync.sync_date;
			stmtUpdate.parameters[':task_name'] = lastSync.task_name;
			stmtUpdate.parameters[':start_row'] = lastSync.start_row;
			stmtUpdate.parameters[':start_id'] = lastSync.start_id;
			exec(stmtUpdate);
		}
		
		public function replace(lastSync:Object):void {
			if (find(lastSync.task_name))
				update(lastSync);
			else
				insert(lastSync);
		}
		
		public function updateStart(lastSync:Object):void {
			stmtUpdateStart.parameters[':task_name'] = lastSync.task_name;
			stmtUpdateStart.parameters[':start_row'] = lastSync.start_row;
			stmtUpdateStart.parameters[':start_id'] = lastSync.start_id;
			exec(stmtUpdateStart);
		}
		
		public function find(task_name:String):Object{
			stmtSelect.parameters[':task_name'] = task_name;
			exec(stmtSelect);
			var sqlResult:SQLResult = stmtSelect.getResult();
			if (sqlResult.data == null || sqlResult.data.length == 0) {
				return null;
			}
			return sqlResult.data[0];
		}
		
		public function getLastSyncDate():String {
			exec(stmtLastSyncDate);
			var sqlResult:SQLResult = stmtLastSyncDate.getResult();
			if (sqlResult.data == null || sqlResult.data.length == 0) {
				return null;
			}
			return sqlResult.data[0].sync_date;
		}
		
		public function isSynced():Boolean {
			exec(stmtLastSync);
			var syncs:ArrayCollection = new ArrayCollection(stmtLastSync.getResult().data);
			if (syncs.length == 0) {
				return false;
			}
			for each (var sync:Object in syncs) {
				if (sync.sync_date == '01/01/1970 00:00:00') {
					return false;
				}
			}
			return true;
		}
		
		public function getCount():int{
			exec(stmtCountLastSyncDate);
			var sqlResult:SQLResult = stmtCountLastSyncDate.getResult();
			if (sqlResult.data == null || sqlResult.data.length <= 0) {
				return 0;
			}
			return 1;
		}
		
		
		
	}
}