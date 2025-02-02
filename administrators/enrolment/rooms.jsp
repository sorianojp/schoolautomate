<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function SetParameter()
{
	document.ems_stat.room_status_name.value = document.ems_stat.room_stat[document.ems_stat.room_stat.selectedIndex].text;
	document.ems_stat.range.value = document.ems_stat.time_from_hr.value +":"+
									document.ems_stat.time_from_min.value+" "+
									document.ems_stat.time_from_AMPM[document.ems_stat.time_from_AMPM.selectedIndex].text+
									" to "+
									document.ems_stat.time_to_hr.value +":"+
									document.ems_stat.time_to_min.value+" "+
									document.ems_stat.time_to_AMPM[document.ems_stat.time_to_AMPM.selectedIndex].text+
									" ("+document.ems_stat.week_day.value +")"
}
function ReloadPage()
{
	document.ems_stat.submit();
}
function PrintPg()
{
	this.SetParameter();
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	var vExtraCon = "";
	if(document.ems_stat.plot2D.checked)
		vExtraCon = "&plot2D=1";
	if(document.ems_stat.showData.checked)
		vExtraCon += "&showData=1";
	
	var pgLoc = "./rooms_print.jsp?sy_from_prev="+document.ems_stat.sy_from_prev.value+"&sy_to_prev="+document.ems_stat.sy_to_prev.value+
				"&sy_from="+document.ems_stat.sy_from.value+"&sy_to="+document.ems_stat.sy_to.value+"&semester="+
				document.ems_stat.semester[document.ems_stat.semester.selectedIndex].value+"&room_stat="+
				document.ems_stat.room_stat[document.ems_stat.room_stat.selectedIndex].value+ "&week_day="+
				document.ems_stat.week_day.value+"&time_from_hr="+document.ems_stat.time_from_hr.value+
				"&time_to_hr="+document.ems_stat.time_to_hr.value+"&time_from_min="+document.ems_stat.time_from_min.value+
				"&time_to_min="+document.ems_stat.time_to_min.value+"&time_from_AMPM="+
				document.ems_stat.time_from_AMPM[document.ems_stat.time_from_AMPM.selectedIndex].value+
				"&time_to_AMPM="+document.ems_stat.time_to_AMPM[document.ems_stat.time_to_AMPM.selectedIndex].value+
				"&room_status_name="+document.ems_stat.room_status_name.value+
				"&range="+escape(document.ems_stat.range.value);		
				vExtraCon;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#46689B">
<%@ page language="java" import="utility.*,ems.Enrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strGraphInfo = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Administrators-Enrollment","enrollees.jsp");
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
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														"enrollees.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../administrators/administrators_bottom_content.jsp");
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
Vector vRetResult = null;
Enrollment enrlInfo = new Enrollment();
if(WI.fillTextValue("sy_from").length() > 0)
{
	vRetResult = enrlInfo.getRoomStatus(dbOP,request);
	if(vRetResult == null)
		strErrMsg = enrlInfo.getErrMsg();
	else if(WI.fillTextValue("plot2D").length() > 0 || WI.fillTextValue("plot3D").length() > 0 || 
			WI.fillTextValue("showData").length() > 0)
	{//System.out.println("I am here ");
		//plot here graph if it is called for graph.
		String strXAxisName = "School Year Level --->";String strYAxisName = "NUMBER OF ROOMS";
		int iWidthOfGraph   = 600;int iHeightOfGraph  = 500;
		String strBGColor = "#C5CACB";
		String strColumnColor="#FC9604";
		boolean bolPlot2DGraph = true;
		if(WI.fillTextValue("plot3D").length() > 0)
			bolPlot2DGraph = false;
		strGraphInfo = enrlInfo.plotRoomStatusGraph(vRetResult, bolPlot2DGraph,strXAxisName, strYAxisName,
									 iWidthOfGraph, iHeightOfGraph, strBGColor, strColumnColor);
		if(strGraphInfo == null)
			strErrMsg = enrlInfo.getErrMsg();//System.out.println(vRetResult);
//	System.out.println(strGraphInfo);
	}
}

String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","ALL"};
%>
<form method="post" name="ems_stat" action="./rooms.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#004488"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          </strong></font><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>ROOMS</strong></font><font color="#FFFFFF"><strong> 
          STATISTICS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size=3><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td valign="bottom">Room Status</td>
      <td width="16%" valign="bottom">School year from</td>
      <td width="17%" valign="bottom">School year to</td>
      <td colspan="2" valign="bottom">Term</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td><select name="room_stat">
          <option value="">All</option>
          <%
strTemp = WI.fillTextValue("room_stat");
if(strTemp.compareTo("Occupied") ==0){%>
          <option selected value="Occupied">Occupied</option>
          <%}else{%>
          <option value="Occupied">Occupied</option>
          <%}if(strTemp.compareTo("Available") == 0){%>
          <option value="Available" selected>Available</option>
          <%}else{%>
          <option value="Available">Available</option>
          <%}%>
        </select></td>
      <td><input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from_prev")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" onKeyUp='DisplaySYTo("ems_stat","sy_from_prev","sy_to_prev")'>
        - 
        <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to_prev")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" readonly></td>
      <td> 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
      <td width="11%"><select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
      <td width="36%"><input name="image" type="image" onClick="SetParameter();" src="../../images/refresh.gif"></td>
    </tr>
    <tr bgcolor="#e0e0e0">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#e0e0e0"> 
      <td height="25">&nbsp;</td>
      <td align="right"><strong>RANGE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></td>
      <td colspan="4"><input type="text" name="week_day" size="20" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeyPress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" onKeyUp="javascript:this.value=this.value.toUpperCase();">
        (M-T-W-TH-F-SAT-S) </td>
    </tr>
    <tr bgcolor="#e0e0e0"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">&nbsp;</td>
      <td colspan="4"><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_from_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
        <input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
        <select name="time_to_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
    </tr>
	    <tr bgcolor="#e0e0e0">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">&nbsp;</td>
    </tr>

    <tr > 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr > 
      <td height="25" width="2%">&nbsp;</td>
      <td width="36%">
<%
strTemp = WI.fillTextValue("plot2D");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="plot2D" value="1" <%=strTemp%>>
        Plot 2D Graph</td>
      <td width="27%">&nbsp;</td>
      <td width="35%">
<%
strTemp = WI.fillTextValue("showData");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="showData" value="1" <%=strTemp%>>
        Show Data and Graph</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">NOTE: For details go to <strong><font color="#000066">ENROLMENT/STATISTICS 
        module </font></strong> <div align="right"></div></td>
      <td height="25"><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border=0></a>click 
          to print</div></td>
    </tr>
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF">ROOMS 
          STATISTICS <strong>: (<%=request.getParameter("sy_from_prev") +" - "+request.getParameter("sy_to_prev")%>) 
          TO (<%=request.getParameter("sy_from") +" - "+request.getParameter("sy_to")%>) 
          : &amp;TERM : <%=astrConvertToSem[Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"4"))]%> 
          <br>
          ROOM STATUS : <%=WI.getStrValue(request.getParameter("room_status_name"),"N/A").toUpperCase()%> 
          FOR DURATION : <%=request.getParameter("range")%></strong></font></div></td>
    </tr>
  </table>
<%if(WI.fillTextValue("showData").length() > 0 || 
	(WI.fillTextValue("plot2D").length() == 0 && WI.fillTextValue("plot3D").length() ==0) ){%>
  <table   width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="27%" height="25"><div align="center"><font size="1"><strong>SCHOOL 
          YEAR</strong></font></div></td>
      <td width="24%"><div align="center"><font size="1"><strong>SUBJECT OFFERING 
          STATUS</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>NO. OF SUBJECTS</strong></font></div></td>
    </tr>
<%
for(int i = 1; i< vRetResult.size(); i+=5){

	strTemp = (String)vRetResult.elementAt(i+2)+" - "+(String)vRetResult.elementAt(i+3);
%>
<!--Open-->
<%
strErrMsg = WI.fillTextValue("room_stat");
if(strErrMsg.length() ==0 || strErrMsg.startsWith("O")){%>
    <tr> 
      <td height="25" align="center"><%=strTemp%></td>
      <td height="25">OCCUPIED</td>
      <td height="25"><%=(String)vRetResult.elementAt(i)%></td>
    </tr>
<%
strTemp = "";
}if(strErrMsg.length() ==0 || strErrMsg.startsWith("A")){%>
<!--Closed-->
    <tr> 
      <td height="25" align="center"><%=strTemp%></td>
      <td height="25">AVAILABLE</td>
      <td height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
    </tr>
<%
}

}//end of for loop%>  
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" >&nbsp;</td>
    </tr>
</table>
<%}//only if WI.fillTextValue("plot2D").length() ==0 or show data and graph)
if(strGraphInfo != null){%>
<%=WI.getStrValue(strGraphInfo)%>
<%}%>

<!--  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="6" ><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border=0></a>click 
          to print</div></td>
    </tr>
</table>-->
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<!--    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="6">&nbsp;</td>
    </tr> -->
    <tr bgcolor="#004488">
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="room_status_name">  
<input type="hidden" name="range">
<input type="hidden" name="page_value" value="1">  
</form>  
</body>
</html>
<%
dbOP.cleanUP();
%>