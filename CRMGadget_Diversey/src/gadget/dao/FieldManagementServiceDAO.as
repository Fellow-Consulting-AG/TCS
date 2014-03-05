// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	public class FieldManagementServiceDAO extends SimpleTable {
		
		public function FieldManagementServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table:"field_management",
				unique: [ 'entity, Name' ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("FieldManagementService")}
			});
		}
		
		public function delete_one(name:String):void {
			del(null,{name:name});
			Database.fieldTranslationDataDao.delete_one(name);
		}
		
		public function getDefaultFieldValue(entity:String, displayName:String):Array{
			var where:String = " Where entity='" + entity + "' and (DisplayName='" + displayName + "' or Name='" + displayName + "')";
			return select_order("*", where, null, "DisplayName",null);
		}
		
		public function readAll(entity:String):Array{
			var where:String = " Where entity='" + entity + "'";
			return select_order("*", where, null, "DisplayName",null);
		}
		
		override public function delete_all():void {
			del(null);
			Database.fieldTranslationDataDao.delete_all();
		}

		override public function getColumns():Array {
			return [
				'entity',
				'Name',
				'DefaultValue',
				'DisplayName',
				'FieldType',
				'FieldValidation',
				'IntegrationTag',
				'PostDefault',
				'ReadOnly',
				'Required',
				'ValidationErrorMsg'
			];
		}
	}
}
