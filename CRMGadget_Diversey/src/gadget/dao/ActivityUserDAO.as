package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	
	public class ActivityUserDAO extends SupportDAO {
/*		
		private var stmtInsert:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtSelect:SQLStatement;
*/		
		public function ActivityUserDAO(sqlConnection:SQLConnection, work:Function) {

			super(work, sqlConnection, {
				entity: [ 'Activity',   'User'   ],
				id:     [ 'ActivityId', 'UserId' ],
				columns: TEXTCOLUMNS
			},{
				name_column:["UserAlias"],
				search_columns:["UserAlias"]
			});

			/*
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			
			/* activityId is a gadget_id and userId is UserId /
			stmtInsert.text = "INSERT INTO activity_user (activityId, userId)" +
				" VALUES (:activityId, :userId)";
					
			stmtSelect = new SQLStatement();
			stmtSelect.sqlConnection = sqlConnection;
			
			stmtSelect.text = "SELECT * FROM activity_user au, allusers u" +
				" WHERE au.userId = u.UserId and au.activityId = :activityId ORDER BY u.uppername"; 
			
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM activity_user WHERE activityId = :activityId AND userId = :userId";
*/			
		}
/*		
		public function insert(activityUser:Object):void{
			stmtInsert.parameters[":activityId"] = activityUser.activityId;
			stmtInsert.parameters[":userId"] = activityUser.userId;
		    exec(stmtInsert);
		}
		
		public function delete_(activityUser:Object):void{
			stmtDelete.parameters[":activityId"] = activityUser.activityId;
			stmtDelete.parameters[":userId"] = activityUser.userId;
		    exec(stmtDelete);
		}
		
		public function select(activityId:String):ArrayCollection {
			stmtSelect.parameters[":activityId"] = activityId;
		    exec(stmtSelect);
			return new ArrayCollection(stmtSelect.getResult().data);
		}
*/
		private const TEXTCOLUMNS:Array = [
			ID("Id"),
			ID(".ActivityId"),				// Missing in WSDL
			PICK(".Subject","ActivityId"),	// Missing in WSDL
			PICK("UserAlias","UserId","Alias"),
			PICK("UserEmail","UserId","EMailAddr"),
			PICK("UserExternalSystemId","UserId","ExternalSystemId"),
			PICK("UserFirstName","UserId","FirstName"),
			PICK("UserLastName","UserId","LastName"),
			PICK("UserRole","UserId","Role"),

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

			"ModId",
			"ModifiedBy",
			"ModifiedById",
			"ModifiedDate",

			"UpdatedByAlias",
			"UpdatedByEMailAddr",
			"UpdatedByExternalSystemId",
			"UpdatedByFirstName",
			"UpdatedByFullName",
			"UpdatedByIntegrationId",
			"UpdatedByLastName",
			"UpdatedByUserSignInId",
			];
	}
}