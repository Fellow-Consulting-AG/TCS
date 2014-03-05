// semi-automatically generated from CRMODLS_ModificationLog.wsdl
package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;

	public class ModificationTrackingDAO extends BaseDAO {

		
		private var stmtProcess:SQLStatement;
		
		public function ModificationTrackingDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'sod_modificationtracking',
				oracle_id: 'Id',
				name_column: [ 'Id' ],	//___EDIT__THIS___
				search_columns: [ 'Id' ],
				display_name : "ModificationTracking",	//___EDIT__THIS___
				index: [ 'Id' ],
				columns: { 'TEXT' : textColumns }
			});
			
			// statement for setting the processed field
			stmtProcess = new SQLStatement();
			stmtProcess.sqlConnection = sqlConnection;
			stmtProcess.text = "UPDATE sod_modificationtracking SET processed = 1 WHERE processed IS NULL AND ObjectName = :ObjectName AND ObjectId = :ObjectId";	
		}

		override public function get entity():String {
			return "ModificationTracking";
		}
		
		private var textColumns:Array = [
			"ChildId",
			"ChildName",
			"CreatedBy",
			"CreatedByAlias",
			"CreatedByEMailAddr",
			"CreatedByExternalSystemId",
			"CreatedByFirstName",
			"CreatedByFullName",
			"CreatedById",
			"CreatedByIntegrationId",
			"CreatedByLastName",
			"CreatedByUserSignInId",
			"CreatedDate",
			"EventName",
			"ExternalSystemId",
			"Id",
			"ModId",
			"ModificationNumber",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",
			"ObjectId",
			"ObjectName",
			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			];
		
		public function process(objectName:String, objectId:String):void {
			stmtProcess.parameters[':ObjectName'] = objectName;
			stmtProcess.parameters[':ObjectId'] = objectId;
			exec(stmtProcess);
		}
	}
}
