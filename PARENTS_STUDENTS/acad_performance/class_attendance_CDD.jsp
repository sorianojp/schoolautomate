<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">

<style type="text/css">

.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}

</style>

<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>

<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	String strUserID    = (String)request.getSession(false).getAttribute("userId");
	if(strUserIndex == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	//check if elem student.
	String strSQLQuery = "select course_index from stud_curriculum_hist "+
		"join semester_sequence on (semester_sequence.semester_val = semester) "+
		"where is_valid = 1 and user_index = "+
		request.getSession(false).getAttribute("userIndex")+" order by sy_from desc, sem_order desc";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
	if(strSQLQuery.equals("0")) {//basic
		dbOP.cleanUP();
		
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Not Available for Grade School Student</font></p>
		<%
		return;
	}
	
	
int iElemCount = 0;	
	
ClassMgmt.CMAttendance attendance = new ClassMgmt.CMAttendance(request);
Vector vRetResult = attendance.getClassAttendancePerStudentCDD(dbOP);
if(vRetResult == null)
	strErrMsg = attendance.getErrMsg();
else
	iElemCount = attendance.getElemCount();
%>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function viewStatus(strSubIndex){
	if(strSubIndex.lenght == 0)
		return;
		
	var strSYFrom = document.cm_op.sy_from.value;
	var strSem    = document.cm_op.semester.value;
	var strUserIndex = <%=strUserIndex%>;
	var pgLoc = "./view_status_CDD.jsp?view_status=1&faculty_encoding=1&user_index="+strUserIndex+
		"&subject="+strSubIndex+		
		"&sy_from="+strSYFrom+
		"&sy_to="+(parseInt(strSYFrom)+1)+
		"&offering_sem="+strSem;
	var win=window.open(pgLoc,"viewStatus",'width=400,height=500,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#93B5BB">
<form name="cm_op" method="post" action="./class_attendance_CDD.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td width="656" height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT CLASS ATTENDANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="25">&nbsp;&nbsp;SY/Term : 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
-
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
	
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
  <%if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
  <%if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="submit" name="132" value="Refresh Display" style="font-size:11px; height:22px;border: 1px solid #FF0000;">
    </td>
	</tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="3" class="thinborder" align="right">Total Days of Attendance : <%=WI.getStrValue(vRetResult.remove(0))%></td>
    </tr>
    <tr bgcolor="#98B9CD"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><strong>ATTENDANCE SHEET</strong></div></td>
    </tr>
    <tr> 
      <td width="23%" class="thinborder"><div align="center"><strong>Subject Code </strong></div></td>
      <td width="59%" height="25" class="thinborder"><div align="center"><strong>Subject Title </strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong>Total Absence </strong></div></td>
    </tr>
<%for(int i =0; i < vRetResult.size(); i += iElemCount){%>
   <tr onDblClick="viewStatus('<%=(String)vRetResult.elementAt(i+3)%>');" class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" 
   	onMouseOut="navRollOver('msg<%=i%>', 'off')">
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"Not encoded")%></td>
    </tr>
<%}//%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5" align="center">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
	<tr bgcolor="#6A99A2"> 
    	<td height="25">&nbsp;</td>
  	</tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>