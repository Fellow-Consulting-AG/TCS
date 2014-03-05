package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	public class CustomRecordTypeServiceDAO extends SimpleTable {
	
		public function CustomRecordTypeServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "custom_record_type",
				unique: [ 'Name' ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("CustomRecordTypeService")}
			});
		}
		
		public function delete_one(name:String):void {
			del(null,{name:name});
			Database.customRecordTypeTranslationsDao.delete_one(name);
		}

		override public function delete_all():void {
			del(null);
			Database.customRecordTypeTranslationsDao.delete_all();
		}
		
		override public function getColumns():Array {
			return [
				'Name', 
				'SingularName', 
				'PluralName', 
				'ShortName', 
				'IconName',
			];
		}
	}
}
