package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	public class RoleServiceDAO extends SimpleTable {
		private var stmtGetOwnerAccessPf:SQLStatement;
		public function RoleServiceDAO(sqlConnection:SQLConnection, workerFunction:Function) {
			super(sqlConnection, workerFunction, {
				drop_table:true,
				create_cb:function(struct:Object):void { Database.lastsyncDao.unsync('gadget.sync.task::RoleService'); },
				table: "role_service",
				unique: [ 'RoleName' ],
				index:[]
			});
			
			stmtGetOwnerAccessPf = new SQLStatement();
			stmtGetOwnerAccessPf.sqlConnection = sqlConnection;
			stmtGetOwnerAccessPf.text = "SELECT OwnerAccessProfile FROM role_service rs " +
				"WHERE rs.RoleName = :rolename";
		}
		
		public function getOwnerAccessProfile(roleServiceName:String):String{
			stmtGetOwnerAccessPf.parameters[":rolename"]=roleServiceName;
			exec(stmtGetOwnerAccessPf);
			var result:SQLResult = stmtGetOwnerAccessPf.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0].OwnerAccessProfile;
			
		}
		
		override public function delete_all():void {
			del(null);
			// Yuck!
			Database.roleServiceAvailableTabDao.delete_all();
			Database.roleServiceLayoutDao.delete_all();
			Database.roleServicePageLayoutDao.delete_all();
			Database.roleServicePrivilegeDao.delete_all();
			Database.roleServiceRecordTypeAccessDao.delete_all();
			Database.roleServiceSelectedTabDao.delete_all();
			Database.roleServiceTransDao.delete_all();
		}
		
		override public function getColumns():Array {
			return [
				"RoleName",
				"Description",
				"DefaultSalesProcess",
				"ThemeName",
				"LeadConversionLayout",
				"ActionBarLayout",
//				"AccessProfile",
				"DefaultAccessProfile",
				"OwnerAccessProfile",

/*
				"ListOfHomepageLayoutAssignment",
				"ListOfPageLayoutAssignment",
				"ListOfPrivilege",
				"ListOfRecordTypeAccess",
				"ListOfRoleTranslation",
				"ListOfSearchLayoutAssignment",
*/
/*
				"TabAccessAndOrder",
				=>"ListOfAvailableTab"
				=>"ListOfSelectedTabData"
*/
			];
		}
	}
}
