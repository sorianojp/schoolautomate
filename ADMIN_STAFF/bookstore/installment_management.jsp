<%@ page language="java" import="utility.*, bookstore.InstallmentManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Installment Management</title></head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this installment?'))
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
		document.form_.submit();
	}
	
	function RefreshPage() {
		location = "./installment_management.jsp";
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","installment_management.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PRICE MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security

	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo  = null; 
	Vector vRetResult = null;
	
	InstallmentManagement im = new InstallmentManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(im.operateOnInstallments(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = im.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Installment successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Installment successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Installment successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	int iSearchResult = 0;
	vRetResult = im.operateOnInstallments(dbOP, request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = im.getErrMsg();
		
	if(strPrepareToEdit.equals("1")){
		vEditInfo = im.operateOnInstallments(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = im.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./installment_management.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: INSTALLMENT MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Installment Code:</td>
		  	<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("installment_code");
				%>
			<input type="text" name="installment_code" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="16" maxlength="16" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Installment Name: </td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("installment_name");
				%>
			<input type="text" name="installment_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=strTemp%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Coverage:</td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("date_fr");
				%>
				<input name="date_fr" type="text" class="textbox" value="<%=strTemp%>" size="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" tabindex="-1"
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				to 
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
					else
						strTemp = WI.fillTextValue("date_to");
				%>
				<input name="date_to" type="text" class="textbox" value="<%=strTemp%>" size="10"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="-1">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" tabindex="-1"
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<font size="1">Leave date to value empty if up to current date.</font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>SY/Term: </td>
		  	<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("offering_sem");
				%>
				<select name="offering_sem">
              	<%if(strTemp.equals("1")){%>
              		<option value="1" selected>1st Sem</option>
              	<%}else{%>
              		<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
              		<option value="2" selected>2nd Sem</option>
              	<%}else{%>
              		<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
              		<option value="3" selected>3rd Sem</option>
              	<%}else{%>
              		<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
              		<option value="0" selected>Summer</option>
              	<%}else{%>
              		<option value="0">Summer</option>
              	<%}%>
            	</select>
				<%
					//WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("sy_from");
				%>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<%
					//WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"))
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("sy_to");
				%>
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>No. of Installments: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("num_installments");
				%>
				<input type="text" name="num_installments" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','num_installments');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyInteger('form_','num_installments')" size="5" maxlength="10" /></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("is_basic");
						
					if(strTemp.equals("2"))
						strErrMsg = " checked";
					else
						strErrMsg = "";
				%>
				<input type="checkbox" name="is_basic" <%=strErrMsg%> value="2"/>
				<font size="1">Check if this is for Basic Education</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td>
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');"><img src="../../images/save.gif" border="0"></a>
						<font size="1">Click to save installment.</font>
					    <%}else {
						if(vEditInfo!=null){%>
							<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
								<img src="../../images/edit.gif" border="0"></a>
							<font size="1">Click to edit installment.</font>
						    <%}
					}%>
					<a href="javascript:RefreshPage();"><img src="../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to save installment information.
				    <%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>:::  INSTALLMENT LISTING ::: </strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Installment Code</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Installment Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Coverage</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>SY/Term</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>No. of Installments</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Type</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<% 	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i+=10, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> - <%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+5))]%>/<%=(String)vRetResult.elementAt(i+6)%>-<%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder">&nbsp;<%=Integer.parseInt((String)vRetResult.elementAt(i+9))%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				if(strTemp.equals("1"))//collge
					strTemp = "College";
				else
					strTemp = "Basic Education";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../images/delete.gif" border="0"></a>
					<%}%>
				<%}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
