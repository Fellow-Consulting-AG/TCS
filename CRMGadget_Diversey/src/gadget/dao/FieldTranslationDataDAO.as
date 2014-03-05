// Keep the synced ranges in the database

package gadget.dao
{
	import flash.data.SQLConnection;
	
	public class FieldTranslationDataDAO extends SimpleTable {
		
		public function FieldTranslationDataDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "field_translation",
				unique: [ 'entity, Name, LanguageCode' ],
				index:[]
			});
		}
		
		public function delete_one(name:String):void {
			del(null,{name:name});
		}
		
		override public function getColumns():Array {
			return [
				'entity',
				'Name',
				'LanguageCode',
				'DisplayName',
				'ValidationErrorMsg'
			];
		}
		public function readAll(entity:String):Array{
			var where:String = " Where entity='" + entity + "'";
			return select_order("*", where, null, "DisplayName",null);
		}
		

	}
}
