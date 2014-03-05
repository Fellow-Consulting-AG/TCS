package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	public class CustomRecordTypeTranslationsDAO extends SimpleTable {
	
		private var stmtSelectOne:SQLStatement ;
		public function CustomRecordTypeTranslationsDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				table: "custom_record_type_trans",
				unique: [ "CustomRecordTypeServiceName, LanguageCode" ],
				index: [],
				create_cb: function(structure:Object):void {Database.incomingSyncDao.unsync_one("CustomRecordTypeService")} // refetch the parent!
			});
			stmtSelectOne=new SQLStatement();
			stmtSelectOne.sqlConnection=sqlConnection;
			stmtSelectOne.text="select * from custom_record_type_trans where CustomRecordTypeServiceName=:entity and LanguageCode=:lang";
		}
		
		public function selectCustomRecordTypeByEntity(entity:String,langcode:String="ENG"):Object{

			stmtSelectOne.parameters[":entity"]=entity;
			stmtSelectOne.parameters[":lang"]=langcode;
			exec(stmtSelectOne);
			var result:SQLResult=stmtSelectOne.getResult();
			if(result!=null){
				var data:Array=result.data;
				if(data!=null && data.length>0){
					return data[0];
				}
			}
			return null;
		}

		public function delete_one(name:String):void {
			del(null,{name:name});
		}
		
		override public function getColumns():Array {
			return [
				'CustomRecordTypeServiceName',
				'LanguageCode',
				'SingularName',
				'PluralName',
				'ShortName',
			];
		}
	}
}
