package gadget.util
{
	import gadget.dao.DAOUtils;
	
	import mx.collections.ArrayCollection;
	
	public class Relation
	{
		// This array describes relation between entities and is used for :
		// 1) Row ID updates via the ReferenceUpdater class
		// 2) ItemFinder initialization in entity details, when the user clicks on a field that is a relation between two entites.
		//    ItemFinder updates the detail with both ID and label, so we need both information in the table.
		// 3) Link lists and link creation between objects.
		//
		// entitySrc : source entity
		// keySrc : name of the field that is a reference to another entity.
		// keyDest : name of the rowId field of the referenced entity. (it would better to remove this field and replace it with DAOUtils.getOracleId()) 
		// labelSrc : label/name of the referenced entity in the source object.
		// labelDest : label/name of the referenced entity.
		// entityDest : referenced entity.
		// supportTable (optional) : support table that handles m-n relationship between entities.
		//
		private static const RELATIONS:ArrayCollection = new ArrayCollection([
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"UserId", keyDest:"Id", labelSrc:["ContactId"], labelSupport:["UserLastName","UserFirstName","UserRole","ContactAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Contact.Team"},
			{entitySrc:"Contact", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName", "PrimaryCity", "PrimaryCountry", "PrimaryAddress", "AccountLocation", "PrimaryZipCode"], labelDest:["AccountName", "PrimaryBillToCity", "PrimaryBillToCountry", "PrimaryBillToStreetAddress", "Location", "PrimaryBillToPostalCode"], entityDest:"Account"},
			{entitySrc:"Contact", keySrc:"ManagerId", keyDest:"ContactId", labelSrc:["Manager"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Contact", keySrc:"SourceCampaignId", keyDest:"CampaignId", labelSrc:["SourceCampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"ContactId", keyDest:"Id", labelSrc:["ContactFullName"], labelSupport:["RelatedContactFullName","ReverseRelationshipRole","Description","RelationshipStatus","StartDate","EndDate"],isColDynamic:true, labelDest:["RelatedContactFirstName","RelatedContactLastName"], entityDest:"Relationships", supportTable:"Contact.Related"},
			
			{entitySrc:"Contact", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			
			{entitySrc:"Contact.Related", keySrc:"RelatedContactId", keyDest:"ContactId", labelSrc:["RelatedContactFullName","RelatedContactFirstName","RelatedContactLastName"], labelDest:["ContactFullName","ContactFirstName", "ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Contact.Team", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactId"], labelDest:["ContactId"], entityDest:"Contact"},
			{entitySrc:"Contact.Note", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactId"], labelDest:["ContactId"], entityDest:"Contact"},
			
			{entitySrc:"Contact", keySrc:"ContactId", keySupport:"ContactId", keyDest:"Id", labelSrc:["ContactFullName"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Contact.Note"},
			
			
			{entitySrc:"Campaign", keySrc:"CampaignId", keySupport:"CampaignId", keyDest:"Id", labelSrc:["CampaignName"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Campaign.Note"},
			{entitySrc:"Campaign.Note", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignId"], labelDest:["CampaignId"], entityDest:"Campaign"},
			
			
			{entitySrc:"Account.Competitor", keySrc:"CompetitorId", keyDest:"AccountId", labelSrc:["CompetitorName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Competitor", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},			
			
			
			{entitySrc:"Account.Partner", keySrc:"PartnerId", keyDest:"AccountId", labelSrc:["PartnerName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Partner", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			
			{entitySrc:"Account.Team", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account.Note", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountId"], labelDest:["AccountId"], entityDest:"Account"},
			
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"UserId", keyDest:"Id", labelSrc:["AccountName"], labelSupport:["LastName","FirstName","RoleName","AccountAccess","ContactAccess","OpportunityAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Account.Team"},
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"Id", keyDest:"Id", labelSrc:["AccountName"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Account.Note"},
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"AccountId", keyDest:"Id", labelSrc:["CompetitorName"], labelSupport:["CompetitorName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["CompetitorName"], entityDest:"Competitor", supportTable:"Account.Competitor"},			
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"AccountId", keyDest:"Id", labelSrc:["PartnerName"], labelSupport:["PartnerName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["PartnerName"], entityDest:"Partner", supportTable:"Account.Partner"},
			{entitySrc:"Account", keySrc:"SourceCampaignId", keyDest:"CampaignId", labelSrc:["SourceCampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Account", keySrc:"AccountId", keyDest:"ParentAccountId", labelSrc:["AccountName"],keepOutLabelSrc : true, labelDest:["ParentAccount"], entityDest:"Account"},
			{entitySrc:"Account", keySrc:"ParentAccountId", keyDest:"AccountId", labelSrc:["ParentAccount"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Account", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Account", keySrc:"PriceListId", keyDest:"Id", labelSrc:["PriceListPriceListName"], labelDest:["PriceListName"], entityDest:"PriceList"},
//			{entitySrc:"Account", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Asset"},
			/* fix #2018
			{entitySrc:"Account", keySrc:"AccountId", keySupport:"ContactId", keyDest:"ContactId", labelSrc:["AccountName"], labelSupport:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact", supportTable:"Contact.Account"},
			*/
			//{entitySrc:"Account", keySrc:"AccountId", keySupport:"Id", keyDest:"Id", labelSrc:["AccountName"], labelSupport:["Product","SerialNumber","Quantity","Type","Status","PurchaseDate","PurchasePrice","NotifyDate"],isColDynamic:true, labelDest:["Product"], entityDest:"Asset", supportTable:"Account.Asset"},
			{entitySrc:"Account", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			
			{entitySrc:"Opportunity.Product", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity.Product", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","ProductCategory","ProductType","ProductStatus","ProductPartNumber"], labelDest:["Name","ProductCategory","ProductType","Status","PartNumber"], entityDest:"Product"},
			{entitySrc:"Opportunity.Partner", keySrc:"PartnerId", keyDest:"AccountId", labelSrc:["PartnerName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity.Partner", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContactName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Opportunity.Team", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityId"], labelDest:["OpportunityId"], entityDest:"Opportunity"},
			{entitySrc:"Opportunity.Note", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityId"], labelDest:["OpportunityId"], entityDest:"Opportunity"},
			
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"OpportunityId", keyDest:"ProductId", labelSrc:["OpportunityName"], labelSupport:["ProductName","Quantity","PurchasePrice","Revenue","Frequency","NumberOfPeriods","Owner"],isColDynamic:true, labelDest:["Name"], entityDest:"Product", supportTable:"Opportunity.Product"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"OpportunityId", keyDest:"Id", labelSrc:["PartnerName"], labelSupport:["PartnerName","PrimaryContactName","RelationshipRole"],isColDynamic:true, labelDest:["PartnerName"], entityDest:"Partner", supportTable:"Opportunity.Partner"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"UserId", keyDest:"Id", labelSrc:["OpportunityId"], labelSupport:["UserLastName","UserFirstName","OpportunityAccess"],isColDynamic:true, labelDest:["LastName","FirstName"], entityDest:"User", supportTable:"Opportunity.Team"},
			{entitySrc:"Opportunity", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Opportunity", keySrc:"OpportunityId", keySupport:"Id", keyDest:"Id", labelSrc:["OpportunityId"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Opportunity.Note"},
			
			{entitySrc:"Opportunity", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			{entitySrc:"Opportunity", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			
			{entitySrc:"Service Request", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Service Request", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Service Request", keySrc:"ServiceRequestId", keySupport:"ServiceRequestId", keyDest:"Id", labelSrc:["ServiceRequestId"], labelSupport:["Subject","Private","CreatedByFullName","ModifiedDate"],isColDynamic:true, labelDest:["Subject"], entityDest:"Note", supportTable:"Service Request.Note"},
			{entitySrc:"Service Request.Note", keySrc:"ServiceRequestId",labelSrc:["ServiceRequestId"], keyDest:"ServiceRequestId",labelDest:["ServiceRequestId"],  entityDest:"Service Request"},
			
			{entitySrc:"Service Request", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			
			//{entitySrc:"Service Request", keySrc:"CustomObject1Id", keyDest:"CustomObject1Id", labelSrc:["CustomObject1Name"], labelDest:["Name"], entityDest:"Custom Object 1"},
			//{entitySrc:"Service Request", keySrc:"CustomObject2Id", keyDest:"CustomObject2Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},
			
			
			{entitySrc:"Custom Object 1", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Custom Object 1", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Custom Object 1", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			
			//{entitySrc:"Custom Object 1", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			{entitySrc:"Activity", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName", "AccountLocation"], labelDest:["AccountName", "Location"], entityDest:"Account"},
			{entitySrc:"Activity", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["CampaignName"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Activity", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Activity", keySrc:"PrimaryContactId", keyDest:"ContactId", labelSrc:["PrimaryContact", "PrimaryContactFirstName", "PrimaryContactLastName"], labelDest:["ContactFullName", "ContactFirstName", "ContactLastName"], entityDest:"Contact"},
			{entitySrc:"Activity", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"Activity", keySrc:"LeadId", keyDest:"LeadId", labelSrc:["Lead"], labelDest:["LeadFullName"], entityDest:"Lead"},
			{entitySrc:"Activity", keySrc:"CustomObject14Id", keyDest:"Id", labelSrc:["CustomObject14Name"], labelDest:["Name"], entityDest:"CustomObject14"},
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"ProductId", keyDest:"ProductId", labelSrc:["Subject"], labelSupport:["Product"], labelDest:["Name"], entityDest:"Product", supportTable:"Activity.Product"},
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"UserId", keyDest:"Id", labelSrc:["UserFirstName", "UserLastName"], labelSupport:["UserFirstName", "UserLastName"], labelDest:["FirstName", "LastName"]/*labelSrc:["Subject"], labelSupport:"UserAlias", labelDest:["Alias"]*/, entityDest:"User", supportTable:"Activity.User"}, // SC-20110616
			{entitySrc:"Activity", keySrc:"ActivityId", keySupport:"Id", keyDest:"ContactId", labelSrc:["PrimaryContactFirstName", "PrimaryContactLastName"], labelSupport:["ContactFirstName", "ContactLastName"], labelDest:["ContactFirstName", "ContactLastName"]/*labelSrc:["Subject"], labelSupport:"ContactFullName", labelDest:["ContactFullName"]*/, entityDest:"Contact", supportTable:"Activity.Contact"},
			
			{entitySrc:"Activity", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			{entitySrc:"Activity", keySrc:"CustomObject5Id", keyDest:"Id", labelSrc:["CustomObject5Name"], labelDest:["Name"], entityDest:"CustomObject5"},
			
			
			{entitySrc:"Lead", keySrc:"CampaignId", keyDest:"CampaignId", labelSrc:["Campaign"], labelDest:["CampaignName"], entityDest:"Campaign"},
			{entitySrc:"Lead", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName","AccountLocation","AccountFuriganaName"],labelDest:["AccountName","Location",'FuriganaName'],  entityDest:"Account"},
			{entitySrc:"Lead", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName","ContactFirstName","ContactFuriganaFirstName","ContactFuriganaLastName","ContactLastName"], labelDest:["ContactFullName","ContactFirstName","FuriganaFirstName", "FuriganaLastName", "ContactLastName" ], labelDest:["ContactFullName","ContactFirstName","ContactFuriganaFirstName","ContactFuriganaLastName","ContactLastName"], entityDest:"Contact"},
			
			{entitySrc:"Custom Object 2", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"Custom Object 2", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"Custom Object 2", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Custom Object 2", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"Custom Object 2", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			
			{entitySrc:"Custom Object 2", keySrc:"CustomObject3Id", keyDest:"Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
//			{entitySrc:"Custom Object 3", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
//			{entitySrc:"Custom Object 3", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
//			{entitySrc:"Custom Object 3", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
//			{entitySrc:"Custom Object 3", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
//			{entitySrc:"Custom Object 3", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
//			{entitySrc:"Custom Object 3", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
//			
//			
//			{entitySrc:"CustomObject4", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
//			{entitySrc:"CustomObject4", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
//			{entitySrc:"CustomObject4", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
//			{entitySrc:"CustomObject4", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
//			{entitySrc:"CustomObject4", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},

			
			{entitySrc:"CustomObject14", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject14", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},
			{entitySrc:"CustomObject14", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"CustomObject14", keySrc:"OpportunityId", keyDest:"OpportunityId", labelSrc:["OpportunityName"], labelDest:["OpportunityName"], entityDest:"Opportunity"},
			{entitySrc:"CustomObject14", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivitySubject"], labelDest:["Subject"], entityDest:"Activity"},
			{entitySrc:"CustomObject14", keySrc:"ServiceRequestId", keyDest:"ServiceRequestId", labelSrc:["ServiceRequestSRNumber"], labelDest:["SRNumber"], entityDest:"Service Request"},
			{entitySrc:"CustomObject14", keySrc:"CustomObject3Id", keyDest:"CustomObject3Id", labelSrc:["CustomObject3Name"], labelDest:["Name"], entityDest:"Custom Object 3"},
			
			{entitySrc:"CustomObject7", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"CustomObject7", keySrc:"CustomObject2Id", keyDest:"Id", labelSrc:["CustomObject2Name"], labelDest:["Name"], entityDest:"Custom Object 2"},

			{entitySrc:"CustomObject5", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["ProductName","CustomCurrency20"], labelDest:["ProductName","ListPrice"], entityDest:"PriceListLineItem"},
			{entitySrc:"CustomObject5", keySrc:"CustomObject4Id", keyDest:"Id", labelSrc:["CustomObject4Name"], labelDest:["Name"], entityDest:"CustomObject4"},
			
			{entitySrc:"CustomObject10", keySrc:"ActivityId", keyDest:"ActivityId", labelSrc:["ActivitySubject"], labelDest:["Subject"], entityDest:"Activity"},
			
			{entitySrc:"CustomObject4", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"},
			{entitySrc:"CustomObject4", keySrc:"ContactId", keyDest:"ContactId", labelSrc:["ContactFullName"], labelDest:["ContactFullName"], entityDest:"Contact"},

			{entitySrc:"Asset", keySrc:"ProductId", keyDest:"ProductId", labelSrc:["Product"], labelDest:["Name"], entityDest:"Product"},
			{entitySrc:"Asset", keySrc:"AccountId", keyDest:"AccountId", labelSrc:["AccountName"], labelDest:["AccountName"], entityDest:"Account"}

		]);
		
		
		public static function getFieldRelation(entitySrc:String, field:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entitySrc && relation.labelSrc[0] == field) {
//				if (relation.entitySrc == entitySrc && relation.labelSrc == field) {
					return relation;
				}
			}
			if (entitySrc.indexOf(".")>0) {
				return DAOUtils.fakeGetFieldRelation(entitySrc, field);
			}
			return null;
		}

		
		public static function getAllFieldsRelation(entitySrc:String):ArrayCollection{
			var rFields:ArrayCollection=new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entitySrc) {
					for each(var f:String in relation.labelSrc){
						if(rFields.contains(f)) continue;
						rFields.addItem(f);
					}
				}
			}
			return rFields;
		}
		
		
		
		//VAHI There can be more than one field which has a relation to another object.
		// So this should return a list (Array) of such relations, not just an arbitrary one.
		// Perhaps rename it to getRelations() then.
		public static function getRelation(entitySrc:String, entityDest:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.supportTable == null && relation.entitySrc == entitySrc && relation.entityDest == entityDest) {
					return relation;
				}
			}	
			return null;
		}
		
		public static function getMNRelation(entitySrc:String, entityDest:String):Object {
			for each (var relation:Object in RELATIONS) {
				if (relation.supportTable != null && relation.entitySrc == entitySrc && relation.entityDest == entityDest) {
					return relation;
				}
			}	
			return null;
		}
		
		
		/**
		 * Returns the entities that are referenced by this entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getReferenced(entity:String):ArrayCollection {
			var references:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entity) {
					references.addItem(relation);
				}
			}
			return references;
		}

		/**
		 * Returns the entities that are referenced by this entity, and that use a MxN relationship. 
		 * @param entity
		 * @return 
		 */
		public static function getMNReferenced(entity:String):ArrayCollection {
			var references:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entitySrc == entity && relation.supportTable) {
					references.addItem(relation);
				}
			}
			return references;
		}
		
		/**
		 * Returns the entities that reference this entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getReferencers(entity:String):ArrayCollection {
			var referencers:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entityDest == entity) {
					referencers.addItem(relation);
				}
			}			
			if (entity.indexOf(".")>0) {
				OOPS("=missing","getReferencers for SupportDAO not yet implemented");
			}
			return referencers;
		}
		
		/**
		 * Returns all the entities that are linkable to a specific entity. 
		 * @param entity
		 * @return 
		 * 
		 */
		public static function getLinkable(entity:String):ArrayCollection {
			var linkable:ArrayCollection = new ArrayCollection();
			for each (var relation:Object in RELATIONS) {
				if (relation.entityDest == entity && !linkable.contains(relation.entitySrc)) {
					linkable.addItem(relation.entitySrc);
				}
				if (relation.entitySrc == entity && !linkable.contains(relation.entityDest)) {
					linkable.addItem(relation.entityDest);
				}

			}
			if (entity.indexOf(".")>0) {
				OOPS("=missing","getLinkable for SupportDAO not yet implemented");
			}
			return linkable;
		}
		
	}
}