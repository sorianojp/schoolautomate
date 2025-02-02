<%@ page language="java" import="utility.*, enrollment.SetParameter, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Lock Credential Access</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	function PageAction(strAction) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to locking information?'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","lock_stud_batch.jsp");

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
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"lock_stud_batch.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
	
	int iSearchResult = 0;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};

	Vector vRetResult = null;
	SetParameter sp = new SetParameter();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(sp.operateOnDeptLockingBatch(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = sp.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Student lock information successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Student advising successfully locked by department.";
		}
	}
	
	vRetResult = sp.operateOnDeptLockingBatch(dbOP, request, 4);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = sp.getErrMsg();
	}
	else
		iSearchResult = vRetResult.size()/10;
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./lock_stud_batch.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::: LOCK ADIVISING :::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%" valign="top"><br />ID Number in CSV: </td>
	  	    <td width="80%">
			<textarea name="id_batch" style="font-size:9px" cols="125" rows="10" class="textbox" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=WI.fillTextValue("id_batch")%></textarea>
			</td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>SY/Term: </td>
	  	    <td>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
				%>
				<select name="semester">
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
				</select></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lock Target: </td>
	  	  <td>
		  <%
		  strTemp = WI.fillTextValue("dept_1");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_1" value="23" <%=strTemp%>> Accounting
		  
		  <%
		  strTemp = WI.fillTextValue("dept_2");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_2" value="27" <%=strTemp%>> Registrar
		  
		  <%
		  strTemp = WI.fillTextValue("dept_3");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_3" value="24" <%=strTemp%>> Student Affairs
		  </td>
	  	</tr>
		
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lock Reason:</td>
		  	<td>
				<textarea name="lock_reason" style="font-size:11px" cols="107" rows="1" class="textbox" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=WI.fillTextValue("lock_reason")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td><strong><u>VIEW OPTION</u></strong></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Dept Locked: </td>
		    <td>
		  <%
		  strTemp = WI.fillTextValue("dept_1_view");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_1_view" value="23" <%=strTemp%>> Accounting
		  
		  <%
		  strTemp = WI.fillTextValue("dept_2_view");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_2_view" value="27" <%=strTemp%>> Registrar
		  
		  <%
		  strTemp = WI.fillTextValue("dept_3_view");
		  if(strTemp.length() > 0) 
		  	strTemp = " checked";
		  else
		  	strTemp = "";
		  %>
		  <input type="checkbox" name="dept_3_view" value="24" <%=strTemp%>> Student Affairs
			
			
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>ID Number: </td>
		    <td>
				<input name="stud_id_view" type="text" size="16" value="<%=WI.fillTextValue("stud_id_view")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('stud_id_view','stud_id_view_');">&nbsp;
				<label id="stud_id_view_" style="position:absolute; width: 300px"></label></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		    <td height="25">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to show results.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0" /></a>
					<font size="1">Click to block student credential.</font>
					&nbsp;
					
				<%}else{%>
					Not authorized to lock advising.
		            <%}%>		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="100%" height="15">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LOCK ADVISING APPLIED IN BATCH :::</strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="7">
				<strong>Total Results: <%=iSearchResult%></strong> Note: Records listed are locked by batch</td>
			<td class="thinborderBOTTOM" height="25" colspan="2">&nbsp;</td>
		</tr>
		<tr style="font-weight:bold">
			<td height="22" class="thinborder" align="center" width="10%" style="font-size:9px;">Student ID</td>
		    <td class="thinborder" align="center" width="20%" style="font-size:9px;">Student Name </td>
		    <td class="thinborder" align="center" width="10%" style="font-size:9px;">Lock Date</td>
			<td class="thinborder" align="center" width="5%" style="font-size:9px;">SY/Term</td>
			<td class="thinborder" align="center" width="10%" style="font-size:9px;">Lock By Dept </td>
			<td class="thinborder" align="center" width="5%" style="font-size:9px;">Lock Priority </td>
		    <td class="thinborder" align="center" width="5%" style="font-size:9px;">Locked By </td>
			<td class="thinborder" align="center" width="30%" style="font-size:9px;">Reason</td>
		    <td class="thinborder" align="center" width="5%" style="font-size:9px;">Delete</td>
		</tr>
	<%	int iMaxDisp = 0; 
		for(int i = 0; i < vRetResult.size(); i += 10, ++iMaxDisp){%>
		<tr>
			<td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%> - <%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
		    <td class="thinborder" align="center">
			<input type="checkbox" name="lock_<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i)%>">
			</td>
		</tr>
	<%}%>
	<input type="hidden" name="max_disp" value="<%=iMaxDisp%>" />
	</table>		
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td align="center">
			  <input type="button" name="proceed_btn" value=" Delete Selected Records " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onclick="PageAction(0)" />
			</td>
		</tr>
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
	
	<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>