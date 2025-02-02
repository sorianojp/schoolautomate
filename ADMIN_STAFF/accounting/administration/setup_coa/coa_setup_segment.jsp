<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA Segment Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction){
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_setup_segment.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	Vector vRetResult = null;
	COASetting coa = new COASetting();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(coa.operateOnSegmentSetup(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = coa.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "COA setup successful.";
			else
				strErrMsg = "COA setup successfully edited.";
		}
	}
	
	vRetResult = coa.operateOnSegmentSetup(dbOP, request, 4);
	if(vRetResult == null && strTemp.length() == 0)
		strErrMsg = coa.getErrMsg();
	
%>
<body bgcolor="#D2AE72">
<form action="./coa_setup_segment.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: COA SEGMENT SETUP ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="5"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Country Code: </td>
			<td align="right">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = WI.getStrValue((String)vRetResult.elementAt(0));
					else
						strTemp = WI.fillTextValue("cc_digit");
				%>
				<select name="cc_digit">
				<%if(strTemp.length() == 0){%>
					<option value="" selected>N/A</option>
				<%}else{%>
					<option value="">N/A</option>
					
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>1</option>
				<%}else{%>
					<option value="1">1</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2</option>					
				<%}else{%>
					<option value="2">2</option>
				<%}%>
				</select>&nbsp;</td>
			<td width="10%">&nbsp;Digit(s)</td>
			<td colspan="2" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Account Classification: </td>
		    <td align="right">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(1);
					else
						strTemp = WI.fillTextValue("ac_digit");
				%>
	        	<select name="ac_digit">
				<%if(strTemp.equals("1")){%>
	          		<option value="1" selected>1</option>
				<%}else{%>
					<option value="1">1</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2</option>
				<%}else{%>
					<option value="2">2</option>
				<%}%>
          	</select>&nbsp;</td>
		    <td colspan="3">&nbsp;Digit(s)</td>
	    </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Sub-Account Type: </td>
		    <td align="right">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(2);
					else
						strTemp = WI.fillTextValue("sat_level");
				%>
	        	<select name="sat_level">
				<%if(strTemp.equals("1")){%>
	          		<option value="1" selected>1</option>
				<%}else{%>
					<option value="1">1</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2</option>
				<%}else{%>
					<option value="2">2</option>
				
				<%}if(strTemp.equals("3")){%>
	          		<option value="3" selected>3</option>
				<%}else{%>
					<option value="3">3</option>
				
				<%}if(strTemp.equals("4")){%>
	          		<option value="4" selected>4</option>
				<%}else{%>
					<option value="4">4</option>
				
				<%}if(strTemp.equals("5")){%>
	          		<option value="5" selected>5</option>
				<%}else{%>
					<option value="5">5</option>
				
				<%}if(strTemp.equals("6")){%>
	          		<option value="6" selected>6</option>
				<%}else{%>
					<option value="6">6</option>
				<%}if(strTemp.equals("7")){%>
	          		<option value="7" selected>7</option>
				<%}else{%>
					<option value="7">7</option>
				<%}%>
	          	</select>&nbsp;</td>
		    <td>&nbsp;Level(s)</td>
		    <td width="7%" align="right">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(3);
					else
						strTemp = WI.fillTextValue("sat_digit");
				%>
	        	<select name="sat_digit">
				<%if(strTemp.equals("1")){%>
	          		<option value="1" selected>1</option>
				<%}else{%>
					<option value="1">1</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2</option>
				<%}else{%>
					<option value="2">2</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3</option>
				<%}else{%>
					<option value="3">3</option>
				<%}%>
	          	</select>&nbsp;</td>
		    <td width="45%">&nbsp;Digit(s)</td>
		</tr>
		<tr>
			<td height="25" width="5%">&nbsp;</td>
		    <td width="23%">Unit Center : </td>
		    <td align="right" width="10%">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(4);
					else
						strTemp = WI.fillTextValue("cost_digit");
				%>
	        	<select name="cost_digit">
				<%if(strTemp.equals("1")){%>
	          		<option value="1" selected>1</option>
				<%}else{%>
					<option value="1">1</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>2</option>
				<%}else{%>
					<option value="2">2</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>3</option>
				<%}else{%>
					<option value="3">3</option>
				<%}%>
          	</select>&nbsp;</td>
		    <td colspan="3">&nbsp;Digit(s)</td>
	    </tr>
		<tr>
			<td height="15" colspan="6">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<%if(vRetResult == null){%>
					<a href="javascript:PageAction('1')"><img src="../../../../images/save.gif" border="0"></a>
					<font size="1">Click to setup country code.</font>
				<%}else{%>
					<a href="javascript:PageAction('2')"><img src="../../../../images/edit.gif" border="0"></a>
					<font size="1">Click to edit country code.</font>
				<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="6">&nbsp;</td>
		</tr>
  	</table>
	
<%
int iTemp = 0;
int iTemp2 = 0;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="15%" align="center" class="thinborder"><strong>Country Code</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Account</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>Sub-Account</strong></td>
			<td width="35%" align="center" class="thinborder"><strong>Unit Center</strong></td>
		</tr>
		<tr>
			<%
				iTemp = Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(0), "0"));
			%>
			<td height="25" align="center" class="thinborder">
				<%if(iTemp == 0){%>
					N/A
				<%}else{
					for(int i = 0; i < iTemp; i++){%>X<%}
				}%></td>
			<%
				iTemp = Integer.parseInt((String)vRetResult.elementAt(1));
			%>
			<td align="center" class="thinborder">&nbsp;<%for(int i = 0; i < iTemp; i++){%>X<%}%></td>
			<%
				iTemp = Integer.parseInt((String)vRetResult.elementAt(2));
				iTemp2 = Integer.parseInt((String)vRetResult.elementAt(3));
			%>
			<td align="center" class="thinborder">
				<%for(int i = 0 ; i < iTemp; i++){for(int j = 0; j < iTemp2; j++){%>X<%}%>&nbsp;<%}%></td>
			<%
				iTemp = Integer.parseInt((String)vRetResult.elementAt(4));
			%>
			<td align="center" class="thinborder">
				<%for(int i = 0; i < iTemp; i++){%>X<%}%></td>
		</tr>
	</table>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>