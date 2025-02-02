<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">


function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
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
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

Vector vRetResult = new Vector();
ParentRegistration prSMS = new ParentRegistration();
if(WI.fillTextValue("parent_i").length() > 0){
	vRetResult = prSMS.operateOnEditInfo(dbOP, request, 0);
	if(vRetResult == null) 
		strErrMsg = prSMS.getErrMsg();
}
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && vRetResult != null) {
	if(prSMS.operateOnEditInfo(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Information successfully updated.";
		vRetResult = prSMS.operateOnEditInfo(dbOP, request, 0);
	}
	else	
		strErrMsg = prSMS.getErrMsg();
}

%>
<form action="./edit_parent_info.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          UPDATE PARENT REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>       
		  <td  colspan="6" height="25"><strong>Parent's Name</strong></td>
		</tr>
		<tr>
		  <td width="36">&nbsp;</td>       
		  <td width="242" align="right">Last Name &nbsp;</td>	  
		  <td width="936" colspan="3"><input type="text" name="last_name" value="<%=vRetResult.elementAt(2)%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/> </td>
		</tr>
		
		<tr>
		  <td valign="top">&nbsp;</td>  
			
			<td width="242" align="right">First Name &nbsp;</td>
			<td colspan="3"><input type="text" name="first_name" value="<%=vRetResult.elementAt(0)%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/>  </td>
		</tr>
		
		<tr>
		  <td valign="top">&nbsp;</td> 
		  
		  <td width="242" align="right">Middle Name &nbsp;</td>
		  <td colspan="3"><input type="text" name="middle_name" value="<%=WI.getStrValue(vRetResult.elementAt(1))%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
		  <td width="21%" style="font-size:9px"><a href="javascript:PageAction('1')"><img src="../../images/update.gif" border="0"></a> Update Name </td>
	  </tr>
		<tr><td colspan="6">&nbsp;</td></tr>
		<tr>       
		  <td  colspan="6" height="25"><strong>Password Information </strong></td>
		</tr>
		
		<tr>
		  <td align="right">&nbsp;</td>       
		  <td width="242" align="right">Password &nbsp;</td>	  
		  <td colspan="3"><input type="password" name="password" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/>					
					</td>
		</tr>
		<tr>
		  <td align="right">&nbsp;</td>       
		  <td width="242" align="right">Confirm Password &nbsp;</td>	  
		  <td colspan="3"><input type="password" name="confirm_password" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
		  <td width="21%" style="font-size:9px"><a href="javascript:PageAction('2')"><img src="../../images/update.gif" border="0"></a> Update Password </td>
	  </tr>
		<tr><td colspan="6">&nbsp;</td></tr>
		<tr>
		  <td>&nbsp;</td>
			<td align="right">Contact Number(Mobile) &nbsp;</td>
			<td colspan="3">
			<input type="text" name="mobile_parent_no" 			
				 value="<%=WI.getStrValue(vRetResult.elementAt(3))%>" 
				 class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';"/></td>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td>&nbsp;</td>
		  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
		  <td width="21%" style="font-size:9px"><a href="javascript:PageAction('3')"><img src="../../images/update.gif" border="0"></a> Update Contact Number </td>
	  </tr>
		<tr><td colspan="6">&nbsp;</td></tr>
		<tr>
				<td height="15" colspan="6">
				
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td height="25" colspan="4"><strong>Contact Address</strong></td></tr>
							<tr>
							  <td width="4%">&nbsp;</td>
								<td height="25" width="19%">House no./ Street / Barangay </td>
								<td height="25" colspan="2">
									<input name="contact_address" type="text" value="<%=WI.getStrValue(vRetResult.elementAt(5))%>" 
										size="72" class="textbox" maxlength="128"
										onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"></td>
							</tr>
							<tr>
							  <td>&nbsp;</td>
								<td>City/Town/Province/Zip</td>
								<td colspan="2">							
								<input name="contact_address_city" type="text" value="<%=WI.getStrValue(vRetResult.elementAt(6))%>" 
								size="72" class="textbox" maxlength="128" 
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"></td>
							</tr>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
					      <td width="21%" style="font-size:9px"><a href="javascript:PageAction('4')"><img src="../../images/update.gif" border="0"></a> Update Address </td>
				      </tr>
						<tr>
						  <td>&nbsp;</td>	
							<td>Email : </td>
							<td colspan="2"><input type="text" name="email_address" value="<%=WI.getStrValue(vRetResult.elementAt(4))%>" 
									class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
									onBlur="style.backgroundColor='white';"/>							</td>
						</tr>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
					      <td width="21%" style="font-size:9px"><a href="javascript:PageAction('5')"><img src="../../images/update.gif" border="0"></a> Update Email Address </td>
				      </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td colspan="2">&nbsp;</td>
					  </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td>Assigned RF ID </td>
						  <td colspan="2">
						  <input type="text" name="rf_id1" value="<%=WI.getStrValue(vRetResult.elementAt(7))%>" 
									class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
									onBlur="style.backgroundColor='white';"/>						  </td>
					  </tr>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td width="56%" align="right" style="font-size:9px">&nbsp;</td>
					      <td width="21%" style="font-size:9px"><a href="javascript:PageAction('6')"><img src="../../images/update.gif" border="0"></a> Update RF ID</td>
				      </tr>
					</table>				</td>
	  </tr>
		
		
		<tr><td colspan="6">&nbsp;</td></tr>
		<tr>	
			<td colspan="5" align="center">&nbsp;</td>
		</tr>
  </table>
<%}//show only if vRetResult is not null%>  
  
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="parent_i" value="<%=WI.fillTextValue("parent_i")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>