<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TABLE.thinborderALL{
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
	
		this.SubmitOnce('form_');
	}
-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,
ClassMgmt.CMAttendance" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	
	boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");

	
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-STUDENT'S PERFORMANCE-Edit Time-in Time-out","stud_attendance.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","ALL",request.getRemoteAddr(), 
														"stud_attendance.jsp");	
iAccessLevel = 2;
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
	String strPrepareToEdit = null;
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vStudBasicInfo = null;
	Vector vRetResult = null;
	CMAttendance cmA = new CMAttendance(request);
	String strStudID = WI.fillTextValue("stud_id");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strStudID.length() == 0 && bolIsStudent){
		strStudID = (String)request.getSession(false).getAttribute("userId");
	}

	
	
	if (strStudID.length() > 0){
		vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
		if (vStudBasicInfo == null){
			strErrMsg = offlineAdm.getErrMsg();
		}
		vRetResult = cmA.getStudAttendance(dbOP,request); // null lang bala anay
		
		if (vRetResult == null){
			strErrMsg = "";
		}
//		System.out.println(vRetResult);
	}
%>
<body bgcolor="#93B5BB">
<form action="stud_attendance.jsp" method="post" name="form_" >  
<% if (bolIsStudent) {%>
	<input type="hidden" value="<%=strStudID%>" name="stud_id">
<%}%> 
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          STUDENT ATTENDANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><font color="#FF0000" size="3">&nbsp; <%=WI.getStrValue(strErrMsg,"")%></font></td>
    </tr>
<% if (!bolIsStudent){%> 
    <tr bgcolor="#FFFFFF"> 
      <td width="11%"><font face="Verdana, Arial, Helvetica, sans-serif">Student 
        ID </font></td>
      <td width="22%" height="25"><input name="stud_id" type="text" class="textbox" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
						 value="<%=strStudID%>" size="15" maxlength="15"></td>
      <td width="67%" colspan="2"><a href="javascript:ReloadPage();"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
<%}%> 
    <tr bgcolor="#FFFFFF">
      <td>Show </td>
      <td height="25"><select name="select_view" onChange="ReloadPage()">
	  <option value="0">Specify Date</option>
	  <% if(WI.fillTextValue("select_view").equals("1")) { %>
	  <option value="1" selected>Specify Sem / Subject</option>
	  <%}else{%>
	  <option value="1">Specify Sem / Subject</option>
	  <%}%> 	  
      </select>
      </td>
      <td colspan="2"><a href="javascript:ReloadPage();">
<% if (bolIsStudent) {%> 
	  <img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a>
<%}%> 
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
<% if (!WI.fillTextValue("select_view").equals("1")) {


%> 
    <tr bgcolor="#FFFFFF">
      <td width="17%">Attendance Date</td>
      <td height="25" colspan="4">From : 
        <input name="date_attendance" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_attendance")%>" size="12" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_attendance');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif"  border="0"></a>&nbsp;&nbsp;&nbsp;To : 
        <input name="date_attendance2" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_attendance")%>" size="12" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_attendance');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif"  border="0"></a> <font size="1">(Leave &quot; date to&quot; empty to check  for a day)</font></td>
    </tr>
<%}else{%> 
    <tr bgcolor="#FFFFFF">
      <td>School Year / Term</td>
      <td width="17%" height="25"><%
	strTemp  = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>	  
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>- 
<%
	strTemp  = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
      <td width="14%"><%
	strTemp  = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
        <select name="semester" id="semester">
          <option value="1">1st</option>
          <% if (strTemp.equals("2")){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}
		  if (!strSchCode.startsWith("CPU")) { 
		  	if (strTemp.equals("3")){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if (strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}
		  } // 
		  
		  if (strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="9%">Subject : </td>
      <td width="43%">
	  <input name="sub_index" type="text" class="textbox" 
	    onFocus="style.backgroundColor='#D3EBFF'" size="16"
		onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("sub_index")%>" ></td>
    </tr>
 <%}%> 
  </table>
  <% if (vStudBasicInfo != null) {%>

  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong>STUDENT NAME</font> :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%"><font size="2">COURSE </font> : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong></font><font size="2">YEAR LEVEL </font> : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td><font size="2">MAJOR : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null) {

		String[] astrStatus ={"Present","Absent","Late","Sent Out"};
%>
  <table width="100%" border="0" cellpadding="5" cellspacing="0">
    <tr bgcolor="#98B9CD"> 
      <td width="100%" height="30"><div align="center"><strong>ATTENDANCE SHEET 
          <%=WI.getStrValue(request.getParameter("date_attendance"),"FOR ","","")%></strong></div></td>
    </tr>
  </table>
<% } // if vRetResult != null
} // if vStudBasicInfo != null%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#6A99A2"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#6A99A2">
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>