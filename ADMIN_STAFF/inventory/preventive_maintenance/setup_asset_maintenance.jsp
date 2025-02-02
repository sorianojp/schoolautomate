<%@ page language="java" import="utility.*, inventory.InvPreventiveMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src="../../../jscript/common.js" ></script>
<script language="javascript"  src="../../../Ajax/ajax.js" ></script>
<script language="javascript"  src="../../../jscript/date-picker.js" ></script>
<script>

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateFrequency(){
	var pgLoc = "./frequency_management.jsp";
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function Refresh(){
	document.form_.page_action.value = "";
	document.form_.submit();
}

function AjaxSetNextSched(){
	if(!document.form_.last_maintenance_date)
		return;
	
	var strDate = document.form_.last_maintenance_date.value;
	
	var	objCOAInput = document.getElementById("coa_info");		
	
	var strFreqIndex = document.form_.frequency_index.value;	
	
	if(strFreqIndex.length == 0 || strDate.length == 0){
		objCOAInput.innerHTML = "";
		return ;
	}
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
		
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6406&frequency_index="+strFreqIndex+
		"&last_maintenance_date="+strDate;
	this.processRequest(strURL);
}

function FocusID(){
	document.form_.property_no.focus();
}

</script>
</head>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-PREVENTIVE_MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Inventory -PREVENTIVE MAINTENANCE","setup_asset_maintenance.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
	
inventory.InvPreventiveMaintenance prevMain = new inventory.InvPreventiveMaintenance();

Vector vItemDetail = null;
Vector vRetResult = null;
	
	
strTemp = WI.fillTextValue("page_action");		
if(strTemp.length() > 0) {		
	if(prevMain.operateOnMaintenanceDetails(dbOP, request, Integer.parseInt(strTemp)) == null )
		strErrMsg = prevMain.getErrMsg();
	else{			
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully saved.";					
	}
}	
	


String strInvEntryIndex = null;
String strIsCPU = null;
int iElemCount = 0;
if(WI.fillTextValue("property_no").length() > 0){
	vItemDetail = prevMain.getPropertyInfo(dbOP, request);
	if(vItemDetail == null)
		strErrMsg = prevMain.getErrMsg();
	else{
		strInvEntryIndex = (String)vItemDetail.elementAt(0);
		strIsCPU = (String)vItemDetail.elementAt(14);
		vRetResult = prevMain.operateOnMaintenanceDetails(dbOP, request, 4, strInvEntryIndex, strIsCPU);
		if(vRetResult != null && vRetResult.size() > 0)
			iElemCount = prevMain.getElemCount();
	}
}

			
		
		
			
%>
<body bgcolor="#D2AE72" onLoad="AjaxSetNextSched();FocusID();">
<form name="form_" action="setup_asset_maintenance.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SETUP ASSET FOR MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="76%" height="25"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>
  </table>

	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Property No.</td>
		<td><input name="property_no" type="text" class="textbox" size="20" 
			onblur='style.backgroundColor="white"' 
			onFocus="style.backgroundColor='#D3EBFF'"
			value="<%=WI.fillTextValue("property_no")%>">
			&nbsp;
			<a href="javascript:Refresh();"><img src="../../../images/refresh.gif" border="0" align="absmiddle"></a>
			
		</td>
	</tr>
  </table>
  
<%
if(vItemDetail != null && vItemDetail.size() > 0){
%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	    <td height="20" colspan="6"><hr size="1%"></td>
	    </tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="17%">Category</td>
		<td colspan="2"><%=WI.getStrValue(vItemDetail.elementAt(4))%></td>
		<td width="12%">Property No</td>
		<td width="27%"><%=WI.fillTextValue("property_no")%></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Classification</td>
	    <td colspan="2"><%=WI.getStrValue(vItemDetail.elementAt(3))%></td>
	    <td>Serial No</td>
	    <td><%=WI.getStrValue(vItemDetail.elementAt(6))%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Description</td>
	    <td colspan="2"><%=WI.getStrValue(vItemDetail.elementAt(2))%></td>
	    <td>Product No</td>
	    <td><%=WI.getStrValue(vItemDetail.elementAt(7))%></td>
	    </tr>
	<tr>
	    <td height="25" colspan="6"><strong>LOCATION</strong></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Building</td>
	    <td colspan="4"><%=WI.getStrValue(vItemDetail.elementAt(12))%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Room No. </td>
	    <td colspan="4"><%=WI.getStrValue(vItemDetail.elementAt(13))%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>College / Office </td>
		<%
		strTemp = WI.getStrValue(vItemDetail.elementAt(8));
		strErrMsg = WI.getStrValue(vItemDetail.elementAt(10));
		if(strTemp.length() > 0 && strErrMsg.length() > 0)
			strTemp += " / ";
		strTemp += strErrMsg;
		%>
	    <td colspan="4"><%=strTemp%></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="2">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
	<tr>
	    <td height="25" colspan="6"><strong>MAINTENANCE DETAILS</strong></td>
	    </tr>
	<!--<tr>
	    <td height="25">&nbsp;</td>
	    <td colspan="5"><font color="#FF0000"><strong>NOTE for start date:</strong><br><font size="1">Last Maintenance Date is used for old items.
		<br>Next Maintenance Date is for newly acquired items.<br>If both date specified, Last Maintenance Date will be used in the system.</font></font></td>
	    </tr>-->
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Frequency</td>
	    <td colspan="4">
		<select name="frequency_index" style="width:150px;" onChange="AjaxSetNextSched();">
		<%
		strTemp = " from INV_PREV_MAINTENANCE_FREQ order by is_preload desc, frequency_name";
		%>
			<%=dbOP.loadCombo("FREQUENCY_INDEX","FREQUENCY_NAME",strTemp , WI.fillTextValue("frequency_index"), false)%>
		</select>		
		<a href="javascript:UpdateFrequency();"><img src="../../../images/update.gif" border="0"></a>
		<font size="1">Click to update frequency list</font>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Type</td>
	    <td colspan="4">
		<select name="maintenance_type_index" style="width:200px;">
		<%
		strTemp = " from INV_PREV_MAINTENANCE_TYPE order by MAINTENANCE_TYPE_NAME";
		%>
			<%=dbOP.loadCombo("MAINTENANCE_TYPE_INDEX","MAINTENANCE_TYPE_NAME",strTemp , WI.fillTextValue("maintenance_type_index"), false)%>
		</select>		
		<a href='javascript:viewList("INV_PREV_MAINTENANCE_TYPE","MAINTENANCE_TYPE_INDEX","MAINTENANCE_TYPE_NAME","MAINTENANCE TYPE", 
			"INV_PREV_MAINTENANCE", "MAINTENANCE_TYPE_INDEX"," and is_valid = 1","","maintenance_type_index");'><img src="../../../images/update.gif" border="0"></a>
			<font size="1">Click to update type list</font>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Last Maintenance Date </td>
	    <td width="16%">
		<input name="last_maintenance_date" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("last_maintenance_date")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="AjaxSetNextSched();style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.last_maintenance_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>		</td>
	    <td colspan="3">System generated next maintenance date : <strong><label id="coa_info"></label></strong></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Next Maintenance Date </td>
	    <td>
		<input name="next_maintenance_date" type="text" size="10" maxlength="10" value="<%=WI.fillTextValue("next_maintenance_date")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.next_maintenance_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>		</td>
	    <td colspan="3" valign="top"></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Remarks</td>
	    <td colspan="4"><textarea name="remarks" rows="3" cols="50"><%=WI.fillTextValue("remarks")%></textarea></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td colspan="4">
		<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>		</td>
	    </tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
  	    <td height="25"><strong style="color:#FF0000;">NOTE:</strong> <font color="#0000FF">Information at TOP is the one used in the system.</font></td>
  	    </tr>
  	<tr>
		<td align="center" height="25"><strong>LIST OF SETUP FOR ASSET MAINTENANCE</strong></td>
	</tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  	<tr>
		<td width="18%"align="center" rowspan="2" class="thinborder">FREQUENCY</td>
		<td width="26%" rowspan="2" align="center" class="thinborder">TYPE</td>
		<td class="thinborder" height="22"  colspan="2" align="center">MAINTENANCE DATE</td>
		<td width="30%" rowspan="2"  align="center"class="thinborder">REMARKS</td>
	</tr>
  	<tr>
  	    <td width="13%" height="22" align="center" class="thinborder">LAST</td>
  	    <td width="13%" align="center" class="thinborder">NEXT</td>
  	</tr>
	<%for(int i = 0; i < vRetResult.size(); i+=iElemCount){%>
	<tr>
		<td height="25" class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+4)%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
	</tr>
	<%}%>
  </table>
<%}}%>
  
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr> 
      <td width="76%" height="25">&nbsp;</td>
    </tr>
	<tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

  	<input type="hidden" name="info_index"  value="<%=WI.fillTextValue("info_index")%>">	
    <input type="hidden" name="page_action">

	
	<input type="hidden" name="inv_entry_index" value="<%=strInvEntryIndex%>">	
	<input type="hidden" name="is_cpu" value="<%=strIsCPU%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>