package gadget.sync.incoming {
	import gadget.dao.DAOUtils;
	import gadget.util.ObjectUtils;
	import flash.utils.getQualifiedClassName;

	public class IncomingObject extends WebServiceIncoming {
		
		public function IncomingObject(entity:String) {
			super(entity);
			if (entity == "Contact") {
				ignoreFields.push("CurrencyCode", "ContactFullName");
			}
			if (entity == "Activity") {
				ignoreQueryFields.push("Owner");
			}			
		}

		override protected function getInfo(xml:XML, ob:Object):Object {
			if (entityIDour == "Contact") {
				ob.picture = null;
			}
			return {
				rowid:ob[DAOUtils.getOracleId(entityIDour)],
				name:ObjectUtils.joinFields(ob, DAOUtils.getNameColumns(entityIDour))
			};
		}
		
		override protected function tweak_vars():void {
			if (entityIDour == "User") {
				withFilters	= false;
			}
		}
		
		override public function getMyClassName():String {
			return getQualifiedClassName(this) + entityIDour;
		}
	}
}
