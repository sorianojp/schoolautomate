<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-USAGE DETAILS-Internet Lab usage",
								"iL_usage_internet_lab.jsp");
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
														"Internet Cafe Management",
														"USAGE DETAILS",request.getRemoteAddr(),
														"iL_usage_internet_lab.jsp");
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
iCafe.ComputerUsage compUsage = new iCafe.ComputerUsage();
Vector vRetResult = null; Vector vTemp = null;
if(WI.fillTextValue("date_fr").length() > 0){
	vRetResult = compUsage.viewComputerUsageStat(dbOP,request);
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();
}	

%>
<form action="./iL_usage_internet_lab_stat.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET LAB USAGE <%=WI.getStrValue(WI.fillTextValue("v_date_fr"), " FROM ","","")%>
		  <%=WI.getStrValue(WI.fillTextValue("v_date_to")," TO ","","")%> ::::</strong></font></div></td>
    </tr>
<%
if(strErrMsg != null) {%>
    <tr >
      <td height="25"><font size="3" color="#FF0000"><%=strErrMsg%></font></td>
    </tr>
<%}%>
    <tr >
      <td height="25"><div align="right"><font size="1"><strong>Date &amp; Time 
          :</strong> <%=WI.getTodaysDateTime()%></font>&nbsp;&nbsp;</div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Range</td>
      <td height="25">Between 
        <input name="date_fr" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
        &nbsp;and 
        <input name="date_to" type="text" size="10" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td width="8%" height="25">&nbsp;</td>
      <td width="25%" height="25"><br>
        View Detail</td>
      <td width="67%" height="25"> <select name="loc_index" onChange="ReloadPage();">
          <option value="">Select a location</option>
          <%
strTemp = WI.fillTextValue("loc_index");
if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>ALL</option>
          <%}else{%>
          <option value="0">ALL</option>
          <%}%>
          <%=dbOP.loadCombo("location_index","location"," from IC_COMP_LOC order by location",strTemp,false)%> </select> &nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <%
	  strTemp = WI.fillTextValue("per_date");
	  if(strTemp.compareTo("1") == 0) 
	  	strTemp = " checked";
	  else	
	  	strTemp = "";
	  %><input type="checkbox" name="per_date" value="1"<%=strTemp%>>
        View Per date (list usage for each date). 
        <div align="right"></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td height="24" align="right"><font size="1">
	  <img src="../../images/print.gif">click to print summary</font></td>
    </tr>
</table>
<%double dTolMinsUsed = 0d; int iMinPerLoc = 0;
for(int i = 0; i < vRetResult.size(); ++i){
vTemp = (Vector)vRetResult.elementAt(i);
%>  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr valign="bottom" bgcolor="#FFFF9F"> 
      <td height="24"><font color="#0000FF">Location : <strong>
	  <%=(String)vTemp.elementAt(0)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF"> 
      <td width="29%" height="24"><div align="center"><font size="1"><strong>USAGE 
          DATE</strong></font></div></td>
      <td width="38%"> <div align="center"><font size="1"><strong>NO OF USERS</strong> 
          </font></div></td>
      <td width="33%"><font size="1"><strong>TOTAL # OF HOUR USED</strong></font></td>
    </tr>
 <%
 for(int j = 0; j < vTemp.size(); j += 4){
 iMinPerLoc += Integer.parseInt((String)vTemp.elementAt(j + 2));
 %>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;<font size="1"><%=WI.getStrValue(vTemp.elementAt(j + 3))%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vTemp.elementAt(j + 1))%></font></td>
      <td><font size="1">&nbsp;<%=ConversionTable.convertMinToHHMM(Integer.parseInt((String)vTemp.elementAt(j + 2)))%></font></td>
    </tr>
    <%}

}//vRetResult loop -- outer.
 dTolMinsUsed += iMinPerLoc;
 iMinPerLoc = 0; 
%>
  </table>
<%}//only vRetResult is not null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>