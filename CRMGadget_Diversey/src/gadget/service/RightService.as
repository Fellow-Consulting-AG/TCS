package gadget.service
{
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.util.CacheUtils;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Form;

	public class RightService
	{
		
		public function RightService()
		{
		}
		
		
		
		/**
		 * 
		 * @return true if 1) the transaction is not read only and 2) the user has the right "CanCreate" 
		 * 
		 */
		public static function canCreate(entity:String,forOwner:Boolean=true):Boolean {
			return getRights(entity,forOwner).canCreate;
		}
		
		
		public static function canDelete(entity:String,forOwner:Boolean=true):Boolean {
//			if(!forOwner){
//				return false;
//			}
			return getRights(entity,forOwner).canDelete;
		}
		
		/**
		 * 
		 * @return true if 1) the transaction is not read only and 2) the user has the right "HasAccess" 
		 * 
		 */
		public static function canUpdate(entity:String,forOwner:Boolean=true):Boolean {
			return getRights(entity,forOwner).canUpdate;
		}
		
		
		public static function deleteRightsCatch(entity:String,forOwner:Boolean=true):void {
			var cache:CacheUtils = new CacheUtils("right");
			cache.del(entity+"_"+forOwner);
		}
		/**
		 * To get a right for a given entity.
		 * @param entity : is an entity name.
		 * @return the object that contains canCreate and canUpdate property. 
		 * 
		 */
		private static function getRights(entity:String,forOwner:Boolean=true):Object {
			var cache:CacheUtils = new CacheUtils("right");
			var right:Object;
			right = cache.get(entity+"_"+forOwner); 
			if (right != null) {
				return right;
			}
			
			var tmpRight:Object = readRight(entity,forOwner);
			var entityTransaction:Object = Database.transactionDao.find(entity);
				
				var readOnly:Boolean = entityTransaction ? entityTransaction.read_only : false; 
				var authorizeDeletion:Boolean = entityTransaction ? entityTransaction.authorize_deletion : false; 
				var canCreate:Boolean = !readOnly && tmpRight.CanCreate;
				var canUpdate:Boolean = !readOnly && tmpRight.CanUpdate; 
				var canDelete:Boolean = !readOnly && tmpRight.CanDelete;
				
				/*if(entity == "Account") canDelete = canDelete && Database.preferencesDao.getBooleanValue(PreferencesDAO.ACCOUNT_DELETE);
				if(entity == "Contact") canDelete = canDelete && Database.preferencesDao.getBooleanValue(PreferencesDAO.CONTACT_DELETE);
				if(entity == "Lead") canDelete = canDelete && Database.preferencesDao.getBooleanValue(PreferencesDAO.LEAD_DELETE);
				if(entity == "Opportunity") canDelete = canDelete && Database.preferencesDao.getBooleanValue(PreferencesDAO.OPPORTUNITY_DELETE);
				*/
				canDelete = canDelete && authorizeDeletion;
				
				
				right = {'canCreate':canCreate,'canUpdate':canUpdate,'canDelete':canDelete};
		
			
			
			cache.put(entity+"_"+forOwner, right);
			return right;
		}
	
		
		private static function readRight(entity:String,forOwner:Boolean=true):Object {
			if (entity != null) {
				var role:String = Database.rightDAO.getRole();				
				if(forOwner){					
					
					var right:Object = Database.rightDAO.getRight(role, entity);
					if (right != null) {
						return {CanCreate:right.CanCreate == 'true', CanUpdate:right.HasAccess == 'true','CanDelete':true};;			
					}
					
				}else{
					
					var accessProfile:String=Database.roleServiceDao.getOwnerAccessProfile(role);	
					if(accessProfile==null){
						var accessPf:Array=	 Database.accessProfileServiceEntryDao.fetch({'AccessProfileServiceName':accessProfile,
							'AccessObjectName':entity});
						if(accessPf!=null && accessPf.length>0){
							var pCode:String=accessPf[0].PermissionCode;						 
							if(pCode!=null){
								var canCreate:Boolean = pCode.indexOf("C")!=-1;
								var canUpdate:Boolean = pCode.indexOf("U")!=-1;
								var canDelete:Boolean = pCode.indexOf("D")!=-1;								
								return {'CanCreate':canCreate, 'CanUpdate':canUpdate,'CanDelete':canDelete}; 
							}
							
						}
					}
					
				}
				
			}
			return {CanCreate:true, CanUpdate:true,CanDelete:false};
		}
		
	}
}