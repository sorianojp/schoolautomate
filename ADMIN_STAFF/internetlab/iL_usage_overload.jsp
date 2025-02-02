<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value ="";
	document.form_.submit();
}

function PageAction(strPageAction,strInfoIndex){
	document.form_.page_action.value = strPageAction;
	if (eval(strPageAction) == 2){
		document.form_.info_index.value = strInfoIndex;
	}
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeOtherService,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;

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

iCafe.TimeInTimeOut tinStud = new iCafe.TimeInTimeOut();
iCafe.ComputerUsage compUsage = new iCafe.ComputerUsage();
Vector vRetResult = null;Vector vTemp = null;

//end of authenticaion code.
String strAuthIndex = (String)request.getSession(false).getAttribute("userId");

strAuthIndex = dbOP.mapUIDToUIndex(strAuthIndex);


if (WI.fillTextValue("page_action").length() !=0){
		if (tinStud.operateOnOverLoad(dbOP,request)){
			strErrMsg = " Operation successful";
		}else{
			strErrMsg = tinStud.getErrMsg();
		}
}
Vector vICafeAvalability = tinStud.internetCafeAvailability(dbOP,request.getRemoteAddr());
//System.out.println(compUsage.viewComputerUsagePerLoc(dbOP, null));
if(WI.fillTextValue("loc_index").length() > 0){
	vRetResult = compUsage.viewComputerUsagePerLoc(dbOP, WI.fillTextValue("loc_index"));
	if(vRetResult == null || vRetResult.size() == 0)
		strErrMsg = compUsage.getErrMsg();
}



%>
<form action="./iL_usage_overload.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          USAGE DETAILS - OVERLOAD PAGE::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong> <div align="right"></div></td>
    </tr>
    <tr > 
      <td height="25"><div align="right"><font size="1"><strong>Date / Time :</strong> 
          <%=WI.getTodaysDateTime()%></font></div></td>
    </tr>
  </table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
<td align="center" width="90%">
<%
if(vICafeAvalability != null && vICafeAvalability.size() > 0){%>
	  <table border="0" bgcolor="#000000" cellpadding="1" cellspacing="1">
          <tr bgcolor="#FFFFCF"> 
            <td><font size="1"><strong>LOCATION</strong></font></td>
            <td><font size="1"><strong>TOTAL SEAT</strong></font></td>
            <td><font size="1"><strong>AVAILABLE SEAT</strong></font></td>
          </tr>
          <%for(int p = 0; p < vICafeAvalability.size(); p += 3){
	if(p == 0)
		strTemp = "#FFEEEE";
	else	
		strTemp = "#FFFFFF";
	%>
          <tr bgcolor="<%=strTemp%>"> 
            <td><font size="1"><%=(String)vICafeAvalability.elementAt(p)%></font></td>
            <td><font size="1"><%=(String)vICafeAvalability.elementAt(p + 1)%></font></td>
            <td><font size="1"><%=(String)vICafeAvalability.elementAt(p + 2)%></font></td>
          </tr>
          <%}//end of for loop%>
        </table>
<%}// if vICafeAvalability is not null
%>
</td></tr></table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="8%" height="25">&nbsp;</td>
      <td width="25%" height="25"><br>
        View Detail</td>
      <td width="67%" height="25"> <br> <select name="loc_index" onChange="ReloadPage();">
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
      <td colspan="2">NOTE : Computer name in red are under maintenance and is 
        not counted in total seat count. 
        <div align="right"></div></td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td height="24" align="right"><font size="1">
	  <!--<img src="../../images/print.gif">click to print summary--></font></td>
    </tr>
</table>
<% 
for(int i = 0; i < vRetResult.size(); ++i){
vTemp = (Vector)vRetResult.elementAt(i);
if (vTemp != null  && vTemp.elementAt(4) != null) {
%>  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr valign="bottom" bgcolor="#FFFF9F"> 
      <td height="24"><font color="#0000FF">Location : <strong>
	  <%=(String)vTemp.elementAt(0)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF"> 
      <td width="10%"><div align="center"><font size="1"><strong>COMPUTER NAME 
          </strong></font></div></td>
      <td width="43%"> <div align="center"><font size="1"><strong>STUD ID (NAME) 
          </strong> </font></div></td>
      <td width="10%"><font size="1"><strong>LOGIN TIME</strong></font></td>
      <td width="10%"><div align="center"><font size="1"><strong>EXPTD. LOGOUT 
          TIME</strong></font></div></td>
      <td width="9%"><div align="center"><strong><font size="1">TOTAL MINS USED</font></strong></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>OVERLOAD<br>
          (minutes) </strong></font></div></td>
      <td width="9%" height="24"><div align="center"><font size="1"><strong>OPTION</strong></font></div></td>
    </tr>
<%
 for(int j = 3; j < vTemp.size(); j += 13){
	if ((String)vTemp.elementAt(j + 2) == null) // show only computer with users;
		break;
 %>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;<font size="1"><%=WI.getStrValue(vTemp.elementAt(j))%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vTemp.elementAt(j + 2))%> <%=WI.getStrValue((String)vTemp.elementAt(j + 3),"(",")","")%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vTemp.elementAt(j + 4))%></font></td>
      <td><div align="center"><font size="1">&nbsp;<%=WI.getStrValue(vTemp.elementAt(j + 5))%></font></div></td>
      <td><div align="center"><font size="1"><%=WI.getStrValue(vTemp.elementAt(j + 10))%></font></div></td>
      <td><div align="center">
	  <% if ((strTemp = (String)vTemp.elementAt(j+11)) != null){%>
	  	<%=strTemp%>	
	  <%}else{%>
	   <input name="textbox<%=iCtr%>" type="text" size="4" maxlength="3"
			  class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
			  onKeypress=" if(event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" >
	  <%}%>
        </div></td>
      <td>
	   <% if (iAccessLevel == 2 && (String)vTemp.elementAt(j+12) != null){
	   		if (((String)vTemp.elementAt(j+12)).compareTo(strAuthIndex) == 0){%>
	   	<a href="javascript:PageAction('2','<%=WI.getStrValue(vTemp.elementAt(j + 7),"")%>')">
				<img src="../../images/delete.gif" border="0"></a>
		<%}else{%> <font size=1>Not Authorized</font> <%}%>
	   <%}else{%>
        <input type="checkbox" name="checkbox<%=iCtr++%>" value="<%=WI.getStrValue(vTemp.elementAt(j + 7))%>">
	   <%}%>
	  </td>
    </tr>
<%} // end for loop

	if(iAccessLevel > 1){%>
    <tr bgcolor="#FFFFFF"> <td height="40" colspan="7"><div align="center">
	  <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a><font size="1" >click
          to save entries/changes 
		  <a href="./iL_usage_overload.jsp"><img src="../../images/cancel.gif" border="0"></a>click to
          clear or cancel entries</font></div></td>
    </tr>
<%
 }  // end iAccesslevel
 } // vTempSize  > 3
}//vRetResult loop -- outer.

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
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=iCtr%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>