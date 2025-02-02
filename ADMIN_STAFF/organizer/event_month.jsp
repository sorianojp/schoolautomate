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
	String strDateChange = null;
	String strDateIndex = WI.getStrValue(WI.fillTextValue("dateIndex"),"0");
	String strErrMsg = null;
	boolean bStart = false;
	String strMonth = null;
	String strYear = null;
	String strTableBg = null;
	String strFonCol = null;
	int y = 0;
	String [] astrConvertMonth = {"January", "February", "March", "April", "May", "June", "July", 
								"August", "September", "October", "November", "December"};

	Event myEvent = new Event();
	strDateNow = WI.fillTextValue("dateNow");
	if (strDateNow.length()==0)
	{
		strDateNow = WI.getTodaysDate(1);
	}
	Vector vMonthSet = myEvent.getDateRange(strDateNow, 4);
	strDateChange = WI.fillTextValue("isDateChange");
	
	if (strDateChange.length()>0) {
		if(strDateIndex.compareTo("0")==0) {
			strDateChange = "";		
			strDateNow = (String)vMonthSet.elementAt(0);
			}
		if(strDateIndex.compareTo("1")==0) {
			strDateChange = "";		
			strDateNow = (String)vMonthSet.elementAt(1);
			}
	if(strDateIndex.compareTo("2")==0) {
			strDateChange = "";		
			strDateNow = (String)vMonthSet.elementAt(2);
			}
	}
	int iCurMonth = Integer.parseInt(strDateNow.substring(0,1))-1;
	int iCurYear = Integer.parseInt(strDateNow.substring(strDateNow.length()-4));
	
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Events-View Monthly Events","event_month.jsp");
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
														"event_month.jsp");
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

	MyCalendar myCal = new MyCalendar();
	Vector vCal = myCal.makeCal(Integer.toString(iCurMonth), Integer.toString(iCurYear));
	Vector vRetResult = myEvent.getEventSet(dbOP,(String)request.getSession(false).getAttribute("userId"),strDateNow,2);
%>
<body bgcolor="#8C9AAA" >
<form action="./event_month.jsp" method="post" name="form_">
  <table width="1024" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="7" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVENT LIST ::::</strong></font></div></td>
    </tr>
    <tr>
	   <td colspan="7"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
   </tr>
   <tr>
   <td colspan="3" align="right" ><a href='javascript:DateChange("2");'>Previous Month</a></td>
   <td align="center" ><strong><%=astrConvertMonth[iCurMonth]%><br><%=iCurYear%></strong></td>
   <td colspan="3" align="left" ><a href='javascript:DateChange("1");'>Next Month</a></td>
   </tr>
   <tr>
	   <td colspan="7">&nbsp;</td>
   </tr>
	<tr bgcolor="aliceblue">
   <td width="14.28%" align="center" height="25" class="thinborderALL"><font size="1" color="red"><strong>SUN</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>MON</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>TUE</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>WED</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>THURS</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>FRI</strong></font></td>
   <td width="14.28%" align="center" class="thinborderALL"><font size="1"><strong>SAT</strong></font></td>
   </tr>
    <%
   if (vCal != null){
   int iCtr;
   for (int i = 0; i<84;){
   iCtr = 0;%>
   <tr height="25">
   <%
   while (iCtr<=6)
   {
  	 if (iCtr == 0 || iCtr == 6)
   		strTableBg = "bgcolor = gainsboro";
	 else
   		strTableBg ="bgcolor= #FFFFFF";
	
   	if (((String)vCal.elementAt(i+1)).compareTo("1")==0) {
   		if (!bStart)
   			bStart = true;
     	else bStart = false;	
   	}
   	if (bStart)
   		strFonCol = "color = black"; 
	else
   		strFonCol = "color = orange"; 
   	
   if (((String)vCal.elementAt(i)).compareTo(WI.getTodaysDate(1))==0)
		strFonCol = "color = red"; 
   %>
   <td align="left" <%=strTableBg%> class="thinborder" valign="top">
   <a href= "./event_day.jsp?dateNow=<%=(String)vCal.elementAt(i)%>"> <font size="1" <%=strFonCol%>><%=(String)vCal.elementAt(i+1)%></font></a>&nbsp;
   <a href= 'javascript:MakeEvent("<%=WI.formatDate((String)vCal.elementAt(i),1)%>")'> <font size="1" <%=strFonCol%>>[Add Event]</font></a>
   <%if (vRetResult!=null && vRetResult.size()>0){%>
		<table>
					<tr>
					<td><font size="1">
					<%for (y = 0; y < vRetResult.size(); y += 8){
					if(((String)vRetResult.elementAt(y)).compareTo((String)vCal.elementAt(i))==0) {%>
					<%=(String)vRetResult.elementAt(y+2)%>&nbsp;(<%=(String)vRetResult.elementAt(y+3)%>)<br>
					<%
					vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);
					vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);vRetResult.removeElementAt(y);
					} //if falls on day
					} //for (event)
					%>
					</font>
					</td>
					</tr>
				</table>
		<%}%>
   </td>
	<%
   i+=2;
   ++iCtr;
   }%>
   </tr>
   <%}}%>
	<tr>    
		<td height="10" colspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="7" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  	<input type="hidden" name="page_action">
	<input type="hidden" name="dateNow" value="<%=strDateNow%>">
	<input type="hidden" name="dateIndex" value="<%=WI.fillTextValue("=strDateIndex")%>">
  	<input type="hidden" name="isDateChange" value="<%=WI.fillTextValue("strDateChange")%>">		
  	<input name="month" type="hidden" value="<%=Integer.toString(iCurMonth)%>">
  	<input name="year" type="hidden" value="<%=Integer.toString(iCurYear)%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>