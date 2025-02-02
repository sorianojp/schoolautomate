<%
if(request.getSession(false).getAttribute("userId") == null){%>
<font style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
	Please login to access this link.
</font>
<%return;
}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function DateChange(strWkTarget)
{
	if (strWkTarget == "1")
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
function MakeEvent (strDate)
{
	location = "./event_entry.jsp?start_date="+strDate+"&end_date="+strDate;
}
</script>
<%@ page language="java" import="utility.*, organizer.Event, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strDateNow = null;
	String strErrMsg = null;
	String strDateChange = null;
	String strDateIndex = WI.getStrValue(WI.fillTextValue("dateIndex"),"0");
	
	strDateNow = WI.fillTextValue("dateNow");
	if (strDateNow.length()==0)
	{
		strDateNow = WI.getTodaysDate(1);
	}

	Event myEvent = new Event();
	Vector vWeekSet = myEvent.getDateRange(strDateNow, 3);

	int iCtr = 0;
	int i = 0;
	int y = 0;

	strDateChange = WI.fillTextValue("isDateChange");
	if (strDateChange.length()>0) {
		if(strDateIndex.compareTo("0")==0) {
			strDateChange = "";		
			strDateNow = (String)vWeekSet.elementAt(0);
			}
		if(strDateIndex.compareTo("1")==0) {
			strDateChange = "";		
			strDateNow = (String)vWeekSet.elementAt(1);
			}
	if(strDateIndex.compareTo("2")==0) {
			strDateChange = "";		
			strDateNow = (String)vWeekSet.elementAt(2);
			}
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Events-View Weekly Events","event_week.jsp");
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
/** authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Events",request.getRemoteAddr(),
														"event_week.jsp");
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
	Vector vRange = myEvent.getDateRange(strDateNow, 1);
	Vector myVector = myEvent.getEventSet(dbOP,(String)request.getSession(false).getAttribute("userId"),strDateNow,1);
%>
<body bgcolor="#8C9AAA" >
<form action="./event_week.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVENT LIST ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
   </tr>
   <tr>
   <td width="34%" align="right" ><a href='javascript:DateChange("2");'>Previous Week</a></td>
   <td width="33%" align="center" ><%=WI.formatDate(strDateNow,2)%></td>
   <td width="33%" align="left" ><a href='javascript:DateChange("1");'>Next Week</a></td>
   </tr>
   <tr>
   		<td colspan="3">&nbsp;</td>
   </tr>
</table>
<%if (vRange != null && vRange.size()>0) {%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<%for (i = 0; i < vRange.size(); ++i) {%>
	<tr>
		<td height="50" class="thinborderBOTTOMRIGHT" width="10%" align="right">
		<a href= 'javascript:MakeEvent("<%=WI.formatDate((String)vRange.elementAt(i),1)%>")'>
		>></a><a href= "./event_day.jsp?dateNow=<%=(String)vRange.elementAt(i)%>"><%=WI.formatDate((String)vRange.elementAt(i),9)%></a><br>
		<%=((String)vRange.elementAt(i)).substring(((String)vRange.elementAt(i)).length()-4)%></td>

		<td class="thinborderBOTTOM" width="90%">&nbsp;
		<%if (myVector!=null && myVector.size()>0){%>
		<table>
					<tr>
					<%for (y = 0; y < myVector.size(); y += 8){
					if(((String)myVector.elementAt(y)).compareTo((String)vRange.elementAt(i))==0) {%>
					<td class="thinborderALL" bgcolor="bisque"><font size="1"><%=(String)myVector.elementAt(y+2)%><br>
					<%=(String)myVector.elementAt(y+3)%><br>
					<%=WI.getStrValue((String)myVector.elementAt(y+5),"Start: ","<br>","&nbsp;")%>
					<%=WI.getStrValue((String)myVector.elementAt(y+6),"End: ","","&nbsp;")%></font>
					</td>
		<%
		myVector.removeElementAt(y);myVector.removeElementAt(y);myVector.removeElementAt(y);myVector.removeElementAt(y);
		myVector.removeElementAt(y);myVector.removeElementAt(y);myVector.removeElementAt(y);myVector.removeElementAt(y);
		}//if falls on day
		}//for loop(events)
		%>
		</tr>
				</table>
		<%}%>			
		</td>
	</tr>
	<%}%>
</table>

<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
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