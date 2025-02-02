<%@ page language="java" import="utility.*,enrollment.OfflineAdmission,java.util.Vector" %>
<%
String strIsOnlineAdvisingOpen = (String)request.getSession(false).getAttribute("online_advise");
if(strIsOnlineAdvisingOpen == null) {%>
<p style="font-size:14px; color:#FF0000; font-weight:bold">Illigal Page Call. Please login again and click on 'Online Avising/ Re-advise' Link</p>
<%return;}
if(!strIsOnlineAdvisingOpen.equals("1")){//can't do online advising..%>
<p style="font-size:14px; color:#FF0000; font-weight:bold">Online Avising is not allowed. Please login again and click the link in left panel. If you still have problem, please contact school authority in charge of online advising.</p>
<%return;}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

String strSYFromAdvise = new utility.ReadPropertyFile().getImageFileExtn("ONLINE_ADVISE_SYTERM","0");
String strSYToAdvise   = null;
String strTermAdvise   = null;//get from read property file :: ONLINE_ADVISE_SYTERM
if(strSYFromAdvise != null && strSYFromAdvise.length() ==6) {
	strTermAdvise   = String.valueOf(strSYFromAdvise.charAt(5));
	strSYFromAdvise = strSYFromAdvise.substring(0,4);
	strSYToAdvise = Integer.toString(Integer.parseInt(strSYFromAdvise) + 1);	
}
if(strSYToAdvise == null) {%>
<p style="font-size:14px; color:#FF0000; font-weight:bold">Online Advising SY/Term is not set. Please consult school authority in charge of online advising.</p>
<%return;}//end of validation.

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strStudStatus = "Old";
	Vector vTemp = new Vector();
	String strCourseIndex = null;
	String strMajorIndex = null;
	int i=0; int j=0;

	String strDegreeType = null;
	String strStudID = (String)request.getSession(false).getAttribute("userId");

	Vector vStudBasicInfo = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
if(strStudID == null)//for fatal error.
{
	dbOP.cleanUP();
%>
		<p align="left"> <font face="Verdana, Arial, Helvetica, sans-serif" size="4">
		You are already logged out.Please login again</font></p>
		<%
		return;
}

/** 
* make sure student is not on hold 
**/
String strHoldReason = new enrollment.SetParameter().bolStudentIsOnHold(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
if(strHoldReason != null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Advising is on hold: <%=strHoldReason%></font></p>


<%dbOP.cleanUP();
return;
}



//end of authenticaion code.
String[] astrConvertSem = {"Summer","1ST SEM","2ND SEM","3RD SEM"};
String[] astrConvertYr = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR","8TH YR"};
OfflineAdmission offlineAdm = new OfflineAdmission();
Vector vecRetResult = new Vector();

String strUserIndex       = null;
String strStudStat        = "Old"; String strPrepPropStat = null;
boolean bolIsAdmProcessed = false;//
String strSQLQuery        = null;
java.sql.ResultSet rs     = null;

if(WI.fillTextValue("addRecord").compareTo("1") ==0) {//addrecord now.
	//if already created, do not create anymore.
	strSQLQuery = "select old_stud_appl_index from na_old_stud where is_valid = 1 and sy_from="+strSYFromAdvise+" and semester= "+strTermAdvise+
					" and user_index = "+(String)request.getSession(false).getAttribute("userIndex");
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	//System.out.println(strSQLQuery);
	if(strSQLQuery == null && !offlineAdm.createApplicant(dbOP,request)) {
		strErrMsg = offlineAdm.getErrMsg();
		//System.out.println("Error: "+strErrMsg);
	}
	else {
		dbOP.cleanUP();
		if(strSchCode.startsWith("AUF")) {//eventually, it has to be removed. -- only to be used only if option selected is ""pre-secheduled sections.
			response.sendRedirect(response.encodeRedirectURL("../../ADMIN_STAFF/enrollment/advising/online_advising_old.jsp?online_advising=1&showList=1&sy_from="+
				strSYFromAdvise+"&sy_to="+strSYToAdvise+"&semester="+strTermAdvise));
		}
		else
			response.sendRedirect(response.encodeRedirectURL("../../ADMIN_STAFF/enrollment/advising/advising_old.jsp?is_forwarded=1&online_advising=1&showList=1&sy_from="+
				strSYFromAdvise+"&sy_to="+strSYToAdvise+"&semester="+strTermAdvise+"&stud_id="+strStudID));
		return;
	}
}else
{
	vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP,strStudID);//System.out.println(vStudBasicInfo);
	if(vStudBasicInfo == null) {
	 	strErrMsg = offlineAdm.getErrMsg();
		dbOP.cleanUP();
		%>
		<font face="Verdana, Arial, Helvetica, sans-serif" size="3">Student basic information not found.Please contact admin for 
		Registration process.</font>
		<%
		return;
	}
	else {
		strUserIndex = (String)vStudBasicInfo.elementAt(12);
		
		/**
		I have to check if student already thru' admission process.. 
		**/
		strSQLQuery = "select na_old_stud.course_index, na_old_stud.major_index, degree_type, cy_from, cy_to, year_level, appl_Catg, prep_prop_status, course_offered.course_code, "+//9
					"course_offered.course_name, major.course_code, major.major_name, college.c_name  from na_old_stud "+//13
					"join course_offered on (course_offered.course_index = na_old_stud.course_index) "+
					"left join major on (major.major_index = na_old_stud.major_index) "+
					"join college on (College.c_index = course_offered.c_index) "+
					"and na_old_stud.is_valid = 1 and user_index="+strUserIndex+" and sy_from = "+strSYFromAdvise+" and semester = "+strTermAdvise;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			vStudBasicInfo.setElementAt(rs.getString(1), 5);//course_index
			vStudBasicInfo.setElementAt(rs.getString(2), 6);//major_index
			strDegreeType = rs.getString(3);
			vStudBasicInfo.setElementAt(strDegreeType, 15);//degree_type
			vStudBasicInfo.setElementAt(rs.getString(4), 3);//cy_from
			vStudBasicInfo.setElementAt(rs.getString(5), 4);//cy_to
			vStudBasicInfo.setElementAt(rs.getString(6), 14);//yrlevel
			strStudStat = rs.getString(7);//appl_catg.
			strPrepPropStat = rs.getString(8);//prep_prop_stat.
			vStudBasicInfo.setElementAt(rs.getString(9), 24);//course_code
			vStudBasicInfo.setElementAt(rs.getString(10), 7);//course_name
			vStudBasicInfo.setElementAt(rs.getString(11), 25);//major.course_code
			vStudBasicInfo.setElementAt(rs.getString(12), 8);//major_name
			vStudBasicInfo.setElementAt(rs.getString(13), 26);//college.c_name
			
			vTemp.addElement(rs.getString(6));//yr level.
		}
	
		//System.out.println(strUserIndex);
		strCourseIndex = (String)vStudBasicInfo.elementAt(5);
		request.setAttribute("course_index",vStudBasicInfo.elementAt(5));
		request.setAttribute("major_index",vStudBasicInfo.elementAt(6));
		if(strDegreeType == null)
			strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",(String)vStudBasicInfo.elementAt(5),"DEGREE_TYPE", " and is_valid=1 and is_del=0");
	}
	
}

double dOSBalance        = 0d;
String strReason         = null;
boolean bolBlockAdvising = false;
boolean bolAllowAdvising = false;

strSQLQuery = "select block_advising, reason from advising_setting where user_index = "+strUserIndex+
					" and sy_from = "+strSYFromAdvise+" and semester = "+strTermAdvise;
rs = dbOP.executeQuery(strSQLQuery);
if(rs.next()) {
	strTemp = rs.getString(1);
	if(strTemp.equals("1"))
		bolBlockAdvising = true;
	else
		bolAllowAdvising = true;
	strReason = rs.getString(2);
}
rs.close();

/** 
1. If OS Balance, do not allow
2. Do not check OS Balance if forced allowed
3. Do not proceed if Advising is blocked.

4. do not allow if ENROLLMENT is closed :: added Jan 13, 2015.
**/
boolean bolFatalErr = false;
if(!bolAllowAdvising) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	dOSBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex, true, true);
	//System.out.println("Printing: "+fOperation.getErrMsg());
	//System.out.println(strUserIndex);
}
//I have to check if forced blocked or forced allowed.

//System.out.println(dOSBalance);
%>
<p style="font-weight:bold; color:#FF0000; font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif">
<%if(bolBlockAdvising) {bolFatalErr=true;%>
	Not Allowed to Advise <br>
	Reason: <%=strReason%>
<%}else if(	dOSBalance > 0.2d) {bolFatalErr=true;%>
	Not Allowed to Advise due to pending outstanding balance
<%}if(false && strSchCode.startsWith("NEU") && dOSBalance < -0.01d) {bolFatalErr=true;//removed for -ve balance.%>
	Not Allowed to Advise due to pending outstanding balance. Please proceed to accounting.
<%}
//I have to check if enrollment is closed.. 
if(new enrollment.SetParameter().isLockedGeneric(dbOP, strSYFromAdvise, strTermAdvise, "1", strUserIndex, "0", strCourseIndex)) {
	bolFatalErr=true;%>
	Enrollment already closed
	<%
}



%>
</p>
<%if(bolFatalErr) {
	dbOP.cleanUP();
    return;
}
//for fatima.. student must select a plan.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord()
{
	if(document.offlineRegd.plan_ref) {
		if(document.offlineRegd.plan_ref.selectedIndex == 0) {
			alert("Please select a Plan");
			return;
		}
	}
	document.offlineRegd.addRecord.value = "1";
	document.offlineRegd.submit();
}
function updatePlanFatima() {
	<%if(strUserIndex == null) {%>
		return;
	<%}else{%>
	
	var strCurID = "<%=strStudID%>";
	
	var strPlanRef = document.offlineRegd.plan_ref[document.offlineRegd.plan_ref.selectedIndex].value;
	//alert(strPlanRef);

	var strParam = "stud_ref=<%=strUserIndex%>&sy_from=<%=strSYFromAdvise%>"+
					"&semester=<%=strTermAdvise%>&is_tempstud=0&new_plan="+strPlanRef;
	var objCOAInput = document.getElementById("coa_info_splan");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=123&"+strParam;
	this.processRequest(strURL);	
	<%}%>
}

</script>

<body bgcolor="#9FBFD0">
<form action="./admission_registration_stud_online.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ADMISSION - REGISTRATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong> 
      </td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><strong><font color="#0000FF" size="3">NOTE 
        : Information on page this page is non-editable. If there is any wrong 
        enrollment information, please proceed to <%if(strSchCode.startsWith("NEU")){%>the registar's Office.<%}else{%>your college for advising.<%}%></font></strong></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td  width="2%"height="25">&nbsp;</td>
      <td width="18%" height="25">Student ID</td>
      <td width="71%" height="25"> <strong><font size="3"><%=strStudID%></font></strong> 
        <input type="hidden" name="stud_id" value="<%=strStudID%>"> <input type="hidden" name="stud_status" value="<%=strStudStat%>"></td>
      <td width="9%">&nbsp;</td>
    </tr>
  </table>
<%if(vStudBasicInfo != null && vStudBasicInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="61%">Course/Major</td>
      <td width="37%">Curriculum Year</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td> 
	  <input type="hidden" name="course_index" value="<%=(String)vStudBasicInfo.elementAt(5)%>"> 
	  <input type="hidden" name="major_index" value="<%=(String)vStudBasicInfo.elementAt(6)%>"> 
        <font size="3"><strong><%=(String)vStudBasicInfo.elementAt(7)%>
		<%if(vStudBasicInfo.elementAt(8) != null){%>
		/<%=(String)vStudBasicInfo.elementAt(8)%>
		<%}%>
		</strong></font></td>
      <td>
	  <input type="hidden" name="cy_from" value="<%=(String)vStudBasicInfo.elementAt(3)%>"> 
        <input type="hidden" name="cy_to" value="<%=(String)vStudBasicInfo.elementAt(4)%>">
        <font size="3"><strong><%=(String)vStudBasicInfo.elementAt(3)%> - <%=(String)vStudBasicInfo.elementAt(4)%></strong></font> 
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25"> Year level entry</td>
      <td height="25">
<%
	//dbop, request, stud_index, course_index, major_index, cy_from, cy_to, prep_prop_stat, sy_from, semester, year_level, degree_type(year level and deg type can be null, prep_prop_stat can be 0)
	if(vTemp.size() == 0) //it is already set if na_old_stud has data.. 
		vTemp = offlineAdm.determineYrLevelOfStud(dbOP,request, (String)request.getSession(false).getAttribute("userIndex"), (String)vStudBasicInfo.elementAt(5), 
				(String)vStudBasicInfo.elementAt(6), (String)vStudBasicInfo.elementAt(3), (String)vStudBasicInfo.elementAt(4), "0",strSYFromAdvise,strTermAdvise, 
				(String)vStudBasicInfo.elementAt(14), strDegreeType);
	if(vTemp != null && vTemp.size() > 0)
		strTemp = (String)vTemp.elementAt(0);
	else
		strTemp = "1";//System.out.println(vTemp);
	if(strTemp == null)
		strTemp = "0";	
	
%>
	  <strong><font size="3"><%=astrConvertYr[Integer.parseInt(strTemp)]%></font></strong>
	  <input type="hidden" name="year_level" value="<%=strTemp%>">
        <em></em></td>
    </tr>
    <%//System.out.println(offlineAdm.determineYrLevelOfStud(dbOP,request.getParameter("stud_id")));%>
    <%}
if(strDegreeType != null && strDegreeType.compareTo("3") ==0 && WI.fillTextValue("stud_status").compareTo("New") !=0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Select Prep/Proper</td>
      <td height="25"><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.length()  == 0 && strPrepPropStat != null)
	strTemp = strPrepPropStat;
	
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select></td>
    </tr>
    <%}%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25"> School Year</td>
      <td height="25">
	  <font size="3"><strong><%=strSYFromAdvise%> - <%=strSYToAdvise%> 
	  	(<%=astrConvertSem[Integer.parseInt(strTermAdvise)]%>)</strong></font>
	  <input type="hidden" name="sy_from" value="<%=strSYFromAdvise%>">
	  <input type="hidden" name="sy_to" value="<%=strSYToAdvise%>">
	  <input type="hidden" name="semester" value="<%=strTermAdvise%>">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="1%" height="24">&nbsp;</td>
      <td width="35%" height="24" valign="bottom">Student last name </td>
      <td width="34%" valign="bottom">Student first name </td>
      <td width="30%" height="24" valign="bottom">Student middle name </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> <b><font size="3"><%=(String)vStudBasicInfo.elementAt(2)%></font></b> 
      </td>
      <td> <b><font size="3"><%=(String)vStudBasicInfo.elementAt(0)%></font></b> 
      </td>
      <td height="25"> <b><font size="3"><%=WI.getStrValue(vStudBasicInfo.elementAt(1))%></font></b> 
      </td>
    </tr>
  </table>
<%}//show only if vBasicInfo is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="36%" height="25" style="font-weight:bold; color:#0000FF">
	  
<%if(strSchCode.startsWith("FATIMA") && strUserIndex != null){
//get here if already set plan.
	String strStudFatimaPlanRef = null;
	enrollment.FAStudMinReqDP faMinDP = new enrollment.FAStudMinReqDP(dbOP);
	Vector vStudInstallmentPlanFatima = faMinDP.getPlanInfoOfAStudent(dbOP, strSYFromAdvise, strTermAdvise, strUserIndex, false);
	if(vStudInstallmentPlanFatima != null && vStudInstallmentPlanFatima.size() > 0)
		strStudFatimaPlanRef = (String)vStudInstallmentPlanFatima.elementAt(0);
%>
		Installation Plan: 
		<select name="plan_ref" style="font-size:11px" onChange="updatePlanFatima()">
          <option value=""></option>
          <%=dbOP.loadCombo("plan_ref","PLAN_NAME,INSTALLMENT_FEE"," from FA_STUD_PLAN_FATIMA where is_valid = 1 order by PLAN_NAME", strStudFatimaPlanRef, false)%>
        </select><label id="coa_info_splan" style="font-size:9px; font-weight:bold"></label>
<%}%>
	  
	  
	  
	  </td>
      <td width="64%" height="25"><a href="javascript:AddRecord();"><img src="../../images/form_proceed.gif" border="0"></a> 
        <font size="1" >Click to go to advising page</font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord">
<input type="hidden" name="degreeType" value="<%=WI.getStrValue(strDegreeType)%>">
<input type="hidden" name="online_advising" value="1">
<input type="hidden" name="showList" value="1">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
