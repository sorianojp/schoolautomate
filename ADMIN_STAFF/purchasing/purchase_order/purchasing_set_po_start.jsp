<%@ page language="java" import="utility.*,purchasing.PO,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function SetPO(){
	document.form_.start.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-PURCHASE ORDER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-PURCHASE ORDER","purchasing_set_po_start.jsp");
	
	PO PO = new PO();	
	String strErrMsg = null;
	String strTemp = null;
	if(WI.fillTextValue("start").length() > 0) {
	  if(WI.fillTextValue("po_number").trim().length() > 0){
		if(PO.setStartPO(dbOP,request)){
			strErrMsg = "PO Setting Successful";
		}else{
			strErrMsg = PO.getErrMsg();
		}
	  }else{
	  	strErrMsg = "Please enter starting PO Number";
	  }
	}
	
%>
<form name="form_" method="post" action="./purchasing_set_po_start.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASING PO SETTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="85%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
    </tr>
  </table>
  <table width="100%" height="30" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="31" height="30">&nbsp;</td>
      <td width="160">Start PO Number :</td>
	  <%
	  	strTemp = WI.fillTextValue("po_number");
	  %>
      <td width="529"> <input type="text" name="po_number" maxlength="6" onKeyPress="if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=strTemp%>"></td>
    </tr>
  </table>	
	
  <table width="100%" height="51" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    <tr> 
      <td width="72%" height="18" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30" colspan="6"><div align="center"><font size="1"> <a href="javascript:SetPO();"> 
          <img src="../../../images/save.gif" width="48" height="28" border="0"></a>click 
          to set the starting PO number</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table> 
  <input type="hidden" name="start">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>