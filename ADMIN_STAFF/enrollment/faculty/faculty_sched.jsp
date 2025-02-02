<%if(request.getParameter("forward_page") != null && request.getParameter("forward_page").compareTo("1") == 0){%>
<jsp:forward page="./faculty_sched_multiple.jsp" />
<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function copyValueToParent()
{
	if(document.facschedule.multiple_assign.value == 1) {
		document.facschedule.forward_page.value = 1;
		document.facschedule.submit();
		return;
	}
	
	eval('window.opener.document.faculty_page.'+document.facschedule.opner_fac_index.value+'.value='+document.facschedule.fac_index.value);
	eval('window.opener.document.faculty_page.'+document.facschedule.opner_fac_name.value+'.value=\"'+document.facschedule.fac_name.value+'\"');
	
	window.close();
}
function AssignValue(strFacultyName,strFacultyIndex)
{
	document.facschedule.fac_name.value = strFacultyName;
	document.facschedule.fac_index.value = strFacultyIndex;
	//alert(strFacultyName);
	//alert(strFacultyIndex);
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous


	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-FACULTY-LOADING"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-schedule","faculty_sched.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","FACULTY",request.getRemoteAddr(),
														"faculty_sched.jsp");
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
**/
//end of authenticaion code.

String strSubSecIndex = request.getParameter("sec_index");
String strSchedule    = request.getParameter("schedule");
String strRoomNo      = request.getParameter("room_no");
String strLECLAB      = request.getParameter("LECLAB");
String strTotalUnit   = request.getParameter("total_unit");

String strCollegeIndex = request.getParameter("c_index");
String strOfferingYrFrom = request.getParameter("sub_off_yrf");
String strOfferingYrTo = request.getParameter("sub_off_yrt");
String strOfferingSem  = request.getParameter("offering_sem");
String strOfficeIndex = request.getParameter("d_index");
String strSubIndex = request.getParameter("sub_index");


if(strSubSecIndex == null || strSubSecIndex.trim().length() ==0)
	strErrMsg = "Subject Section information missing.";
if(strSchedule == null || strSchedule.trim().length() ==0)
	strErrMsg = "Subject schedule information missing.";
if(strTotalUnit == null || strTotalUnit.trim().length() ==0)
	strErrMsg = "Subject total unit information missing.";
if(strCollegeIndex == null || strCollegeIndex.trim().length() ==0)
	strErrMsg = "College information missig.";
if(strOfferingYrFrom == null || strOfferingYrFrom.trim().length() ==0 || strOfferingYrTo == null || strOfferingYrTo.trim().length() ==0)
	strErrMsg = "School offering year from/to missing.";

Vector vFacultyList  = new Vector();
float fSubjectUnit = 0f;//I need this to check if faculty is crossing over max units.
if(strTotalUnit != null && strTotalUnit.length() > 0) {
	int iIndex = strTotalUnit.indexOf("(");
	if(iIndex != -1) 
		strTemp = strTotalUnit.substring(0, iIndex);
	else	
		strTemp = strTotalUnit;
	fSubjectUnit = Float.parseFloat(strTemp);
}//System.out.println(strSubIndex);
if(strErrMsg == null) {
	FacultyManagement FM = new FacultyManagement();
	if(WI.fillTextValue("multiple_assign").compareTo("1") == 0)
		vFacultyList = FM.viewFacPerCollegeWithLoadStat(dbOP, strCollegeIndex,strSubSecIndex,strOfferingYrFrom,strOfferingYrTo,
							strOfferingSem,"",false,0f,strOfficeIndex,strSubIndex);
	else	
		vFacultyList = FM.viewFacPerCollegeWithLoadStat(dbOP, strCollegeIndex,strSubSecIndex,strOfferingYrFrom,strOfferingYrTo,
							strOfferingSem,"",true,fSubjectUnit,strOfficeIndex,strSubIndex);
	if(vFacultyList == null)
		strErrMsg = FM.getErrMsg();
		
}
%>
<form name="facschedule" action="./faculty_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FACULTY PAGE - LOADING/SCHEDULING ::::</strong></font></div></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><%=strErrMsg%></td>
    </tr>
    <%dbOP.cleanUP();return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="16%">Subject Title(code) : </td>
	  <td width="82%"><b><%=request.getParameter("subject")%></b></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="16%"> Unit :</td>
      <td colspan="2"><b><%=strLECLAB%> <%=strTotalUnit%></b></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Schedule : <b></b></td>
      <td width="31%" valign="top"><b><%=strSchedule%></b></td>
      <td width="51%" valign="top">Room #: <b><%=WI.fillTextValue("room_no")%></b></td>
    </tr>
    <tr>
      <td colspan="4" height="25">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">LIST OF FACULTIES FROM <strong><%=request.getParameter("college_name")%></strong></div></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
      <td width="16%" height="25" colspan="6">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
  </table>
  <table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFCC"> 
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>COLLEGE 
          :: DEPT</strong></font></div></td>
      <td width="11%" height="20" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          ID</strong></font></div></td>
      <td width="29%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME(LNAME,FNAME,MI)</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>GENDER</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>EMP. STATUS</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>MAX 
          ALLOWED LOAD</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>TOTAL 
          LOAD</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>SELECT</strong></font></div></td>
    </tr>
    <%//System.out.println(" vFacultyList : "+vFacultyList);
	boolean bolNotSet = false;
	
 for(int i = 0 ; i< vFacultyList.size(); ++i){
 strTemp = WI.getStrValue((String)vFacultyList.elementAt(i+8));
 if(strTemp.equals("0") || strTemp.equals("0.0")) 
 	bolNotSet = true;
 else
 	bolNotSet = false;
	//System.out.println("bolIsNotSet : "+bolNotSet+" : User : "+vFacultyList.elementAt(i+1)+" :strTemp "+strTemp);%>
    <tr> 
      <td class="thinborder" height="25">&nbsp;<%=WI.getStrValue(vFacultyList.elementAt(i+5))%></td>
      <td class="thinborder">&nbsp;<%=(String)vFacultyList.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vFacultyList.elementAt(i+2)%></td>
      <td class="thinborder" align="center"><%=(String)vFacultyList.elementAt(i+4)%></td>
      <td class="thinborder" align="center"><%=(String)vFacultyList.elementAt(i+3)%></td>
      <td class="thinborder" align="center">
	  <%if(bolNotSet){%>
	  <font color="#0000FF">Not Set</font><%}else{%>
	  <%=WI.getStrValue((String)vFacultyList.elementAt(i+8))%><%}%></td>
      <td class="thinborder" align="center"><%=CommonUtil.formatFloat(WI.getStrValue((String)vFacultyList.elementAt(i+6)), false)%></td>
      <td class="thinborder" align="center">&nbsp;<%=(String)vFacultyList.elementAt(i+7)%></td>
      <td class="thinborder"><div align="center"> 
          <%
	  if( ((String)vFacultyList.elementAt(i+7)).length() ==0 && !bolNotSet){%>
          <input type="radio" name="radiobutton" value="<%=(String)vFacultyList.elementAt(i)%>" onClick='AssignValue("<%=(String)vFacultyList.elementAt(i+2)%>","<%=(String)vFacultyList.elementAt(i)%>");'>
          <%}else{%>
          &nbsp; 
          <%}%>
        </div></td>
    </tr>
    <%i = i+9;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="fac_name">
  <input type="hidden" name="fac_index">

  <input type="hidden" name="opner_fac_name" value="<%=WI.fillTextValue("opner_fac_name")%>">
  <input type="hidden" name="opner_fac_index" value="<%=WI.fillTextValue("opner_fac_index")%>">

  <input type="hidden" name="multiple_assign" value="<%=WI.fillTextValue("multiple_assign")%>">
  <input type="hidden" name="sec_index" value="<%=WI.fillTextValue("sec_index")%>">
  <input type="hidden" name="LECLAB" value="<%=WI.fillTextValue("LECLAB")%>">
  <input type="hidden" name="total_unit" value="<%=WI.fillTextValue("total_unit")%>">
  <input type="hidden" name="sub_off_yrf" value="<%=WI.fillTextValue("sub_off_yrf")%>">
  <input type="hidden" name="sub_off_yrt" value="<%=WI.fillTextValue("sub_off_yrt")%>">
  <input type="hidden" name="offering_sem" value="<%=WI.fillTextValue("offering_sem")%>">
  <input type="hidden" name="subject" value="<%=WI.fillTextValue("subject")%>">
  <input type="hidden" name="room_no" value="<%=WI.fillTextValue("room_no")%>">
  <input type="hidden" name="schedule" value="<%=WI.fillTextValue("schedule")%>">
  <input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">

  <input type="hidden" name="forward_page">



  </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
