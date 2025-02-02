<%@ page language="java" import="utility.*,payroll.PayrollConfig, payroll.PRTransmittal, 
																java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transmittal Bank Listing</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function populateBanks(){
	document.form_.populate_banks.value = "1";
	document.form_.submit();
}

function ToggleStatus(strOrigStat, strIndex, strLabel) {
		var objCOA=document.getElementById(strLabel);
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=307&b_index="+strIndex+
								 "&is_allowed="+strOrigStat;
		this.processRequest(strURL);
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll - Pagibig Table Configuration","transmittal_banklist.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"transmittal_banklist.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	PayrollConfig prConfig = new PayrollConfig();
	PRTransmittal prTransmit = new PRTransmittal(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	
	if(WI.fillTextValue("populate_banks").length() > 0){
		prTransmit.populateSupportedBanks(dbOP);
	}	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnTransmittalBanks(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Bank information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Bank information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Bank information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prConfig.operateOnTransmittalBanks(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = prConfig.getErrMsg();
}

	vRetResult  = prConfig.operateOnTransmittalBanks(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="transmittal_banklist.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : TRANSMITTAL BANKS LISTPAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" colspan="2"><a href='javascript:populateBanks();'>Populate Supported Banks</a></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
  <tr>
    <td>&nbsp;</td>
    <td><table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="25" colspan="2" align="center" bgcolor="#B9B292" class="thinborderBOTTOMLEFTRIGHT"><font color="#FFFFFF"><strong>BANK  SETTING</strong></font></td>
        </tr>
      <tr>
        <td width="25%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
        <td width="23%" align="center" class="thinborder"><strong>STATUS</strong></td>
        </tr>
      <% 
			for(int i =0; i < vRetResult.size(); i += 3){%>
      <tr>
        <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
        <%
				strTemp = (String)vRetResult.elementAt(i + 2);
				if(strTemp.equals("1"))
					strTemp = "Allowed";
				else
					strTemp = "Disabled";
			%>
        <td class="thinborder">&nbsp;
				<label id="status_<%=vRetResult.elementAt(i)%>">
					<a href="javascript:ToggleStatus('<%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%>',
																					 '<%=vRetResult.elementAt(i)%>','status_<%=vRetResult.elementAt(i)%>');">
						<%=strTemp%>
					</a>
					</label></td>
        </tr>
      <%}//end of for loop%>
    </table></td>
    <td>&nbsp;</td>
  </tr>
</table>

  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"  colspan="3"  class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="populate_banks">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>