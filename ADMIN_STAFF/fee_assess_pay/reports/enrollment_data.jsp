<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(){
	document.bgColor = "#FFFFFF";
	document.getElementById('tHeader1').deleteRow(0);
	document.getElementById('tHeader1').deleteRow(0);	
	
	document.getElementById('tHeader2').deleteRow(0);
	document.getElementById('tHeader2').deleteRow(0);
	document.getElementById('tHeader2').deleteRow(0);
	document.getElementById('tHeader2').deleteRow(0);
	document.getElementById('tHeader2').deleteRow(0);
	
	document.getElementById('tDataHead').deleteRow(0);
	
	document.getElementById('tFooter').deleteRow(0);
	document.getElementById('tFooter').deleteRow(0);
	window.print();
}
</script>
<body>
<%@ page language="java" import="utility.*, enrollment.FAStudentLedgerExtn ,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment-Reports-Enrollment Data.",
								"enrollment_data.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments",
														"REPORTS",request.getRemoteAddr(),
														"enrollment_data.jsp");
**/


//end of authenticaion code.
FAStudentLedgerExtn FASLedg = new FAStudentLedgerExtn();
Vector vRetResult = null;
double dTotal = 0d;
double dTemp = 0d;
String[] astrSemester =  {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("semester").length()>0) {	
	vRetResult = FASLedg.getEnrollmentData(dbOP, request);
	if (vRetResult == null)
		strErrMsg = FASLedg.getErrMsg();
}
%>
<form action="./enrollment_data.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          ENROLLMENT DATA PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tHeader2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">SY/TERM</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <%strTemp = WI.fillTextValue("semester");
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
          <%}%>
        </select>
		
		&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="./enrollment_data_detail.jsp">Go To Enrollment Data detail (per student)</a>
		
		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Cutoff date </td>
      <td colspan="2"><font size="1">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font></td>
    </tr>
    
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td width="53%">
	<%if (strTemp==null || strTemp.length()==0 )
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 order by course_name asc";
	else
		strTemp = " from course_offered where is_del = 0 and is_valid = 1 and c_index = "+strTemp+
		" order by course_name asc";
	%>
      <select name="course_index">
          <option value="">All</option>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, WI.fillTextValue("course_index"), false)%>
        </select>      </td>
      <td width="29%">Year Level: 
      <%strTemp = WI.fillTextValue("yr_lvl");%>
      <select name="yr_lvl">
		<option value="">N/A</option>      
	<%if (strTemp.equals("1")){%>
		<option value="1" selected>1</option>
	<%} else {%>
		<option value="1">1</option>
	<%} if (strTemp.equals("2")){%>
		<option value="2" selected>2</option>
	<%} else {%>
		<option value="2">2</option>
	<%} if (strTemp.equals("3")){%>
		<option value="3" selected>3</option>
	<%} else {%>
		<option value="3">3</option>
	<%} if (strTemp.equals("4")){%>		
		<option value="4" selected>4</option>
	<%} else {%>
		<option value="4">4</option>
	<%} if (strTemp.equals("5")){%>
		<option value="5" selected>5</option>
	<%} else {%>
		<option value="5">5</option>
	<%} if (strTemp.equals("6")){%>
		<option value="6" selected>6</option>
	<%} else {%>
		<option value="6">6</option>
	<%}%>
      </select>      </td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="exclude_os" value="checked" <%=WI.fillTextValue("exclude_os")%>> Exclude outstanding balance </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><span class="thinborderNONE">
        <%
		if(WI.fillTextValue("clean_up").length() > 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
        <input name="clean_up" type="checkbox" value="1"<%=strTemp%>>
        <font style="font-size:9px; font-weight:bold; color:#0000FF"> Initialize Tuition and Discount : (slower generation - incase of balance does not match)</font></span></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2"><span class="thinborder">
        <input type="submit" name="1" value="Generate Report" style="font-size:11px; height:28px;border: 1px solid #FF0000;">
      </span></td>
    </tr>
  </table>

  <%if (vRetResult != null && vRetResult.size()>0){%>
  
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tDataHead">
		<tr>
			<td align="right" height="25"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print </font></td>
		</tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
    <tr>
      <td colspan="3"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="3"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="3" valign="top"><div align="center"><strong>ENROLLMENT DATA 
	  	<%=WI.getStrValue(WI.fillTextValue("date_fr"), " as of date : ", "","")%>
	  <br>
		  <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td width="35%" height="24" align="right">Date and time printed : </td>
      <td width="23%" height="24">&nbsp;<%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
<%/**%>
<!-- changed to lesser columns.	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="16%" height="25" class="thinborder"><font size="1"><strong>Course-Yr Level</strong></font></td>
			<td width="7%" class="thinborder"><font size="1"><strong>Total Student</strong></font></td>
			<td width="7%" class="thinborder"><font size="1"><strong>Total Units</strong></font></td>
			<td width="12%" class="thinborder"><font size="1"><strong>Total Tuition</strong></font></td>
			<td width="11%" class="thinborder"><font size="1"><strong>Total Discount</strong></font></td>
			<td width="11%" class="thinborder"><font size="1"><strong>Other Fees &amp; Adjustments</strong></font></td>
		    <td width="12%" class="thinborder"><font size="1"><strong>Total Payable</strong></font></td>
		    <td width="12%" class="thinborder"><font size="1"><strong>Total Payment</strong></font></td>
		    <td width="12%" class="thinborder"><font size="1"><strong>Total Balance</strong></font></td>
	    </tr>
<%
for(int i = 8; i < vRetResult.size(); i += 10) {%>
		<tr>
		  <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "-","","")%></td>
		  <td  class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td  class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), false)%></td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 4)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 5)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 6)%>&nbsp;</td>
	      <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 7)%>&nbsp;</td>
	      <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 8)%>&nbsp;</td>
	      <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 9)%>&nbsp;</td>
      </tr>
<%}
int iTotalStud = Integer.parseInt(WI.getStrValue((String)vRetResult.remove(0), "0"));
%> 
		<tr>
		  <td height="25" align="right" class="thinborder"><strong>TOTAL &nbsp;&nbsp;</strong></td>
		  <td class="thinborder"><%=iTotalStud%></td>
		  <td class="thinborder"><%=vRetResult.remove(0)%></td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.remove(0)%>&nbsp;</td>
	  </tr>
	</table>
--><%**/%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="16%" height="25" class="thinborder"><font size="1"><strong>Course-Yr Level</strong></font></td>
			<td width="7%" class="thinborder"><font size="1"><strong>Total Student</strong></font></td>
			<td width="7%" class="thinborder"><font size="1"><strong>Total Units</strong></font></td>
			<td width="12%" class="thinborder"><font size="1"><strong>Total Tuition Fee </strong></font></td>
			<td width="11%" class="thinborder"><font size="1"><strong>Total Payment </strong></font></td>
			<td width="12%" class="thinborder"><font size="1"><strong>Total Discount </strong></font></td>
		    <td width="12%" class="thinborder"><font size="1"><strong>Total Balance</strong></font></td>
	    </tr>
<%

for(int i = 8; i < vRetResult.size(); i += 10) {%>
		<tr>
		  <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 1), "-","","")%></td>
		  <td  class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td  class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), false)%></td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 7)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 8)%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 5)%>&nbsp;</td>
	      <td align="right"  class="thinborder"><%=vRetResult.elementAt(i + 9)%>&nbsp;</td>
      </tr>
<%}
int iTotalStud = Integer.parseInt(WI.getStrValue((String)vRetResult.remove(0), "0"));
String strTotUnit    = (String)vRetResult.remove(0);
String strTotalAsmt  = (String)vRetResult.remove(0);
String strTotDisc    = (String)vRetResult.remove(0);
String strTotaPost   = (String)vRetResult.remove(0);
String strTotPayable = (String)vRetResult.remove(0);
String strTotPaid    = (String)vRetResult.remove(0);
String strTotBal     = (String)vRetResult.remove(0);
%> 
		<tr>
		  <td height="25" align="right" class="thinborder"><strong>TOTAL &nbsp;&nbsp;</strong></td>
		  <td class="thinborder"><%=iTotalStud%></td>
		  <td class="thinborder"><%=strTotUnit%></td>
		  <td align="right"  class="thinborder"><%=strTotPayable%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=strTotPaid%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=strTotDisc%>&nbsp;</td>
		  <td align="right"  class="thinborder"><%=strTotBal%>&nbsp;</td>
	  </tr>
	</table>
<%
//find total students dropped.. 
strErrMsg = "select count(*) from stud_curriculum_hist where not exists "+
	"(select count(*) from enrl_final_cur_list where user_index = stud_curriculum_hist.user_index and "+
	"is_valid = 1 and is_del = 0 and sy_from = "+WI.fillTextValue("sy_from")+
	" and current_semester = "+WI.fillTextValue("semester")+") and sy_from = "+WI.fillTextValue("sy_from")+
	" and semester = "+WI.fillTextValue("semester");
	java.sql.ResultSet rs = dbOP.executeQuery(strErrMsg);
	rs.next();
int iTotalDropped = rs.getInt(1);
	rs.close();
%> 	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr >
      <td width="10%" height="25" class="thinborderNONE"> Dropped:<br>
	  Total:</td>
      <td colspan="4" class="thinborderNONE"><%=iTotalDropped%><br>
	    <%=iTotalStud - iTotalDropped%></td>
    </tr>
    <tr >
      <td height="25" class="thinborderNONE">&nbsp;</td>
      <td width="6%" class="thinborderNONE">&nbsp;</td>
      <td width="28%" class="thinborderNONE"><strong>Prepared By </strong></td>
      <td width="28%" class="thinborderNONE"><strong>Verified By </strong></td>
      <td width="28%" class="thinborderNONE"><strong>Noted By </strong></td>
    </tr>
    <tr >
      <td height="25" class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
      <td class="thinborderNONE"><strong>Daneli T. Bier<br>
      Accounting Clerk</strong></td>
      <td class="thinborderNONE"><strong>Digna A. Castro<br>
      Asst. Controller</strong></td>
      <td class="thinborderNONE"><strong>Elisa P. Bernardo<br>
      Controller</strong></td>
    </tr>
  </table>
<%}//end of displaying report.. %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr >
      <td width="100%" height="25">&nbsp;</td>
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