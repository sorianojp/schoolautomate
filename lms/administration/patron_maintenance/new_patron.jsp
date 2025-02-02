<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function focusID() {
	document.form_.user_id.focus();
}
function ShowSchedule() {
	var loadPg = "../../../ADMIN_STAFF/enrollment/reports/student_sched.jsp?offering_sem="+document.form_.offering_sem.value+
		"&sy_from="+document.form_.sy_from.value+"&sy_to="+
		document.form_.sy_to.value+"&stud_id="+
		escape(document.form_.user_id.value)+"&show_instructor=1&reloadPage=1";

	var win=window.open(loadPg,"myfile",'dependent=no,width=900,height=655,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function ResetPrevAction() {
	document.form_.page_action.value = "";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.user_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtPatron,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	String strUserIndex = null;//ID index of library user.

	String[] astrSchoolYrInfo = null;
	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr","9th Yr"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-PATRON MANAGEMENT","new_patron.jsp");
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
														"LIB_Administration","PATRON MANAGEMENT",request.getRemoteAddr(),
														"new_patron.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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

astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	strErrMsg = "School year not set";
}
//end of authenticaion code.
	MgmtPatron mgmtPatron       = new MgmtPatron();
	lms.MgmtCirculation mgmtCir = new lms.MgmtCirculation();
	LmsUtil lUtil               = new LmsUtil();
	
	Vector vLibUserInfo = null;
	Vector vBorrowMaxValParam = null;
	Vector vBorrowPeriodParam = null;
	
	if(WI.fillTextValue("user_id").length() > 0 && strErrMsg == null) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null) {
			strErrMsg = "Library User ID : "+WI.fillTextValue("user_id")+" does not exist.";
		}
		else {
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0) {
				mgmtPatron.operateOnPatron(dbOP, request,Integer.parseInt(strTemp)); 
				strErrMsg = mgmtPatron.getErrMsg();
			}
			vLibUserInfo = lUtil.getLibraryUserInfo(dbOP, strUserIndex, astrSchoolYrInfo[0], astrSchoolYrInfo[1], 
				astrSchoolYrInfo[2]);
			if(vLibUserInfo == null)
				strErrMsg = lUtil.getErrMsg();
			else {//call only if patron type is not null;				
				if(vLibUserInfo.elementAt(9) == null)
					strTemp = " and LMS_CL_BP.patron_type_index is null";
				else	
					strTemp = " and LMS_CL_BP.patron_type_index="+(String)vLibUserInfo.elementAt(9);
				request.setAttribute("addl_con",strTemp);
				vBorrowMaxValParam = mgmtCir.operateOnBorrowingParam(dbOP, request, 4);
				//if(vBorrowMaxValParam == null)
				//	strErrMsg = mgmtCir.getErrMsg();
			}
		}
				
	}
	
	//if vBorrowMaxValParam != null get BORROWING(LOAN) PERIOD PARAMETERS = CIRCULATION TYPE PARAM (in jsp file)
	if(vBorrowMaxValParam != null) {
		request.setAttribute("pat_type_index",WI.getStrValue(vLibUserInfo.elementAt(9)));
		vBorrowPeriodParam = mgmtCir.operateOnCirTypeParam(dbOP, request, 4);
	}
	
%>

<body bgcolor="#DEC9CC" topmargin="2" leftmargin="2" rightmargin="0" onLoad="focusID();">
<form action="./new_patron.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PATRON MANAGEMENT - PATRON PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="32" class="thinborderBOTTOM">&nbsp;</td>
      <td width="9%" class="thinborderBOTTOM">Library ID</td>
      <td width="23%" class="thinborderBOTTOM"><input type="text" name="user_id" value="<%=WI.fillTextValue("user_id")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
      <td width="65%" colspan="2" class="thinborderBOTTOM">
	  <input type="image" src="../../images/form_proceed.gif" onClick="ResetPrevAction();">
        &nbsp;&nbsp;&nbsp;<a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a> 
        &nbsp;&nbsp;&nbsp; <strong> <font size="3">A</font><font size="3">Y : 
        <%=astrSchoolYrInfo[0]%> - <%=astrSchoolYrInfo[1]%>, 
		  <%=astrConvertSem[Integer.parseInt(astrSchoolYrInfo[2])]%></font></strong></td>
    </tr>
	</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" width="3%">&nbsp;</td>
      <td width="18%" height="18"><div align="center"><strong> </strong></div></td>
      <td width="13%" height="18">&nbsp;</td>
      <td width="27%" height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <%if(vLibUserInfo != null && vLibUserInfo.size() > 0) {%>
    <tr bgcolor="#DDDDEE"> 
      <td height="24">&nbsp;</td>
      <td height="24" colspan="4"><font color="#FF0000">MEMBERSHIP INFORMATION 
        :</font></td>
    </tr>
    <%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="33">&nbsp;</td>
      <td height="33">Patron Type</td>
      <td height="33"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(5),"<font color=red>NOT ASSIGNED</font>")%></strong></td>
      <td height="33" colspan="2">
	  <%
	  //if patron type is student, do not let it b changed. 
	  if(vLibUserInfo.elementAt(5) == null || ((String)vLibUserInfo.elementAt(5)).toLowerCase().compareTo("student") != 0){
	  %>New Patron Type 
        <select name="PATRON_TYPE_INDEX" onChange="ReloadPage();">
<%=dbOP.loadCombo("PATRON_TYPE_INDEX","PATRON_TYPE"," from LMS_PATRON_TYPE where patron_type <> 'student' order by PATRON_TYPE_INDEX asc",strTemp, false)%> </select>
        <font size="1"><a href="javascript:PageAction(2);"><img src="../../images/save.gif" border="0"></a>Change 
        patron type.</font> 
        <%}//show only if patron is not student.%></td>
    </tr>
    <tr> 
      <td height="33">&nbsp;</td>
      <td height="33">Status </td>
      <td height="33"><strong>
	  <%if(vLibUserInfo.elementAt(15) == null){%>ACTIVE<%}else{%>BLOCKED<%}%></strong></td>
      <td height="33" colspan="2"><font size="1"> 
	  <%if(vLibUserInfo.elementAt(15) == null){%>
	  <a href="javascript:PageAction(0);"><img src="../../../images/block_user.gif" border="1"></a>click to block patron
	  <%}else{%>
	  <a href="javascript:PageAction(1);"><img src="../../../images/reactivate_user.gif" border="1"></a>click to unblock patron
	  <%}%>
	</font></td>
    </tr>
    <%}%>
    <tr bgcolor="#DDDDEE"> 
      <td height="24" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="24" colspan="4"><font color="#FF0000">PERSONNAL INFORMATION 
        :</font></td>
    </tr>
    <tr> 
      <td height="33">&nbsp;</td>
      <td> Name</td>
      <td colspan="2"><strong><%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),
	  		(String)vLibUserInfo.elementAt(4),4)%> </strong>(lname,fname,mi)</td>
      <td width="39%" rowspan="5" valign="top">
	  <img src="../../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>" 
	  width="150" height="150" border="1"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Birth Date, Gender</td>
      <td colspan="2"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(10),"Not Set")%>, <%=WI.getStrValue(vLibUserInfo.elementAt(11),"Not Set")%></strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Contact Address</td>
      <td colspan="2"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(12),"Not Set")%></strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Contact Nos.</td>
      <td colspan="2"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(13),"Not Set")%></strong></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Email Address</td>
      <td colspan="2"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(14),"Not Set")%></strong></td>
    </tr>
    <tr bgcolor="#DDDDEE"> 
      <td height="24" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="24" colspan="4"><font color="#FF0000">OTHER INFORMATION :</font></td>
    </tr>
<%
if( ((String)vLibUserInfo.elementAt(0)).compareTo("1") == 0) {//student %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="3"><strong><%=(String)vLibUserInfo.elementAt(6)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Major</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(7),"NONE")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level</td>
      <td><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(8),"N/A")%></strong></td>
      <td colspan="2"><a href="javascript:ShowSchedule();">
	  	<img src="../../images/schedule.gif" width="60" height="25" border="0"></a><font size="1">click 
        to view schedule of students</font></td>
    </tr>
<%}else{//employee%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College/Dept</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(6),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Office</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(5),"N/A")%></strong></td>
    </tr>
<%}%>	
    <tr> 
      <td height="20">&nbsp;</td>
      <td colspan="4" valign="middle">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="24" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="24" colspan="4" bgcolor="#DDDDEE"><font color="#FF0000">TYPE 
        POLICIES INFORMATION :</font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td colspan="2"><strong>BORROWING MAXIMUM VALUE PARAMETERS
	  <%if(vBorrowMaxValParam == null || vBorrowMaxValParam.size() == 0) {%>
	  	:<font color="#FF0000"> NOT SET</font>
	  <%}%>
	</strong></td>
      <td width="4%">&nbsp;</td>
      <td width="4%">&nbsp;</td>
    </tr>
</table>
<%if(vBorrowMaxValParam != null && vBorrowMaxValParam.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong><font size="1">PATRON 
          TYPE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">BORROWING(LOAN)</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FIXED 
          BORROWING DUE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">ALLOWABLE 
          OVERDUE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">OVERRIDE 
          DUE DATE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FINES</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">MAX. 
          RESERVE</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">RES. 
          PRIORITY</font></strong></div></td>
    </tr>
    <%
String[] astrConvertResPriority = {"","High","Medium","Medium-Low","Low"};
for(int i = 0; i < vBorrowMaxValParam.size(); i += 10){%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vBorrowMaxValParam.elementAt(i + 2),"General(for all)")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vBorrowMaxValParam.elementAt(i + 3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vBorrowMaxValParam.elementAt(i + 5))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vBorrowMaxValParam.elementAt(i + 8)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(vBorrowMaxValParam.elementAt(i + 9))%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vBorrowMaxValParam.elementAt(i + 4)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vBorrowMaxValParam.elementAt(i + 6)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=astrConvertResPriority[Integer.parseInt((String)vBorrowMaxValParam.elementAt(i + 7))]%></font></td>
    </tr>
    <%}%>
  </table>
<%}//if vBorrowMaxValParam != null%>

	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td colspan="2"><strong>BORROWING(LOAN) PERIOD PARAMETERS
        <%if(vBorrowPeriodParam == null || vBorrowPeriodParam.size() == 0) {%>
        :<font color="#FF0000"> NOT SET</font> 
        <%}%>
        </strong></td>
      <td width="2%">&nbsp;</td>
    </tr>
  </table>
<%if(vBorrowPeriodParam != null && vBorrowPeriodParam.size() > 0) {%>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="20%" height="25" class="thinborder"><div align="center"><font size="1"><strong>CIRCULATION 
          TYPE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>LOAN 
          PERIOD</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>GRACE 
          PERIOD</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>MAX. 
          RENEWAL</strong></font></div></td>
      <td width="10%" class="thinborder"><font size="1"><strong>MAX. LOAN FOR 
        THIS CIRC. TYPE</strong></font></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>FINE 
          INCREMENT</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>MAX. 
          FINE OR PENALTY</strong></font></div></td>
    </tr>
    <%
String[] astrConvertUnit = {" Day(s)"," Hour(s)","FIXED"};
for(int i = 0; i < vBorrowPeriodParam.size(); i += 12){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vBorrowPeriodParam.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vBorrowPeriodParam.elementAt(i + 3))%> <%=astrConvertUnit[Integer.parseInt((String)vBorrowPeriodParam.elementAt(i + 4))]%></td>
      <td class="thinborder">&nbsp; <%if(vBorrowPeriodParam.elementAt(i + 5) != null) {%> <%=(String)vBorrowPeriodParam.elementAt(i + 5)%> <%=astrConvertUnit[Integer.parseInt((String)vBorrowPeriodParam.elementAt(i + 6))]%> <%}%> </td>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vBorrowPeriodParam.elementAt(i + 7),""," time(s)","")%></td>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vBorrowPeriodParam.elementAt(i + 8),""," time(s)","")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vBorrowPeriodParam.elementAt(i + 9))%></td>
      <td class="thinborder">&nbsp; <%if(vBorrowPeriodParam.elementAt(i + 10) == null) {%>
        Price of Item Loanded
        <%}else{%> <%=(String)vBorrowPeriodParam.elementAt(i + 10)%> Amount 
        <%}%></td>
    </tr>
    <%}//end of for loop%>
  </table>
<%}//end of vBorrowPeriodParam is not null

}//show only if(vLibUserInfo != null && vLibUserInfo.size() > 0)
%>

<%if(astrSchoolYrInfo != null) {%>
	<input type="hidden" name="sy_from" value="<%=astrSchoolYrInfo[0]%>">
	<input type="hidden" name="sy_to" value="<%=astrSchoolYrInfo[1]%>">
	<input type="hidden" name="offering_sem" value="<%=astrSchoolYrInfo[2]%>">
	
<%}%>
<input type="hidden" name="page_action">
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>