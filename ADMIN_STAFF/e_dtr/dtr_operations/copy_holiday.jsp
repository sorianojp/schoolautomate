<%@ page language="java" import="utility.*,eDTR.Holidays, java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
function SetFocus()
{
	document.dtr_op.yr_from.focus();
}
function AddRecord()
{
	document.dtr_op.copyrecords.value = "1";
}
</script>
<body bgcolor="#D2AE72" onLoad="SetFocus();" class="bgDynamic"> 
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR Operations-Copy Holidays","copy_holiday.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"copy_holiday.jsp");	
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

Holidays hol = new Holidays();
Vector vRetResult = new Vector();

strTemp = WI.fillTextValue("copyrecords");

if(strTemp.compareTo("1") ==0)
{
	vRetResult = hol.copyHoliday(dbOP,request);
	if (vRetResult == null)
		strErrMsg = hol.getErrMsg();
	else
		strErrMsg = "Holidays copied successfully";
}
%>	
<form action="./copy_holiday.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        COPY HOLIDAY::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30"><u><strong>COPY HOLIDAY FROM</strong></u></td>
      <td height="30"><u><strong>COPY HOLIDAY TO YEAR</strong></u></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25"> <strong> 
        <input name="yr_from" type="text" class="textbox" id="yr_from" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=WI.fillTextValue("yr_from")%>" size="6" maxlength="4">
        </strong></td>
      <td width="50%" height="25"><strong> 
        <input name="yr_to" type="text" class="textbox" id="yr_to" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" value="<%=WI.fillTextValue("yr_to")%>" size="6" maxlength="4">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
			<%if(iAccessLevel == 2){%>
			<div align="center"> 
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/copy_all.gif" width="55" height="27" border="0">
          <font size="1">click to copy holiday records</font></div>
			<%}else{%>
				Not Authorized
			<%}%>
			</td>
    </tr>
  </table>
<% if (vRetResult!=null && vRetResult.size()>0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" > 
      <td height="25" colspan="4" align="center"><strong><font color="#FFFFFF">LIST 
          OF HOLIDAYS COPIED</font></strong>
        <div align="center"></div>
        <div align="center"></div>
      <div align="center"></div></td>
    </tr>
    <tr > 
      <td width="5%" height="25"><div align="center"></div></td>
      <td width="36%" align="center"><strong>NAME OF HOLIDAY</strong></td>
      <td width="34%"><strong>DATE OF HOLIDAY</strong></td>
      <td width="25%">&nbsp;</td>
    </tr>
    <%	for (int i = 0; i < vRetResult.size(); i +=2){%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td>&nbsp;</td>
    </tr>
    <%} //end for loop%>
  </table>
<%} // end if (vRetResult == null)) %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="copyrecords">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>