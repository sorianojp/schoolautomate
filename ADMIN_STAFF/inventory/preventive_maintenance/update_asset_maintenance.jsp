<%@ page language="java" import="utility.*, java.util.Vector"%>
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>




function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}

	if(strAction == 2){
		if(!confirm("Information will be finalized. Click OK to proceed."))
			return;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value = strAction;
	document.form_.prepareToEdit.value = "0";
	if(strAction == "3"){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
	}
	
	document.form_.submit();
}

function Refresh(){
	document.form_.prepareToEdit.value = "0";
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
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
								"Admin/staff-Inventory -PREVENTIVE MAINTENANCE","update_asset_maintenance.jsp");
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

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
inventory.InvPreventiveMaintenance prevMain = new inventory.InvPreventiveMaintenance();

Vector vItemDetail = null;
Vector vRetResult = null;
Vector vEditInfo = null;
	
strTemp = WI.fillTextValue("page_action");		
if(strTemp.length() > 0) {		
	if(prevMain.operateOnMaintenanceUpdateSchedule(dbOP, request, Integer.parseInt(strTemp)) == null )
		strErrMsg = prevMain.getErrMsg();
	else{			
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully updated.";		
		strPrepareToEdit = "0";			
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
		
		if(strPrepareToEdit.equals("1")){
			vEditInfo = prevMain.operateOnMaintenanceUpdateSchedule(dbOP, request, 3, strInvEntryIndex, strIsCPU);
			if(vEditInfo == null)
				strErrMsg = prevMain.getErrMsg();
		}
		
		vRetResult = prevMain.operateOnMaintenanceUpdateSchedule(dbOP, request, 4, strInvEntryIndex, strIsCPU);
		if(vRetResult != null && vRetResult.size() > 0)
			iElemCount = prevMain.getElemCount();
	}
}

			
		
		
			
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form name="form_" action="update_asset_maintenance.jsp" method="post">
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
	
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	    <td height="25">
		<font color="#FF0000">
		<strong>NOTE:</strong> <br>1. Once updated, information cannot be changed.<br>
		2. Additional schedule can be added, if the main maintenance schedule is not done/complete.<br>	
		3. Once complete, next scheduled maintenance will be created.
		</font>
		</td>
	    </tr>
	<tr><td align="center" height="25"><strong>MAINTENANCE SCHEDULE</strong></td></tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="5%" height="23" align="center" class="thinborder"><strong>COUNT</strong></td>
		<td width="16%" align="center" class="thinborder"><strong>DATE</strong></td>
		<td width="19%" align="center" class="thinborder"><strong>TYPE</strong></td>
		<td width="19%" align="center" class="thinborder"><strong>STATUS</strong></td>
		<td width="27%" align="center" class="thinborder"><strong>REMARKS</strong></td>
		<td width="14%" align="center" class="thinborder"><strong>OPTIONS</strong></td>
	</tr>
<%

int iCount = 0;
for(int i  =0 ; i < vRetResult.size() ; i += iElemCount){%>
	<tr>
	    <td height="23" align="right" class="thinborder"><%=++iCount%>.&nbsp;</td>
	    <td align="center" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
	    <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+2),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp;")%></td>
	    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
	    <td align="center" class="thinborder">&nbsp;
		<%
		/**
		once updated, the update button will not show anymore.		
		show update button, if status is null
		show add button if status is not  null
		*/
		if(WI.getStrValue(vRetResult.elementAt(i+6)).equals("0") && iAccessLevel > 1){
		if(vRetResult.elementAt(i+3) == null){
		%>
		<a href="javascript:PageAction('3','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/update.gif" border="0"></a>
		
		<%if(WI.getStrValue(vRetResult.elementAt(i+7)) != null){%>
		
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		<%}}
		//status is not null and not complete/done
		if(vRetResult.elementAt(i+3) != null){%>
		&nbsp;		
		<a href="javascript:PageAction('5','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/add.gif" border="0"></a>
		<%}}%>
		</td>
    </tr>
<%}%>
</table>
<%if(vEditInfo != null && vEditInfo.size() > 0 && strPrepareToEdit.equals("1")){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="3%" height="25"></td>
		<td colspan="2"><strong>UPDATE SCHEDULE DETAILS</strong></td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td width="17%">Schedule Date</td>
	    <td width="80%"><input name="maintenance_date" type="text" size="10" maxlength="10" value="<%=vEditInfo.elementAt(1)%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.maintenance_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td>Type</td>
	    <td>
		<input name="maintenance_type" type="text" class="textbox" size="30" 
			onblur='style.backgroundColor="white"' 
			onFocus="style.backgroundColor='#D3EBFF'"
			value="<%=vEditInfo.elementAt(2)%>">		</td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td>Status</td>
	    <td><input name="maintenance_status" type="text" class="textbox" size="30" 
			onblur='style.backgroundColor="white"' 
			onFocus="style.backgroundColor='#D3EBFF'"
			value="<%=WI.getStrValue(vEditInfo.elementAt(3))%>"></td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td>Remarks</td>
	    <td><textarea name="remarks" rows="3" cols="50"><%=WI.getStrValue(vEditInfo.elementAt(3))%></textarea></td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("is_complete");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
	    <td>
		<input type="checkbox" name="is_complete" value="1" <%=strErrMsg%>>Click if the maintenance status is done/complete.		</td>
	</tr>
	<tr>
	    <td height="25"></td>
	    <td>&nbsp;</td>
	    <td>
		<a href="javascript:PageAction('2','')"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to update information</font>
		</td>
	</tr>
	
</table>

<%}//end vEditInfo
}//end vRetResult
}//end vItemDetail%>
  
 
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
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>