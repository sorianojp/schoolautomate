<%@ page language="java" import="utility.*,hr.HRManpowerMgmt,java.util.Vector" %>
<%  
    WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolMyHome = false;	
	if (WI.fillTextValue("my_home").equals("1")) {
		bolMyHome = true;
		strColorScheme = CommonUtil.getColorScheme(9);
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
 <script language="JavaScript" src="../../../jscript/common.js"></script> 
<body bgcolor="#D2AE72" class="bgDynamic">
<%	
	String strTemp = null;
 
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}

strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, request items... i doubt someone will look at this anyway... hehehe
			iAccessLevel  = 2;	
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
DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Info","manpower_request.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	String strSchCode = dbOP.getSchoolIndex();	
							
	HRManpowerMgmt manpower = new HRManpowerMgmt();	
	Vector vReqInfo = null;
	String strErrMsg = null;	
	String strTemp2 = null; 		
	vReqInfo = manpower.operateOnManpowerRequest(dbOP, request, 3); 
 
%>
<form name="form_" method="post" action="./manpower_request.jsp">
	<%if(vReqInfo != null && vReqInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	  <tr bgcolor="#A49A6A">	  
	    <td height="25" colspan="2" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>::::  REQUEST DETAILS ::::</strong></font></td>
	  </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="69%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%>        
        </font></strong></td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td><strong>Request # </strong></td>
	   <%		 
				strTemp = (String)vReqInfo.elementAt(1);
		  %>
      <td>&nbsp;<%=strTemp%></td>
      <td><strong>Date Needed</strong></td>
			<%
				strTemp = WI.getStrValue((String)vReqInfo.elementAt(3));
			%>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
    <tr>
      <td width="4%" height="26">&nbsp;</td>
      <td width="17%"><strong>Requested By</strong></td>
			<%
				strTemp = WI.formatName((String)vReqInfo.elementAt(11), (String)vReqInfo.elementAt(12), 
																(String)vReqInfo.elementAt(13), 4);
			%>			
      <td width="32%">&nbsp;<%=strTemp%></td>
      <td width="16%"><strong>Date requested</strong></td>
	   <%		 
				strTemp = (String)vReqInfo.elementAt(9);
		  %>			
      <td width="31%">&nbsp;<%=strTemp%></td>
    </tr>
	 	<tr>
	 	  <td height="26">&nbsp;</td>
	 	  <td><strong>Manpower requested </strong></td>
		<%
	  		strTemp = (String)vReqInfo.elementAt(5);
  	%>
	 	  <td>&nbsp;<%=strTemp%></td>
 	    <td><strong>Approved</strong></td>
	   <%		 
				strTemp = (String)vReqInfo.elementAt(6);
		  %>				
 	    <td>&nbsp;<%=strTemp%></td>
    </tr>
	 	<tr>
	 	  <td height="26">&nbsp;</td>
	 	  <td><strong>Position</strong></td>
			<%
				strTemp = (String)vReqInfo.elementAt(16);
				strTemp = WI.getStrValue(strTemp, "N/a");
			%>			
	 	  <td><%=strTemp%></td>
 	    <td><strong>Filled</strong></td>
	    <%		 
				strTemp = (String)vReqInfo.elementAt(7);
		  %>				
 	    <td>&nbsp;<%=strTemp%></td>
	 	</tr>
	 	<tr> 
      <td height="26">&nbsp;</td>
      <td><strong>Reason</strong></td>
			<%if(vReqInfo != null && vReqInfo.size() > 1 && !(WI.fillTextValue("pageReloaded").equals("1")))
	  		strTemp = (String)vReqInfo.elementAt(2);
	    else 
	  		strTemp = WI.fillTextValue("purpose");
	  	%>			
      <td colspan="3" height="10">&nbsp;<%=strTemp%></td>
    </tr>
   </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">   
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<%}%>
  <!-- all hidden fields go here -->
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <!-- all hidden fields go here
  <input type="hidden" name="is_supply" value="<%//=WI.fillTextValue("is_supply")%>">
  -->
  <input type="hidden" name="forwardTo" value="">
  <input type="hidden" name="pageReloaded" value="">
  <input type="hidden" name="printPage" value="">
  <input type="hidden" name="prepareToEdit">
	
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
