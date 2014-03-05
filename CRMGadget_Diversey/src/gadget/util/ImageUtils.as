package gadget.util{
	import flash.utils.ByteArray;
	
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Decoder;

	public class ImageUtils{
		
		[Embed(source='/assets/appointment.png')] [Bindable] public static var appointmentIcon:Class;
		[Embed(source='/assets/d_silhouette.gif')] [Bindable] public static var noPhoto:Class;
		[Embed(source='/assets/feed/add_group.png')] [Bindable] public static var addGroup:Class;
		[Embed(source='/assets/feed/add_member.png')] [Bindable] public static var addMember:Class;
		[Embed(source='/assets/feed/remove_group.png')] [Bindable] public static var removeGroup:Class;
		[Embed(source='/assets/feed/remove_member.png')] [Bindable] public static var removeMember:Class;
		[Embed(source='/assets/feed/group.png')] [Bindable] public static var group:Class;
		[Embed(source='/assets/feed/member.png')] [Bindable] public static var member:Class;
		
		[Embed(source='/assets/daily_agenda.png')] [Bindable] public static var dailyAgenda:Class;
		[Embed(source='/assets/chat_icon.png')] [Bindable] public static var chat:Class;
		[Embed(source='/assets/chart_Bar.png')] [Bindable] public static var chartBar:Class;
		[Embed(source='/assets/darkCross.png')] [Bindable] public static var darkCross:Class;
		[Embed(source='/assets/facebook.png')] [Bindable] public static var facebookIcon:Class;
		[Embed(source='/assets/linkedin.png')] [Bindable] public static var linkedinIcon:Class;
		[Embed(source='/assets/cross.png')] [Bindable] public static var cross:Class;
		[Embed(source='/assets/time.png')] [Bindable] public static var time:Class;
		[Embed(source='/assets/paper.png')] [Bindable] public static var paper:Class;
		[Embed(source='/assets/favorite.png')] [Bindable] public static var favorite:Class;
		[Embed(source='/assets/unfavorite.png')] [Bindable] public static var unFavorite:Class;
		[Embed(source='/assets/gcalendar-16.png')] [Bindable] public static var gCalendarIcon:Class;
		[Embed(source='/assets/custom/si_contacts16_p.gif')] [Bindable] public static var pContactDefaultIcon:Class;
		[Embed(source='/assets/contact_p.png')] [Bindable] public static var pContactIcon:Class;
		[Embed(source='/assets/epadSign.png')] [Bindable] public static var epadSignIcon:Class;
		[Embed(source='/assets/epadSignPre.png')] [Bindable] public static var epadSignPreIcon:Class;
		[Embed(source='/assets/Formula.png')] [Bindable] public static var formulaIcon:Class;
		[Embed(source='/assets/custom_field.png')] [Bindable] public static var customFieldIcon:Class;
		[Embed(source='/assets/field.png')] [Bindable] public static var fieldIcon:Class;
		
		[Embed(source='/assets/pdficon.gif')] [Bindable] public static var pdfIcon:Class;
		[Embed(source='/assets/warning.png')] [Bindable] public static var warningIcon:Class;
		[Embed(source='/assets/tick.png')] [Bindable] public static var tickIcon:Class;
		[Embed(source='/assets/cross.png')] [Bindable] public static var crossIcon:Class;
		[Embed(source='/assets/report.png')] [Bindable] public static var reportIcon:Class;
		[Embed(source='/assets/kitchen_report.png')] [Bindable] public static var kitchenReportIcon:Class;
		[Embed(source='/assets/run_report.png')] [Bindable] public static var runReportIcon:Class;
		
		[Embed(source='/assets/info.png')] [Bindable] public static var infoIcon:Class;
		[Embed(source='/assets/error.png')] [Bindable] public static var errorIcon:Class;
		
		[Embed(source='/assets/mail_icon.png')] [Bindable] public static var emailIcon:Class;
		
		[Embed(source='/assets/next.png')] [Bindable] public static var nextDayIcon:Class;
		[Embed(source='/assets/previous.png')] [Bindable] public static var previousDayIcon:Class;
		
		[Embed(source='/assets/website.png')] [Bindable] public static var websiteIcon:Class;
		
		[Embed(source='/assets/sqlquery.png')] [Bindable] public static var sqlListImg:Class;
		[Embed(source='/assets/sqlfield.png')] [Bindable] public static var sqlFieldImg:Class;
		[Embed(source='/assets/htmlfield.png')] [Bindable] public static var htmlFieldImg:Class;
		[Embed(source='/assets/newsfield.png')] [Bindable] public static var newsFieldImg:Class;
		
		[Embed(source='/assets/lock.png')] [Bindable] public static var lockImg:Class;
		[Embed(source='/assets/mandatory.png')] [Bindable] public static var mandatoryImg:Class;
		
		[Embed(source='/assets/territory.png')] [Bindable] private static var territoryImg:Class;
		[Embed(source='/assets/account.png')] [Bindable] private static var accountImg:Class;
		[Embed(source='/assets/asset.png')] [Bindable] private static var assetImg:Class;
		[Embed(source='/assets/contact.png')] [Bindable] private static var contactImg:Class;
        [Embed(source='/assets/opportunity.png')] [Bindable] private static var opportunityImg:Class;
        [Embed(source='/assets/activity.png')] [Bindable] private static var activityImg:Class;
        [Embed(source='/assets/service.png')] [Bindable] private static var serviceImg:Class;
        [Embed(source='/assets/product.png')] [Bindable] private static var productImg:Class;
		[Embed(source='/assets/campaign.png')] [Bindable] private static var campaignImg:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObjectImg:Class;
		[Embed(source='/assets/picklist.png')] [Bindable] private static var picklistImg:Class;
		[Embed(source='/assets/lead.png')] [Bindable] private static var leadImg:Class;
		[Embed(source='/assets/custom2.png')] [Bindable] private static var customObject2Img:Class;
		[Embed(source='/assets/custom3.png')] [Bindable] private static var customObject3Img:Class;
		[Embed(source='/assets/custom7.png')] [Bindable] private static var customObject7Img:Class;
		[Embed(source='/assets/custom14.png')] [Bindable] private static var customObject14Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject4Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject5Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject6Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject8Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject9Img:Class;
		[Embed(source='/assets/custom.png')] [Bindable] private static var customObject10Img:Class;
		[Embed(source='/assets/note.png')] [Bindable] private static var noteImg:Class;
		[Embed(source='/assets/meded.png')] [Bindable] private static var medEdImg:Class;
		
		[Embed(source='/assets/account_bw.png')] [Bindable] private static var accountBWImg:Class;
		[Embed(source='/assets/asset_bw.png')] [Bindable] private static var assetBWImg:Class;
		[Embed(source='/assets/contact_bw.png')] [Bindable] private static var contactBWImg:Class;
		[Embed(source='/assets/opportunity_bw.png')] [Bindable] private static var opportunityBWImg:Class;
		[Embed(source='/assets/activity_bw.png')] [Bindable] private static var activityBWImg:Class;
		[Embed(source='/assets/service_bw.png')] [Bindable] private static var serviceBWImg:Class;
		[Embed(source='/assets/campaign_bw.png')] [Bindable] private static var campaignBWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var customBWImg:Class;
		[Embed(source='/assets/custom2_bw.png')] [Bindable] private static var custom2BWImg:Class;
		[Embed(source='/assets/custom3_bw.png')] [Bindable] private static var custom3BWImg:Class;
		[Embed(source='/assets/custom7_bw.png')] [Bindable] private static var custom7BWImg:Class;
		[Embed(source='/assets/custom14_bw.png')] [Bindable] private static var custom14BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom4BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom5BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom6BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom8BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom9BWImg:Class;
		[Embed(source='/assets/custom_bw.png')] [Bindable] private static var custom10BWImg:Class;
		[Embed(source='/assets/lead_bw.png')] [Bindable] private static var leadBWImg:Class;
		[Embed(source='/assets/product_bw.png')] [Bindable] private static var productBWImg:Class;
		[Embed(source='/assets/note_bw.png')] [Bindable] private static var noteBWImg:Class;
		[Embed(source='/assets/meded_bw.png')] [Bindable] private static var medEdBWImg:Class;
		
		[Embed(source='/assets/custom/si_account16.gif')] [Bindable] private static var accountDefaultImg:Class;
		[Embed(source='/assets/custom/si_asset16.gif')] [Bindable] private static var assetDefaultImg:Class;
		[Embed(source='/assets/custom/si_contacts16.gif')] [Bindable] private static var contactDefaultImg:Class;
		[Embed(source='/assets/custom/si_opportunities16.gif')] [Bindable] private static var opportunityDefaultImg:Class;
		[Embed(source='/assets/custom/si_task16.gif')] [Bindable] private static var activityTaskDefaultImg:Class;
		[Embed(source='/assets/custom/si_appointments16.gif')] [Bindable] private static var activityAppointmentDefaultImg:Class;
		[Embed(source='/assets/call.png')] [Bindable] private static var activityCallDefaultImg:Class;
		[Embed(source='/assets/custom/si_service16.gif')] [Bindable] private static var serviceDefaultImg:Class;
		[Embed(source='/assets/custom/si_product16.gif')] [Bindable] private static var productDefaultImg:Class;
		[Embed(source='/assets/custom/si_campaigns16.gif')] [Bindable] private static var campaignDefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObjectDefaultImg:Class;
		[Embed(source='/assets/custom/si_leads16.gif')] [Bindable] private static var leadDefaultImg:Class;		
		[Embed(source='/assets/custom/si_custobj2_16.gif')] [Bindable] private static var customObject2DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj3_16.gif')] [Bindable] private static var customObject3DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj7_16.gif')] [Bindable] private static var customObject7DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj14_16.gif')] [Bindable] private static var customObject14DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject4DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject5DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject6DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject8DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject9DefaultImg:Class;
		[Embed(source='/assets/custom/si_custobj16.gif')] [Bindable] private static var customObject10DefaultImg:Class;
		[Embed(source='/assets/custom/si_flag.png')] [Bindable] private static var flagBWImg:Class;
		[Embed(source='/assets/custom/si_note16.gif')] [Bindable] private static var noteDefaultImg:Class;
		[Embed(source='/assets/custom/si_meded16.gif')] [Bindable] private static var medEdDefaultImg:Class;

		[Embed(source='/assets/custom/si_account16_bw.gif')] [Bindable] private static var accountDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_asset16_bw.gif')] [Bindable] private static var assetDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_contacts16_bw.gif')] [Bindable] private static var contactDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_opportunities16_bw.gif')] [Bindable] private static var opportunityDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_task16_bw.gif')] [Bindable] private static var activityTaskDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_appointments16_bw.gif')] [Bindable] private static var activityAppointmentDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_service16_bw.gif')] [Bindable] private static var serviceDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_product16_bw.gif')] [Bindable] private static var productDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_campaigns16_bw.gif')] [Bindable] private static var campaignDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var customObjectDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_leads16_bw.gif')] [Bindable] private static var leadDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var customDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj2_16_bw.gif')] [Bindable] private static var custom2DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj3_16_bw.gif')] [Bindable] private static var custom3DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj7_16_bw.gif')] [Bindable] private static var custom7DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj14_16_bw.gif')] [Bindable] private static var custom14DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom4DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom5DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom6DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom8DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom9DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_custobj16_bw.gif')] [Bindable] private static var custom10DefaultBWImg:Class;
		[Embed(source='/assets/custom/si_note16_bw.gif')] [Bindable] private static var noteDefaultBWImg:Class;
		[Embed(source='/assets/custom/si_meded16_bw.gif')] [Bindable] private static var medEdDefaultBWImg:Class;
		
		[Embed(source='/assets/account_big.png')] [Bindable] private static var accountBigImg:Class;
		[Embed(source='/assets/asset_big.png')] [Bindable] private static var assetBigImg:Class;
		[Embed(source='/assets/contact_big.png')] [Bindable] private static var contactBigImg:Class;
        [Embed(source='/assets/opportunity_big.png')] [Bindable] private static var opportunityBigImg:Class;
        [Embed(source='/assets/activity_big.png')] [Bindable] private static var activityBigImg:Class;
        [Embed(source='/assets/product_big.png')] [Bindable] private static var productBigImg:Class;
        [Embed(source='/assets/service_big.png')] [Bindable] private static var serviceBigImg:Class;
		[Embed(source='/assets/campaign_big.png')] [Bindable] private static var campaignBigImg:Class;
		[Embed(source='/assets/custom_big.png')] [Bindable] private static var customBigImg:Class;
		[Embed(source='/assets/lead_big.png')] [Bindable] private static var leadBigImg:Class;
		[Embed(source='/assets/custom2_big.png')] [Bindable] private static var custom2BigImg:Class;
		[Embed(source='/assets/custom3_big.png')] [Bindable] private static var custom3BigImg:Class;
		[Embed(source='/assets/custom7_big.png')] [Bindable] private static var custom7BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom14BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom4BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom5BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom6BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom8BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom9BigImg:Class;
		[Embed(source='/assets/custom14_big.png')] [Bindable] private static var custom10BigImg:Class;
		[Embed(source='/assets/note_big.png')] [Bindable] private static var noteBigImg:Class;
		[Embed(source='/assets/meded_big.png')] [Bindable] private static var medEdBigImg:Class;
		
		[Embed(source='/assets/custom/bigicons/si_account80.gif')] [Bindable] private static var accountDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_asset80.gif')] [Bindable] private static var assetDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_contacts80.gif')] [Bindable] private static var contactDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_opportunities80.gif')] [Bindable] private static var opportunityDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_task80.gif')] [Bindable] private static var activityTaskDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_appointments80.gif')] [Bindable] private static var activityAppointmentDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_service80.gif')] [Bindable] private static var serviceDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_product80.gif')] [Bindable] private static var productDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_campaigns80.gif')] [Bindable] private static var campaignDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObjectDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_leads80.gif')] [Bindable] private static var leadDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj2_80.gif')] [Bindable] private static var customObject2DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj3_80.gif')] [Bindable] private static var customObject3DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj7_80.gif')] [Bindable] private static var customObject7DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj14_80.gif')] [Bindable] private static var customObject14DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject4DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject5DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject6DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject8DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject9DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_custobj80.gif')] [Bindable] private static var customObject10DefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_note80.gif')] [Bindable] private static var noteDefaultBigImg:Class;
		[Embed(source='/assets/custom/bigicons/si_meded80.gif')] [Bindable] private static var medEdDefaultBigImg:Class;
		
		[Embed("/assets/accept.png")] public static const acceptIcon:Class;
		[Embed("/assets/cancel.png")] public static const cancelIcon:Class;
		[Embed("/assets/edit.png")] public static const editIcon:Class;			
		[Embed("/assets/delete.png")] public static const deleteIcon:Class;
		
		[Embed("/assets/add.png")] public static const addIcon:Class;
		[Embed("/assets/addBW.png")] public static const addBWIcon:Class;
		
		[Embed("/assets/link.png")] public static const linkIcon:Class;
		
		[Embed(source='/assets/triangle-left.gif')] [Bindable] public static var leftIcon:Class;
		[Embed(source='/assets/triangle-right.gif')] [Bindable] public static var rightIcon:Class;
		[Embed(source='/assets/triangle-down.gif')] [Bindable] public static var downIcon:Class;
		[Embed(source='/assets/triangle-up.gif')] [Bindable] public static var upIcon:Class;
		
		
		[Embed(source="/assets/sync.png")] [Bindable] public static var synIcon:Class;
		[Embed(source="/assets/sync_ok.png")] [Bindable] public static var synOkIcon:Class;
		[Embed(source="/assets/sync_error.png")] [Bindable] public static var synErrorIcon:Class;
		
		[Embed(source="/assets/custom/flag_blue.png")] [Bindable] public static var blueIcon:Class;
		[Embed(source="/assets/custom/flag_green.png")] [Bindable] public static var greenIcon:Class;
		[Embed(source="/assets/custom/flag_orange.png")] [Bindable] public static var orangeIcon:Class;
		[Embed(source="/assets/custom/flag_pink.png")] [Bindable] public static var pinkIcon:Class;
		[Embed(source="/assets/custom/flag_purple.png")] [Bindable] public static var purpleIcon:Class;
		[Embed(source="/assets/custom/flag_red.png")] [Bindable] public static var redIcon:Class;
		[Embed(source="/assets/custom/flag_yellow.png")] [Bindable] public static var yellowIcon:Class;
		[Embed(source='/assets/preview.gif')] [Bindable] public static var previewIcon:Class;
		[Embed(source='/assets/man.png')] [Bindable] public static var manIcon:Class;
		[Embed(source='/assets/woman.png')] [Bindable] public static var womanIcon:Class;
		[Embed(source='/assets/doctor.png')] [Bindable] public static var doctorIcon:Class;
		
		[Embed(source='/assets/red.gif')] [Bindable] public static var red:Class;
		[Embed(source='/assets/green.gif')] [Bindable] public static var green:Class;
		[Embed(source='/assets/yellow.gif')] [Bindable] public static var yellow:Class;
		[Embed(source='/assets/blue.gif')] [Bindable] public static var blue:Class;
		[Embed(source='/assets/orange.gif')] [Bindable] public static var orange:Class;
		[Embed(source='/assets/purple.gif')] [Bindable] public static var purple:Class;
		[Embed(source='/assets/gray.gif')] [Bindable] public static var gray:Class;
		[Embed(source='/assets/white.gif')] [Bindable] public static var white:Class;
		[Embed(source='/assets/black.gif')] [Bindable] public static var black:Class;
		[Embed(source='/assets/thumb.gif')] [Bindable] public static var thumb:Class;
		[Embed(source='/assets/tick.gif')] [Bindable] public static var tick:Class;
		[Embed(source='/assets/question.gif')] [Bindable] public static var question:Class;
		[Embed(source='/assets/warning.gif')] [Bindable] public static var warning:Class;
		[Embed(source='/assets/home.png')] [Bindable] public static var home:Class;
		public static function getColorIcon():Object{
			
			return {"/assets/red.gif":red,
				"/assets/green.gif":green,
				"/assets/yellow.gif":yellow,
				"/assets/blue.gif":blue,
				"/assets/orange.gif":orange,
				"/assets/purple.gif":purple,
				"/assets/gray.gif":gray,
				"/assets/white.gif":white,
				"/assets/black.gif":black
			};
		}
		public static function getIconByName(custom_layout_icon:String): Class {
			switch(custom_layout_icon){
				case "flag_blue": return blueIcon;
				case "flag_green": return greenIcon;
				case "flag_orange": return orangeIcon;
				case "flag_pink": return pinkIcon;
				case "flag_purple": return purpleIcon;
				case "flag_red": return redIcon;
				case "flag_yellow": return yellowIcon;
				case "account": return accountImg;
				case "accountBW": return accountBWImg;
				case "accountDefault": return accountDefaultImg;
				case "accountDefaultBW": return accountDefaultBWImg;
				case "asset": return assetImg;
				case "assetBW": return assetBWImg;
				case "assetDefault": return assetDefaultImg;
				case "assetDefaultBW": return assetDefaultBWImg;
				case "contact" : return contactImg;
				case "contactBW" : return contactBWImg;
				case "contactDefault": return contactDefaultImg;
				case "contactDefaultBW": return contactDefaultBWImg;
				case "opportunity" : return opportunityImg;
				case "opportunityBW" : return opportunityBWImg;
				case "opportunityDefault": return opportunityDefaultImg;
				case "opportunityDefaultBW": return opportunityDefaultBWImg;	
				case "activity": return activityImg;
				case "activityBW": return activityBWImg;	
				case "activityTaskDefault": return activityTaskDefaultImg;
				case "activityTaskDefaultBW": return activityTaskDefaultBWImg;
				case "activityAppointmentDefault": return activityAppointmentDefaultImg;
				case "activityAppointmentDefaultBW": return activityAppointmentDefaultBWImg;
				case "service": return serviceImg;
				case "serviceBW": return serviceBWImg;	
				case "serviceDefault": return serviceDefaultImg;
				case "serviceDefaultBW": return serviceDefaultBWImg;	
				case "product": return productImg;
				case "productBW": return productBWImg;
				case "productDefault": return productDefaultImg;
				case "productDefaultBW": return productDefaultBWImg;
				case "campaign": return campaignImg;
				case "campaignBW": return campaignBWImg;
				case "campaignDefault": return campaignDefaultImg;
				case "campaignDefaultBW": return campaignDefaultBWImg;
				case "custom": return customObjectImg;
				case "customBW": return customBWImg;	
				case "customDefault": return customObjectDefaultImg;
				case "customDefaultBW": return customObjectDefaultBWImg;
					
				case "custom2": return customObject2Img;
				case "custom2BW": return custom2BWImg;	
				case "custom2Default": return customObject2DefaultImg;
				case "custom2DefaultBW": return custom2DefaultBWImg;	
					
				case "custom3": return customObject3Img;
				case "custom3BW": return custom3BWImg;	
				case "custom3Default": return customObject3DefaultImg;
				case "custom3DefaultBW": return custom3DefaultBWImg;	
					
				case "custom7": return customObject7Img;
				case "custom7BW": return custom7BWImg;	
				case "custom7Default": return customObject7DefaultImg;
				case "custom7DefaultBW": return custom7DefaultBWImg;	
					
				case "custom14": return customObject14Img;	
				case "custom14BW": return custom14BWImg;	
				case "custom14Default": return customObject14DefaultImg;
				case "custom14DefaultBW": return custom14DefaultBWImg;	
					
				case "custom4": return customObject4Img;
				case "custom4BW": return custom4BWImg;		
				case "custom4Default": return customObject4DefaultImg;
				case "custom4DefaultBW": return custom4DefaultBWImg;	
					
				case "custom5": return customObject5Img;
				case "custom5BW": return custom5BWImg;	
				case "custom5Default": return customObject5DefaultImg;	
				case "custom5DefaultBW": return custom5DefaultBWImg;
				
				case "custom6": return customObject6Img;
				case "custom6BW": return custom6BWImg;	
				case "custom6Default": return customObject6DefaultImg;	
				case "custom6DefaultBW": return custom6DefaultBWImg;	
				
				case "custom8": return customObject8Img;
				case "custom8BW": return custom8BWImg;	
				case "custom8Default": return customObject8DefaultImg;	
				case "custom8DefaultBW": return custom8DefaultBWImg;	
				
				case "custom9": return customObject9Img;
				case "custom9BW": return custom9BWImg;	
				case "custom9Default": return customObject9DefaultImg;	
				case "custom9DefaultBW": return custom9DefaultBWImg;
				
				case "custom10": return customObject10Img;
				case "custom10BW": return custom10BWImg;	
				case "custom10Default": return customObject10DefaultImg;	
				case "custom10DefaultBW": return custom10DefaultBWImg;		
					
				case "lead": return leadImg;
				case "leadDefault": return leadDefaultImg;	
				case "activityCallDefault": return activityCallDefaultImg;
				case "territory": return territoryImg;
				case "territoryDefault": return territoryImg;
//				case "territoryDefaultBW": return assetDefaultBWImg;
				case "note": return noteImg;
				case "noteBW": return noteBWImg;
				case "noteDefault": return noteDefaultImg;	
				case "noteDefaultBW": return noteDefaultBWImg;	
				
				case "MedEd": return medEdImg;
				case "MedEdBW": return medEdBWImg;
				case "MedEdDefault": return medEdDefaultImg;	
				case "MedEdDefaultBW": return medEdDefaultBWImg;		
					
				default: return null;
			}
		}
		
		
		public static function getImagePath(imageClass:Class):String{
			if(imageClass==accountImg){
				return "/assets/account.png";
			}
			else if(imageClass==accountDefaultImg){
				return "/assets/custom/si_account16.gif";
			}
			return "";
		}
		
		public static function getCustomLayoutIconsByEntity(entity:String):ArrayCollection{
			var tmp:ArrayCollection = new ArrayCollection();
			switch (entity) {
				case "Account" :
					tmp.addItem({name: 'account', icon: accountImg});
					tmp.addItem({name: 'accountDefault', icon: accountDefaultImg});
					return tmp;
				case "Asset" :
					tmp.addItem({name: 'asset', icon: assetImg});
					tmp.addItem({name: 'assetDefault', icon: assetDefaultImg});
					return tmp;
				case "Contact" :
					tmp.addItem({name: 'contact', icon: contactImg});
					tmp.addItem({name: 'contactDefault', icon: contactDefaultImg});
					return tmp;
				case "Opportunity" :
					tmp.addItem({name: 'opportunity', icon: opportunityImg});
					tmp.addItem({name: 'opportunityDefault', icon: opportunityDefaultImg});
					return tmp;
				case "Product" : 
					tmp.addItem({name: 'product', icon: productImg});
					tmp.addItem({name: 'productDefault', icon: productDefaultImg});
					return tmp;
				case "Service Request" : 
					tmp.addItem({name: 'service', icon: serviceImg});
					tmp.addItem({name: 'serviceDefault', icon: serviceDefaultImg});
					return tmp;
				case "Activity" :
					tmp.addItem({name: 'activity', icon: activityImg});
					tmp.addItem({name: 'activityTaskDefault', icon: activityTaskDefaultImg});
					tmp.addItem({name: 'activityAppointmentDefault', icon: activityAppointmentDefaultImg});
					tmp.addItem({name: 'activityCallDefault', icon: activityCallDefaultImg});
					return tmp;
				case "Campaign" : 
					tmp.addItem({name: 'campaign', icon: campaignImg});
					tmp.addItem({name: 'campaignDefault', icon: campaignDefaultImg});
					return tmp;
				case "Custom Object 1" :
					tmp.addItem({name: 'custom', icon: customObjectImg});
					tmp.addItem({name: 'customDefault', icon: customObjectDefaultImg});
					return tmp;
				case "Lead" : 
					tmp.addItem({name: 'lead', icon: leadImg});
					tmp.addItem({name: 'leadDefault', icon: leadDefaultImg});
					return tmp;
				case "Custom Object 2" :
					tmp.addItem({name: 'custom2', icon: customObject2Img});
					tmp.addItem({name: 'custom2Default', icon: customObject2DefaultImg});
					return tmp;
				case "Custom Object 3" :
					tmp.addItem({name: 'custom3', icon: customObject3Img});
					tmp.addItem({name: 'custom3Default', icon: customObject3DefaultImg});
					return tmp;
				case "CustomObject7" :
					tmp.addItem({name: 'custom7', icon: customObject7Img});
					tmp.addItem({name: 'custom7Default', icon: customObject7DefaultImg});
					return tmp;
				case "CustomObject14" :
					tmp.addItem({name: 'custom14', icon: customObject14Img});
					tmp.addItem({name: 'custom14Default', icon: customObject14DefaultImg});
					return tmp;
				case "CustomObject4" :
					tmp.addItem({name: 'custom4', icon: customObject4Img});
					tmp.addItem({name: 'custom4Default', icon: customObject4DefaultImg});
					return tmp;	
				case "CustomObject5" :
					tmp.addItem({name: 'custom5', icon: customObject5Img});
					tmp.addItem({name: 'custom5Default', icon: customObject5DefaultImg});
					return tmp;		
				case "CustomObject6" :
					tmp.addItem({name: 'custom6', icon: customObject8Img});
					tmp.addItem({name: 'custom6Default', icon: customObject6DefaultImg});
					return tmp;	
				case "CustomObject8" :
					tmp.addItem({name: 'custom8', icon: customObject8Img});
					tmp.addItem({name: 'custom8Default', icon: customObject8DefaultImg});
					return tmp;
				case "CustomObject9" :
					tmp.addItem({name: 'custom9', icon: customObject9Img});
					tmp.addItem({name: 'custom9Default', icon: customObject9DefaultImg});
					return tmp;		
				case "CustomObject10" :
					tmp.addItem({name: 'custom10', icon: customObject10Img});
					tmp.addItem({name: 'custom10Default', icon: customObject10DefaultImg});
					return tmp;			
				case "Picklist" :
					tmp.addItem({name: 'picklist', icon: picklistImg});
					return tmp;
				case "Territory" :
					tmp.addItem({name: 'territory', icon: territoryImg});
					return tmp;
				case "Note" :
					tmp.addItem({name: 'Note', icon: medEdImg});
					tmp.addItem({name: 'NoteDefault', icon: noteDefaultImg});
					return tmp;	
				case "MedEd Event" :
					tmp.addItem({name: 'MedEd', icon: noteImg});
					tmp.addItem({name: 'MedEdDefault', icon: medEdDefaultImg});
					return tmp;			
					
				default: return null;
			}
		}		
		
		public static function getFlagIcon():ArrayCollection{
			var array:ArrayCollection = new ArrayCollection();
			var object:Object = new Object();
			object.data = "flag_blue";
			object.icon = blueIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_green";
			object.icon = greenIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_orange";
			object.icon = orangeIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_pink";
			object.icon = pinkIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_purple";
			object.icon = purpleIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_red";
			object.icon = redIcon;
			object.label = "";
			array.addItem(object);
			
			object = new Object();
			object.data = "flag_yellow";
			object.icon = yellowIcon;
			object.label = "";
			array.addItem(object);
			return array;
		}
		
		public static function getImage(entity:String, subtype:int = 0, isPrimary:Boolean = false):Class{
//			switch (entity) {
//				case "Account" : return accountImg;
//				case "Contact" : return contactImg;
//				case "Opportunity" : return opportunityImg;
//				case "Product" : return productImg;
//				case "Service Request" : return serviceImg;
//				case "Activity" : return activityImg;
//				case "Campaign" : return campaignImg;
//				case "Custom Object 1" : return customObjectImg;
//				case "Picklist" : return picklistImg;
//				case "Lead" : return leadImg;
//				default: return null;
//			}
			//MOny--hack title....
			if(entity == Database.accountCompetitorDao.entity){
				entity = "Account";	
			}
			if(entity==Database.accountPartnerDao.entity){
				entity = "Account";
			}
			
			if(entity==Database.opportunityPartnerDao.entity){
				entity = "Opportunity";
			}
			
			if(entity==Database.opportunityProductRevenueDao.entity){
				entity = "Opportunity";
			}
			
			if(entity == Database.relatedContactDao.entity){
				entity = Database.contactDao.entity;
			}
			
			
			
			if(entity.indexOf("Note")!=-1 && entity.indexOf(".")!=-1){
				entity = entity.substring( entity.indexOf(".")+1);
			}
			
			
			
			
			if( entity == MainWindow.DASHBOARD ) return chartBar;
			
			if( entity == MainWindow.CHAT ) return chat;
			
			if( entity == MainWindow.DAILY_AGENDA ) return dailyAgenda;
			
			if( entity == "GCalendar" ) return gCalendarIcon;
			
			if( entity == "Picklist" ) return picklistImg;
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,subtype);
			
			if( isPrimary ){
				if ( StringUtils.endsWith(customLayout.custom_layout_icon, "Default") ){
					return pContactDefaultIcon;
				}else {
					return pContactIcon;
				}
			}
			//mony--fixed npe
			if(customLayout==null){
				return null;
			}
			return getIconByName(customLayout.custom_layout_icon); 
		}

		public static function getImageBW(entity:String, subtype:int = 0):Class{
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,subtype);
			return getIconBWByEntity(customLayout.custom_layout_icon + "BW"); 
		}	
		
		public static function getIconBWByEntity(entity:String): Class {
			switch(entity){
				case "accountBW": return accountBWImg;
				case "accountDefaultBW": return accountDefaultBWImg;
				case "assetBW": return assetBWImg;
				case "assetDefaultBW": return assetDefaultBWImg;
				case "contactBW" : return contactBWImg;
				case "contactDefaultBW": return contactDefaultBWImg;
				case "opportunityBW" : return opportunityBWImg;
				case "opportunityDefaultBW": return opportunityDefaultBWImg;
				case "activityBW": return activityBWImg;
				case "activityTaskDefaultBW": return activityTaskDefaultBWImg;
				case "activityAppointmentDefaultBW": return activityAppointmentDefaultBWImg;
				case "serviceBW": return serviceBWImg;
				case "serviceDefaultBW": return serviceDefaultBWImg;
				case "campaignBW": return campaignBWImg;
				case "campaignDefaultBW": return campaignDefaultBWImg;
					
				case "customBW": return customBWImg;
				case "customDefaultBW": return customDefaultBWImg;
				
				case "custom2BW": return custom2BWImg;
				case "custom2DefaultBW": return custom2DefaultBWImg;
					
				case "custom3BW": return custom3BWImg;
				case "custom3DefaultBW": return custom3DefaultBWImg;
					
				case "custom7BW": return custom7BWImg;
				case "custom7DefaultBW": return custom7DefaultBWImg;
					
				case "custom14BW": return custom14BWImg;
				case "custom14DefaultBW": return custom14DefaultBWImg;
				
				case "custom4BW": return custom4BWImg;
				case "custom4DefaultBW": return custom4DefaultBWImg;
				
				case "custom5BW": return custom5BWImg;
				case "custom5DefaultBW": return custom5DefaultBWImg;	
				
				case "custom6BW": return custom6BWImg;
				case "custom6DefaultBW": return custom6DefaultBWImg;
				
				case "custom6BW": return custom6BWImg;
				case "custom6DefaultBW": return custom6DefaultBWImg;
				
				case "custom8BW": return custom8BWImg;
				case "custom8DefaultBW": return custom8DefaultBWImg;
				
				case "custom9BW": return custom9BWImg;
				case "custom9DefaultBW": return custom9DefaultBWImg;	
				
				case "custom10BW": return custom10BWImg;
				case "custom10DefaultBW": return custom10DefaultBWImg;		
					
				case "leadBW": return leadBWImg;
				case "leadDefaultBW": return leadDefaultBWImg;
					
				case "productBW": return productBWImg;
				case "productDefaultBW": return productDefaultBWImg;
					
				case "flag_blueBW":
				case "flag_greenBW":
				case "flag_orangeBW":
				case "flag_pinkBW":
				case "flag_purpleBW":
				case "flag_redBW":
				case "flag_yellowBW": return flagBWImg;
				
				case "noteBW": return noteBWImg;
				case "noteDefaultBW": return noteDefaultBWImg;
				
				case "medEdBW": return medEdBWImg;
				case "medEdDefaultBW":  medEdDefaultBWImg;	
					
				default: return null;
			}
		}		
		
		public static function getBigImage(entity:String):Class{
//			switch (entity) {
//				case "Account" : return accountBigImg;
//				case "Contact" : return contactBigImg;
//				case "Opportunity" : return opportunityBigImg;
//				case "Product" : return productBigImg;
//				case "Service Request" : return serviceBigImg;
//				case "Activity" : return activityBigImg;
//				case "Campaign" : return campaignBigImg;
//				case "Custom Object 1" : return customBigImg;
//				case "Lead" : return leadBigImg;
//				default: return null;
//			}
			switch(entity){
				case MainWindow.DASHBOARD : return chartBar;
				case MainWindow.CHAT : return chat;
				case MainWindow.DAILY_AGENDA : return dailyAgenda;
					
			}
			var customLayout:Object = Database.customLayoutDao.readSubtype(entity,0);
			switch(customLayout.custom_layout_icon){
				
				case "account": return accountBigImg;
				case "accountDefault": return accountDefaultBigImg;
				case "asset": return assetBigImg;
				case "assetDefault": return assetDefaultBigImg;
				case "contact" : return contactBigImg;
				case "contactDefault": return contactDefaultBigImg;
				case "opportunity" : return opportunityBigImg;
				case "opportunityDefault": return opportunityDefaultBigImg;
				case "activity": return activityBigImg;
				case "activityTaskDefault": return activityTaskDefaultBigImg;
				case "activityAppointmentDefault": return activityAppointmentDefaultBigImg;
				case "service": return serviceBigImg;
				case "serviceDefault": return serviceDefaultBigImg;
				case "product": return productBigImg;
				case "productDefault": return productDefaultBigImg;
				case "campaign": return campaignBigImg;
				case "campaignDefault": return campaignDefaultBigImg;
				case "custom": return customBigImg;
				case "customDefault": return customObjectDefaultBigImg;
				case "custom2": return custom2BigImg;
				case "custom2Default": return customObject2DefaultBigImg;
				case "custom3": return custom3BigImg;
				case "custom3Default": return customObject3DefaultBigImg;
				case "custom7": return custom7BigImg;
				case "custom7Default": return customObject7DefaultBigImg;
				case "custom14": return custom14BigImg;
				case "custom14Default": return customObject14DefaultBigImg;
				case "custom4": return custom4BigImg;
				case "custom4Default": return customObject4DefaultBigImg;
				case "custom5": return custom5BigImg;
				case "custom5Default": return customObject5DefaultBigImg;	
				case "custom6": return custom6BigImg;
				case "custom6Default": return customObject6DefaultBigImg;	
				case "custom8": return custom8BigImg;
				case "custom8Default": return customObject8DefaultBigImg;	
				case "custom9": return custom9BigImg;
				case "custom9Default": return customObject9DefaultBigImg;	
				case "custom10": return custom10BigImg;
				case "custom10Default": return customObject10DefaultBigImg;		
				case "lead": return leadBigImg;
				case "leadDefault": return leadDefaultBigImg;
				case "flag_blue": return blueIcon;
				case "flag_green": return greenIcon;
				case "flag_orange": return orangeIcon;
				case "flag_pink": return pinkIcon;
				case "flag_purple": return purpleIcon;
				case "flag_red": return redIcon;
				case "flag_yellow": return yellowIcon;
				case "note": return noteBigImg;
				case "noteDefault": return noteDefaultBigImg;
				case "menEd": return medEdBigImg;
				case "medEdDefault": return medEdDefaultBigImg;	
				default: return null;
			}
			
		}
		
		
		
		/**
		 * 	1) activity != Appointment 									-----------> TASK
		 *	2) activity = Appointment and CallType != 'Account Call' 	-----------> APPOINTMENT
		 *	3) activity = Appointment and CallType = 'Account Call' 	-----------> CALL
		 */
		
		public static function getActivitySubType(activity:Object):int{
			if(activity["Activity"] != "Appointment") {
				return 0; // Task Image
			}else if(activity["Activity"] == "Appointment" && activity["CallType"] != "Account Call") {
				return 1; // Appointment Image
			}else if(activity["Activity"] == "Appointment" && activity["CallType"] == "Account Call") {
				return 2; // Call Image
			}
			return 0;
		}
		
		
		public static function getImageDailyAgenda(item:Object):Class {
			return getImage("Activity", getActivitySubType(item));
		}
		
		public static function getByteArray(encoded:String):ByteArray {
			var base64Dec:Base64Decoder = new Base64Decoder();
			base64Dec.decode(encoded);
			return base64Dec.toByteArray();
		}
		
//		public static function getImageByType(item:Object):Class {
//			var image:Class;
//			if (item == null) return null;
//			switch (item.gadget_type) {
//				case 'A': return accountImg; //Account
//				case 'C': return contactImg; //Contact
//				case 'O': return opportunityImg; //Opportunity
//				case 'Y': return activityImg; //Activity
//				case 'P': return productImg; //Product
//				case 'S': return serviceImg; //ServiceRequest
//				case 'G': return campaignImg; //Campaign
//				case 'B': return customObjectImg; //CustomObject
//				default: return null;
//			}
//			return image;
//		}
		
	}	
}