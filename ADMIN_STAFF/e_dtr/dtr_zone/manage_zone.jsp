<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<!--
	<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
-->
<title>Manage Zones</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/formatFloat.js"></script>
<script language="javascript">

	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this eDTR zone?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.is_first_load.value = '1';
		document.form_.submit();
	}
	
	function CancelOperation(){
		location = "./manage_zone.jsp";
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	function AddFacDTRRoom(strLocIndex) {
		var loadPg = "./add_fac_room.jsp?loc_index="+strLocIndex;
		var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
</script>
<%		
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD-DTR OPERATIONS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Zone","manage_zone.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	Vector vEditInfo = null;
	Vector vRetResult = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
	DTRZoning dtrz = new DTRZoning();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(dtrz.createDTRZone(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = dtrz.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "eDTR zone successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "eDTR zone successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "eDTR zone successfully edited.";
				
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = dtrz.createDTRZone(dbOP, request, 4);
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = dtrz.createDTRZone(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = dtrz.getErrMsg();
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	boolean bolIsVMUF = strSchCode.startsWith("VMUF");
	
	//if fac dtr applicable, show faculty room number, and allow update room number catered by DTR. 
	boolean bolIsFacDTRApplicable =  new ReadPropertyFile().getImageFileExtn("IS_FACULTY_APPLICABLE","0").equals("1");
	
%>
<body bgcolor="#D2AE72">

<form name="form_" action="./manage_zone.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="2" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: MANAGE ZONES ::::</strong></font></td>
    	</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
  	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsVMUF){%>
		<tr>
			<td height="25">&nbsp;</td>
    		<td colspan="2">
				<%
					if(WI.fillTextValue("is_standalone").length() > 0)
						strTemp = " checked";				
					else {
						if(vEditInfo != null && vEditInfo.elementAt(3) != null && WI.fillTextValue("is_first_load").length() > 0)
							strTemp = " checked";
						else	
							strTemp = "";
					}
				%>
				<input name="is_standalone" type="checkbox" value="1"<%=strTemp%> onclick="ReloadPage();">
			  <font size="1" color="#0000FF">Check if eDTR zone is standalone. Standalone Terminals are having their own DTR Application and SQL Server Installed. Pls consult Support for more detail </font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>DB Property: </td>
			<td style="font-size:9px;">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("db_property");
				%>
				<input type="text" name="db_property" value="<%=strTemp%>" class="textbox" size="16" maxlength="32"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				(consult tech support for information about this field)	
		  </td>
		</tr>
<!--
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sync Interval</td>
			<td style="font-size:9px;">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("sync_intv");
				%>
				<input name="sync_intv" type="text" class="textbox" value="<%=strTemp%>" size="16" maxlength="12"
					onkeyup="AllowOnlyInteger('form_','sync_intv')" onfocus="style.backgroundColor='#D3EBFF'"
					onblur="AllowOnlyInteger('form_','sync_intv');style.backgroundColor='white'" />
				(in minutes)</td>
		</tr>
--><input type="hidden" name="sync_intv" value="60" />
	<%}%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="11%">Location: </td>
			<td width="86%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("loc_name");
				%>
		  <input type="text" name="loc_name" value="<%=strTemp%>" class="textbox" size="32" maxlength="64"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		  <%if(strSchCode.startsWith("CIT")){%>
			  <input type="checkbox" name="nas_only" checked="checked" value="checked" onclick="return false"> For NAS only
		  <%}%>
					</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>IP Address: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("ip_addr");
				%>
				<input type="text" name="ip_addr" value="<%=strTemp%>" class="textbox" size="16" maxlength="15"
	  				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
<%if(bolIsVMUF){%>
		<tr>
			<td height="15" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="get_online_stat" value="checked" <%=WI.fillTextValue("get_online_stat")%> onclick="ReloadPage();"> 
			Incldue Online status (Page loads slow in case there is no connection to a remote terminal)
			
			</td>
		</tr>
<%}%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
				if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<%}else {
						if(vEditInfo!=null){%>
							<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
								<img src="../../../images/edit.gif" border="0"></a>
						<%}
					}%>
					<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0" /></a>
				<%}else{%>
					Not authorized to add/edit zone information.
		<%}%>	
		<div align="right"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0" /></a> Reload Page</div>	
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
      		<td height="20" colspan="10" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>eDTR ZONE LIST</strong></div></td>
    	</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="5%"><strong>Count</strong></td>
			<td align="center" class="thinborder" width="11%"><strong>IP Address</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Location</strong></td>
<%if(bolIsVMUF){%>
			<td align="center" class="thinborder" width="12%"><strong>DB Property</strong></td>
			<!--<td align="center" class="thinborder" width="12%"><strong>Sync Interval</strong></td>-->
			<td align="center" class="thinborder" width="12%"><strong>Next Sync Time</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Last Run Msg</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Online Status</strong></td>
<%}if(bolIsFacDTRApplicable){%>
            <td align="center" class="thinborder" width="12%"><strong>Faculty DTR Room Number</strong></td>
<%}%>
			<td align="center" class="thinborder" width="12%"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 9, iCount++){
			String strIsValid = (String)vRetResult.elementAt(i+8);
			if(strIsValid.equals("0"))//if not valid
				strErrMsg = "#FFFF00";
			else
				strErrMsg = "#FFFFFF";
	%>
		<tr bgcolor="<%=strErrMsg%>">
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
<%if(bolIsVMUF){%>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
			<!--<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>-->
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/A")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
<%}if(bolIsFacDTRApplicable){%>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<b>Not Applicable</b>")%><br />
			<a href="javascript:AddFacDTRRoom('<%=vRetResult.elementAt(i)%>')">Add Room</a>
			</td>
<%}%>
			<td align="center" class="thinborder" style="font-size:9px;">
				<%
				if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel  == 2){
						if(strIsValid.equals("0")){%>(Deleted)<%}else{%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
					<%}
					}
				}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="is_first_load" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>