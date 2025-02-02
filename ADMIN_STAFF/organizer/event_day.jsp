<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>

</head>
<script language="javascript"  src ="../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function DateChange(strDayTarget)
{
	if (strDayTarget == "1")
	{
		document.form_.isDateChange.value = "1";
		document.form_.dateIndex.value = "2";
		this.SubmitOnce('form_');
	}
	else
	{
		document.form_.isDateChange.value = "1";
		document.form_.dateIndex.value = "1";
		this.SubmitOnce('form_');
	}
}
</script>
<%@ page language="java" import="utility.*, organizer.Event, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEventList = new Vector();
	String strTemp = null;
	String strDateNow = null;
	String strDateChange = null;
	String strDateIndex = WI.getStrValue(WI.fillTextValue("dateIndex"),"0");
	

	String strErrMsg = null;
	Event myEvent = new Event();
	strDateNow = WI.fillTextValue("dateNow");
	if (strDateNow.length()==0)
	{
		strDateNow = WI.getTodaysDate(1);
	}
	Vector vDaySet = myEvent.getDateRange(strDateNow, 5);
	strDateChange = WI.fillTextValue("isDateChange");
	if (strDateChange.length()>0) {
		if(strDateIndex.compareTo("0")==0) {
			strDateChange = "";		
			strDateNow = (String)vDaySet.elementAt(0);
			}
		if(strDateIndex.compareTo("1")==0) {
			strDateChange = "";		
			strDateNow = (String)vDaySet.elementAt(1);
			}
	if(strDateIndex.compareTo("2")==0) {
			strDateChange = "";		
			strDateNow = (String)vDaySet.elementAt(2);
			}
	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Events-Event Entry","event_day.jsp");
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
/** authenticate this user - not authenticating.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Events",request.getRemoteAddr(),
														"event_day.jsp");
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
**/
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myEvent.operateOnEvent(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myEvent.getErrMsg();
	}
	if (strErrMsg == null)
		strErrMsg = myEvent.getErrMsg();
	
	vRetResult = myEvent.getDailyEvents(dbOP,(String)request.getSession(false).getAttribute("userId"),strDateNow);
	if (vRetResult == null)
	{
		strErrMsg = myEvent.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" >
<form action="./event_day.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVENT LIST ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
   </tr>
   <tr>
   <td width="34%" align="right" ><a href='javascript:DateChange("2");'>Previous Day</a></td>
   <td width="33%" align="center" ><%=WI.formatDate(strDateNow,2)%></td>
   <td width="33%" align="left" ><a href='javascript:DateChange("1");'>Next Day</a></td>
   </tr>
   <tr>
   <td colspan="3">&nbsp;</td>
   </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr bgcolor="#DBEAF5">
   <td width="13.75%" height="25"><div align="left"><strong><font size="1">Event Start</font></strong></div></td>
   <td width="13.75%" height="25"><div align="left"><strong><font size="1">Event End</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Event Name</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Location</font></strong></div></td>
   <td width="10%"><div align="left"><strong><font size="1">Category</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Note</font></strong></div></td>
   <td width="5%">&nbsp;</td>
   </tr>
<%for (int i = 0; i < vRetResult.size(); i+=11) {%>   
   <tr>
   <td height="25" class="thinborderBOTTOM"><font size="1">
   <%=(String)vRetResult.elementAt(i+6)%><br>
   <%=(String)vRetResult.elementAt(i+7)%>
   </font>
   </td>
   <td class="thinborderBOTTOM" height="28"><font size="1">
   <%if(((String)vRetResult.elementAt(i+6)).compareTo((String)vRetResult.elementAt(i+8))==0){%>&nbsp;<%}else{%><%=(String)vRetResult.elementAt(i+8)%><%}%><br>
   <%=(String)vRetResult.elementAt(i+9)%>
   </font></td>
   <td class="thinborderBOTTOM"><font size="1"><a href= "./event_entry.jsp"><%=(String)vRetResult.elementAt(i+2)%></a></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></font></td>
   <td valign="middle" class="thinborderBOTTOM" align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../images/delete_2.gif" border="0"></a></td>
   </tr>
<%}%>
   <tr>
   	<td colspan="7">&nbsp;</td>
   </tr>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<tr>
   	<td align="center"><a href= "./event_entry.jsp?start_date=<%=WI.fillTextValue("dateNow")%>">
   	<img src="../../images/schedule.gif" border="0"></a><font size="1">click to schedule a event</font>
   	</td>
   </tr>
      <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="dateNow" value="<%=strDateNow%>">
	<input type="hidden" name="dateIndex" value="<%=WI.fillTextValue("=strDateIndex")%>">
  	<input type="hidden" name="isDateChange" value="<%=WI.fillTextValue("strDateChange")%>">		
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>