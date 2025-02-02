<html>
<head>
<title>SchoolBliz Products</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css"></link>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
</script>
<%@ page language="java" import="utility.*,java.util.Vector, search.FSProduct" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	int iAccessLevel = 0;
	
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}


	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	FSProduct  fsProd = new FSProduct();
	
	int iPageAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"), "0"));	
	Vector vRetResult = fsProd.operateOnFSSetting(dbOP, request, iPageAction);
	strErrMsg = fsProd.getErrMsg();	
%>

<body>
<form action="fs_usage_setting.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this)">
  <table width="100%" border="0" cellspacing="0" cellpadding="1" id="myADTable1">
    <tr> 
      <td width="4%">&nbsp;</td>
      <td height="25"><font size="2" color="#FF0000" ><strong><%=WI.getStrValue(strErrMsg)%></strong></font>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong><font size="2"><u>eDTR Attendance Terminal Setting</u></font></strong></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="96%">
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
else	
	strTemp = "2";

if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="setting_eDTR" type="radio" value="0"<%=strErrMsg%>> HTML Interface is used for eDTR Terminal (no FS)	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="setting_eDTR" type="radio" value="1"<%=strErrMsg%>> Java Desktop Application is used for eDTR Terminal but <b>NO FS Verification</b>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
<%
if(strTemp.equals("2"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="setting_eDTR" type="radio" value="2"<%=strErrMsg%>> Java Desktop Application is used for eDTR Terminal <b>with strict FS verification</b> (Default Setting)	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td align="center"><input type="submit" value="Update Setting" name="submit_page" onClick="document.form_.page_action.value='1';"></td>
    </tr>
    <tr> 
      <td colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" align="center"><strong><font size="2"><u>Offline Application Setting</u></font></strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>
<%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(1);
else	
	strTemp = "1";

if(strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  	<input name="setting_offline" type="radio" value="0"<%=strErrMsg%>> Only Online (default - DTR to Server connection is stable) 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		<input name="setting_offline" type="radio" value="1"<%=strErrMsg%>> Online and Offline</td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" align="center"><input type="submit" value="Update Setting" name="submit_page2" onClick="document.form_.page_action.value='2';"></td>
    </tr>
  </table>
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>