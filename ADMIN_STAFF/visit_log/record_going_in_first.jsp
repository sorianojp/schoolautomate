<%@ page language="java" import="utility.*, visitor.VisitorInfo, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Record Going In</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function nextStep(){
		document.form_.step.value = "1";
		document.form_.submit();
	}

	function AjaxMapVisitors() {
		var strLname = document.form_.lname.value;
		var objCOAInput = document.getElementById("coa_info");
		if(strLname.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20200&lname="+escape(strLname);
		this.processRequest(strURL);
	}
	
	function updateInformation(strIndex, strFname, strMname, strLname){
		//alert(strIndex + ": "+strFname + ": "+strMname  + ": "+strLname );
		document.form_.lname.value = strLname;
		document.form_.fname.value = strFname;
		document.form_.mname.value = strMname;		
		document.getElementById("coa_info").innerHTML = "";
	}
	
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Record Going In First","record_going_in_first.jsp");
	}
	catch(Exception exp) {
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
															"Visitor Management","Record Going In Out",request.getRemoteAddr(),
															"record_going_in_first.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	VisitLog visitLog = new VisitLog();
	VisitorInfo visitorInfo = new VisitorInfo();
	Vector vRetResult = null;
	
	if(visitLog.isTerminal(dbOP, request)){
		if(WI.fillTextValue("step").length() > 0){
			strTemp = visitorInfo.getVisitorInfo(dbOP, request);
			if(strTemp == null)
				strErrMsg = visitorInfo.getErrMsg();
			else{
				if(strTemp.length() == 0){
					if(visitorInfo.operateOnVisitorInfo(dbOP, request, 1) == null)
						strErrMsg = visitorInfo.getErrMsg();
					strTemp = visitorInfo.getVisitorInfo(dbOP, request);
				}
				else
					strTemp = visitorInfo.getVisitorInfo(dbOP, request);
			}
		}
		
		if(strTemp != null){
			if(visitLog.isVisitorInsidePremises(dbOP, request, strTemp)){
				strTemp = null;
				strErrMsg = "Visitor already inside.";
			}
		}
		
		if(strTemp != null){
			strTemp = "./record_going_in.jsp?info_index="+strTemp;
		%>
			<jsp:forward page="<%=strTemp%>" />
			<%
			return;
		}
	}
	else
		strErrMsg = visitLog.getErrMsg();
%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="record_going_in_first.jsp">
<jsp:include page="./tabs.jsp?pgIndex=1"></jsp:include>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="30%" align="center" bgcolor="#99CC99">
				<strong><font size="2" color="#FFFFFF">RECORD VISITOR'S GOING IN</font></strong></td>
			<td width="70%">&nbsp;</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="98%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>
		
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="60%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" width="4%">&nbsp;</td>
						<td colspan="4">Date and Time: <%=WI.getTodaysDateTime()%></td>
					</tr>
					<tr>
						<td height="15" width="4%">&nbsp;</td>
						<td width="16%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
						<td width="20%">&nbsp;</td>
						<td width="40%">&nbsp;</td>
					</tr>
					<tr>
						<td height="25">&nbsp;</td>
						<td colspan="4"><strong><u>Visitor's Info</u></strong></td>
					</tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>Last name:</td>
			  	        <td colspan="2">
							<input name="lname" type="text" size="32" value="<%=WI.fillTextValue("lname")%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapVisitors();"></td>
		  	        </tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>First name:</td>
			 	        <td colspan="2">
							<input name="fname" type="text" size="32" value="<%=WI.fillTextValue("fname")%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		 	        </tr>
					<tr>
					  	<td height="25" colspan="2">&nbsp;</td>
					  	<td>Middle name: </td>
		                <td colspan="2">
							<input name="mname" type="text" size="32" value="<%=WI.fillTextValue("mname")%>" class="textbox" maxlength="32"
								onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
                  	</tr>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
					  	<td>&nbsp;</td>
					  	<td colspan="2" align="center">
						<%if(iAccessLevel > 1){%>
							<a href="javascript:nextStep();"><img src="../../images/next.gif" border="0"></a>
						<%}else{%>
							Not authorized to save record information.
						<%}%></td>
				  	</tr>
				</table>
			</td>
			<td width="40%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="2">&nbsp;</td>
					</tr>
					<tr>
						<td height="25" colspan="2">&nbsp;</td>
					</tr>
					<tr>
					  	<td valign="top"><label id="coa_info" style="position:absolute; width:350px"></label></td>
				  	</tr>
				</table>
			</td>
		</tr>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="step">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>