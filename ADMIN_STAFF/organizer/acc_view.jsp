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
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
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

</script>
<%@ page language="java" import="utility.*, organizer.ToDo, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEventList = new Vector();
	String strTemp = null;
	String strFinCol = "";
	int iCurMonth = Integer.parseInt(WI.getTodaysDate(1).substring(0,1))-1;
	int iCurYear = Integer.parseInt(WI.getTodaysDate(2).substring(WI.getTodaysDate(2).length()-4));

	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-To Do-Accomplishments","acc_view.jsp");
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


	ToDo myToDo = new ToDo();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myToDo.operateOnAccomplishments(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myToDo.getErrMsg();
	}

	vRetResult = myToDo.operateOnAccomplishments(dbOP, request, 5);
	if (vRetResult == null && WI.fillTextValue("month").length()>0)
		strErrMsg = myToDo.getErrMsg();

	
%>
<body bgcolor="#8C9AAA" >
<form action="./acc_view.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="3" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          VIEW ACCOMPLISHMENTS ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
   </tr>
   <tr>
   <td width="34%" align="right" >Accomlishments for</td>
   <td width="33%" align="center" >    <%	strTemp = WI.fillTextValue("month");
	    	if (strTemp.length()==0)
   		strTemp = Integer.toString(iCurMonth);
    %>
   <select name="month" onChange="ReloadPage();">
	<%if (strTemp.compareTo("0")==0){%>
   		<option value="0" selected>January</option>
 	<%} else {%>	
 		<option value="0">January</option>
	<%} if (strTemp.compareTo("1")==0){%>
 		<option value="1" selected>February</option>
 	<%} else {%>	
 		<option value="1">February</option>
	<%} if (strTemp.compareTo("2")==0){%>
  		<option value="2" selected>March</option>
	<%} else {%>	
  		<option value="2">March</option>
	<%} if (strTemp.compareTo("3")==0){%>   	
   		<option value="3" selected>April</option>
	<%} else {%>	
   		<option value="3">April</option>
   	<%} if (strTemp.compareTo("4")==0){%>   	
		<option value="4" selected>May</option>
	<%} else {%>	
		<option value="4">May</option>
	<%} if (strTemp.compareTo("5")==0){%>   	
		<option value="5" selected>June</option>
	<%} else {%>	
		<option value="5">June</option>
	<%} if (strTemp.compareTo("6")==0){%>   	
		<option value="6" selected>July</option>
	<%} else {%>	
		<option value="6">July</option>
	<%} if (strTemp.compareTo("7")==0){%>   	
 		<option value="7" selected>August</option>
	<%} else {%>	
 		<option value="7">August</option>
	<%} if (strTemp.compareTo("8")==0){%>   	
  		<option value="8" selected>September</option>
	<%} else {%>	
  		<option value="8">September</option>
	<%} if (strTemp.compareTo("9")==0){%>   	
   		<option value="9" selected>October</option>
	<%} else {%>	
   		<option value="9">October</option>
	<%} if (strTemp.compareTo("10")==0){%>   	
		<option value="10" selected>November</option>
	<%} else {%>	
		<option value="10">November</option>
	<%} if (strTemp.compareTo("11")==0){%>   	
		<option value="11" selected>December</option>
	<%} else {%>	
		<option value="11">December</option>
	<%}%>
   </select>&nbsp;<%	strTemp = WI.fillTextValue("year");
   		if (strTemp.length()==0)
   		strTemp = Integer.toString(iCurYear);
   %>
    <select name="year" onChange="ReloadPage();" >
	<%for (int i = iCurYear-2; i <= iCurYear+2; ++i){
		if (strTemp.compareTo(Integer.toString(i))==0){%>
		<option value="<%=i%>" selected><%=i%></option>
		<%} else {%>
		<option value="<%=i%>"><%=i%></option>
	<%}}%>
    </select></td>
   <td width="33%" align="left" ><a href="JavaScript:ReloadPage();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
   </tr>
   <tr>
   <td colspan="3">&nbsp;</td>
   </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr bgcolor="#DBEAF5">
   <td width="13.75%" height="25"><div align="left"><strong><font size="1">Date</font></strong></div></td>
   <td width="23.75%" height="25"><div align="left"><strong><font size="1">Subject</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Description</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Comment</font></strong></div></td>
   <td width="20%"><div align="left"><strong><font size="1">Next Task</font></strong></div></td>
   <td width="5%" align="center">&nbsp</td>
   </tr>
<%for(int i = 0; i< vRetResult.size(); i+=7) {
 	if (((String)vRetResult.elementAt(i+6)).compareTo("1")==0)
	strFinCol = " bgcolor = '#EEEEEE'";
	else 
	strFinCol = " bgcolor = '#FFFFFF'";
%>
   <tr <%=strFinCol%>>
   <td height="18" class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
   <td class="thinborderBOTTOM" height="28"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp")%></font></td>
   <td class="thinborderBOTTOM"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
   <td class="thinborderBOTTOM" align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'>
	<img src="../../images/x_small.gif" border="0"></a></td>
   </tr>
   <%}%>
   <tr>
   	<td colspan="6">&nbsp;</td>
   </tr>
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
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>