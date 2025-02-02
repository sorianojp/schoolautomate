<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusOnGrade()
{
	if(document.form_.stud_id)
		document.form_.stud_id.focus();
}
function ViewResidency()
{
	var strStudID = document.form_.stud_id.value;
	if(strStudID.length == 0)
	{
		alert("Please enter student ID.");
		return;
	}
	location = "../residency/residency_status.jsp?stud_id="+escape(strStudID);
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.submit();
}
function CheckStudent() {
	if(document.form_.course_index2) {
		document.form_.course_index2.selectedIndex = 0;
	}
	document.form_.checkStudent.value = "1";
}
function PageAction(strAction,strInfoIndex)
{
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

</script>
<body bgcolor="#D2AE72" onLoad="focusOnGrade();">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.OfflineAdmission,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vTemp = null;
	int i=0; int j=0;
	String strCYFrom = null;
	String strCYTo = null;
	String strCourseType = null;//0->Under graduate, 1->Doctoral, 2-> doctor of medicine, 3-> with proper, 4-> non semestral.
	Vector vStudInfo = null;
	String strSubName = null;
	String strSubCode = null;
	float fCredit = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-OLD STUDENT DATA MANAGEMENT","sub_accredition_foreign_stud.jsp");
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
														"Registrar Management","SUBJECT UNITS CREDITATION",request.getRemoteAddr(),
														"sub_accredition_foreign_stud.jsp");
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
enrollment.AccreditedExtn accrExtn = new enrollment.AccreditedExtn();
GradeSystem GS = new GradeSystem();
OfflineAdmission offlineAdmission = new OfflineAdmission();
vStudInfo = offlineAdmission.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));

if(vStudInfo != null && vStudInfo.size() > 0)
{
	strCYFrom = (String)vStudInfo.elementAt(3);
	strCYTo   = (String)vStudInfo.elementAt(4);

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(accrExtn.operateOnForeignStudSubCredit(dbOP, request,Integer.parseInt(strTemp)) == null)
			strErrMsg = accrExtn.getErrMsg();
		else
			strErrMsg = "Operation Successful.";
	}
	strCourseType = " and is_del=0 and is_valid=1";
	strCourseType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vStudInfo.elementAt(5),"DEGREE_TYPE",strCourseType);

}
else
	strErrMsg = offlineAdmission.getErrMsg();


if(strErrMsg == null) strErrMsg = "";


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//collect here the list of courses already completed by student.. 
Vector vCourseInfo = new Vector();
Vector vMajorInfo  = new Vector();
if(vStudInfo != null && vStudInfo.size() > 0) {
	String strSQLQuery = "select distinct stud_curriculum_hist.course_index, course_name from stud_curriculum_hist "+
	" join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
	" where stud_curriculum_hist.is_valid = 1 and user_index = "+
	(String)vStudInfo.elementAt(12);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vCourseInfo.addElement(rs.getString(1));
		vCourseInfo.addElement(rs.getString(2));//course name.. 
	}
	rs.close();

	if(WI.fillTextValue("course_index2").length() > 0) {
		strSQLQuery = "select distinct stud_curriculum_hist.major_index, major_name from stud_curriculum_hist "+
		" join major on (major.major_index = stud_curriculum_hist.major_index) "+
		" where stud_curriculum_hist.is_valid = 1 and user_index = "+
		(String)vStudInfo.elementAt(12)+" and stud_curriculum_hist.course_index ="+WI.fillTextValue("course_index2");
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vMajorInfo.addElement(rs.getString(1));
			vMajorInfo.addElement(rs.getString(2));//course name.. 
		}
		rs.close();
	}
	
}	
%>


<form action="./sub_accredition_foreign_stud.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"> <strong>:::: 
          SUBJECT CREDITATION ::::</strong></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top">
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">Student ID</td>
      <td width="16%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="10%">
        <input type="image" onClick="CheckStudent();" src="../../../images/form_proceed.gif">      </td>
      <td width="55%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="5">
<%
if(WI.fillTextValue("local_stud").length() > 0) {%>
<input type="hidden" name="CE_SCH_INDEX" value="0">
<%}else{
strTemp = WI.fillTextValue("CE_SCH_INDEX");
if(strTemp.length() > 0) 
	strTemp = " checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="CE_SCH_INDEX" value="0" <%=strTemp%>> <font color="#0000FF"><strong>Click here to hide this subject in list of accredited subject in TOR</strong></font>
<%}%>		</td>
    </tr>
<%}

if((true || strSchCode.startsWith("VMUF")) && vCourseInfo != null && vCourseInfo.size() > 0){//show for all.. let them select a course that is listed in stud_curriculum_hist.%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="5" style="font-weight:bold; font-size:9px;">
	  	Subject Taken in Course : 
		<select name="course_index2" onChange="ReloadPage();" style="width:500px;">
			<option value="">Subject List from Latest Course of student</option>
			<%for(i = 0; i < vCourseInfo.size(); i += 2) {
				if(WI.fillTextValue("course_index2").equals(vCourseInfo.elementAt(i)))
					strTemp = "selected";
				else	
					strTemp = "";
			 %>
			 	<option value="<%=vCourseInfo.elementAt(i)%>" <%=strTemp%>><%=vCourseInfo.elementAt(i + 1)%></option>
			<%}%>
		</select>
	  </td>
    </tr>
<%if(vMajorInfo != null && vMajorInfo.size() > 0) {%>
    <tr >
      <td height="25">&nbsp;</td>
      <td colspan="5" style="font-weight:bold; font-size:9px;">
	  	Major : 
		<select name="major_index2">
			<%for(i = 0; i < vMajorInfo.size(); i += 2) {
				if(WI.fillTextValue("major_index2").equals(vMajorInfo.elementAt(i)))
					strTemp = "selected";
				else	
					strTemp = "";
			 %>
			 	<option value="<%=vMajorInfo.elementAt(i)%>" <%=strTemp%>><%=vMajorInfo.elementAt(i + 1)%></option>
			<%}%>
		</select>
	  </td>
    </tr>
<%}//show only if there is major%>

<%}%>
    <tr >
      <td  colspan="6" height="25"><hr size="1"></td>
    </tr>
  </table>
<%if(vStudInfo != null && vStudInfo.size() > 0)
{%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student Name : <strong>
	  <%= WI.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),1)%></strong></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td>Course/Major (curriculum year) <font size="1"><strong>NOTE:</strong>
        To edit course or curriculm please edit student's information.</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><strong><%=(String)vStudInfo.elementAt(7)%>
        <%
	  if((String)vStudInfo.elementAt(8) != null){%>
        /<%=(String)vStudInfo.elementAt(8)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(3)+" - "+ (String)vStudInfo.elementAt(4)%>)</strong></td>
</tr>
<tr>
	<td colspan="2"><hr size="1"></td>
</tr>
  </table>
    <input type="hidden" name="course_index" value="<%=(String)vStudInfo.elementAt(5)%>">
    <input type="hidden" name="major_index" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">
    <input type="hidden" name="cy_from" value="<%=(String)vStudInfo.elementAt(3)%>">
    <input type="hidden" name="cy_to" value="<%=(String)vStudInfo.elementAt(4)%>">
  <%
if(strCYTo.length() > 0)
{
if(strCourseType.compareTo("4") != 0){%>
  <%}
strErrMsg = "";
if(WI.fillTextValue("course_index").length() > 0)
{
	vTemp = GS.getSubjectList(dbOP, request, strCYFrom, strCYTo, true);
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="2"><font size="1"><strong><%=strErrMsg%></strong> &nbsp;&nbsp;
        <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a>click
        to view Residency status of student</font></td>
    </tr>
  </table>
<%
if(vTemp != null)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="7" ><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="29%"  height="25" ><div align="left"><font size="1"> <strong></strong><strong><br>
          SUBJECT CODE TO CREDIT</strong></font> </div></td>
      <td width="41%" > <div align="left"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="9%" ><strong><font size="1">UNIT</font></strong></td>
      <td width="9%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="10%" ><font size="1"><strong>REMARKS</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="document.form_.sub_index_.value='';ReloadPage();">
          <%
	//System.out.println(vTemp);
	String strSubIndex = null;
	strTemp = WI.fillTextValue("subject");//cur_index.
	if(strTemp.length() == 0) 
		strTemp = (String)vTemp.elementAt(0);
	for(i = 0; i< vTemp.size(); ++i) {	
		if(strTemp.compareTo( (String)vTemp.elementAt(i)) ==0) {
			strSubName = (String)vTemp.elementAt(i+2);
			strSubCode = (String)vTemp.elementAt(i+1);
			strSubIndex = (String)vTemp.elementAt(i+5);
			fCredit  = Float.parseFloat((String)vTemp.elementAt(i+3))+Float.parseFloat((String)vTemp.elementAt(i+4));
			%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i+1)%></option>
          <%}
i = i+5;
}
if(strSubName == null && fCredit ==0)//first time - so select the top result.
{
	strSubName = (String)vTemp.elementAt(2);
	fCredit  = Float.parseFloat((String)vTemp.elementAt(3))+Float.parseFloat((String)vTemp.elementAt(4));
}%>
        </select>
 <input type="hidden" name="sub_index_" value="<%=WI.getStrValue(strSubIndex)%>">
        <%if(WI.getStrValue(strSubCode).indexOf("NSTP") != -1){
strTemp = WI.fillTextValue("nstp_val");%>
        <select name="nstp_val" style="font-weight:bold;">
          <option value="CWTS">CWTS</option>
          <%
if(strTemp.compareTo("LTS") ==0){%>
          <option value="LTS" selected>LTS</option>
          <%}else{%>
          <option value="LTS">LTS</option>
          <%}if(strTemp.compareTo("ROTC") ==0){%>
          <option value="ROTC" selected>ROTC</option>
          <%}else{%>
          <option value="ROTC">ROTC</option>
          <%}%>
        </select>
        <%}//only if subject is NSTP %>      </td>
      <td valign="top"><%=strSubName%></td>
      <td valign="top"><%=fCredit%></td>
      <td valign="top"><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=fCredit%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td valign="top"><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark",
		  " from REMARK_STATUS where is_del=0 and remark like 'pass%'",request.getParameter("remark_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" style="font-size:11px; font-weight:bold; color:#0000FF"> 
	  <!--
	  <input type="checkbox" name="credited_same_sch" value="checked" <%=WI.fillTextValue("credited_same_sch")%>> 
	  Equivalent Subject (Subject taken in Current School)
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  -->
	  Equivalent Grade of current School (if not taken in same school):
	  <input name="grade_" type="text" size="5" maxlength="6" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("grade_")%>"
	  onKeyUp="AllowOnlyIntegerExtn('form_','grade_','.')">
	  
	  	  
	  
	  <br><font style="font-size:9px; color:#FF0000">
	  Note: <!--If Equivalent Subject, the subject must be taken in your own school. Leave the check box unchecked if Subject is taken from other school. 
	  <br>-->
	  Equivalent Grade is the Grade converted to your own grading system. This filed is optional to fill up and only if subject is taken in another school.
	  <!--<br>Both Fields are optional.-->
	   
	  </font>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="5" style="font-size:11px; font-weight:bold; color:#0000FF">List of subject already taken in Current School: 
	  <select name="sub_cur_school" style="font-size:11px; width:450px;">
          <option value=""></option>
          <%=dbOP.loadCombo("gs_index","sub_code, sub_name"," from g_sheet_final join subject on (sub_index = s_index) where g_sheet_final.is_valid = 1 and credit_earned > 0 and user_index_ = "+(String)vStudInfo.elementAt(12)+ " and G_SHEET_FINAL.COPIED_FR_TF_GS = 0 order by sub_code", WI.fillTextValue("sub_cur_school"), false)%>
      </select>
	  
	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" >&nbsp;</td>
      <td colspan="4" > <div align="left"> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0"></a><font size="1">click
          to add</font> </div></td>
    </tr>
  </table>
<%
//get here the list of grade created already for this year/sem course
	//true = get GS INDEX
	vTemp = accrExtn.operateOnForeignStudSubCredit(dbOP, request,4);
	if(vTemp != null && vTemp.size() > 0)
	{%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
    <tr bgcolor="#B9B292">
      <td height="25" colspan="10" bgcolor="#B9B292"><div align="center">LIST OF CREDITED SUBJECTS</div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold;" align="center">
      <td width="20%" height="25" class="thinborder">Subject Code</td>
      <td width="45%" class="thinborder">Subject Title</td>
<%
if(WI.fillTextValue("local_stud").length() ==0){%>
      <td width="9%" class="thinborder"><div align="center">Is Listed TOR?</div></td>
<%}%>
      <td width="7%" class="thinborder">Credit Earned</td>
      <td width="7%" class="thinborder">Grade Remark</td>
      <td width="7%" class="thinborder">Grade Equivalent</td>
      <td width="9%" class="thinborder">Is Taken Current School?</td>
      <td width="5%" class="thinborder">Delete</td>
    </tr>
    <%//System.out.println(vTemp);
	for(i=0; i< vTemp.size(); i += 8)
	{//System.out.println((String)vTemp.elementAt(3) + " : "+(String)vTemp.elementAt(4));%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vTemp.elementAt(i+1)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+2)%></td>
<%
if(WI.fillTextValue("local_stud").length() ==0){%>
      <td align="center" class="thinborder"><%if(vTemp.elementAt(i + 5) != null && ((String)vTemp.elementAt(i + 5)).compareTo("0") ==0){%>
	  <img src="../../../images/tick.gif">
	  <%}%>&nbsp;</td>
<%}
if(((String)vTemp.elementAt(i+7)).equals("0"))
	strTemp = "&nbsp;";
else {	
	strTemp = "Y";
	if(!((String)vTemp.elementAt(i+7)).equals("1"))
	strTemp = "Y<br>("+vTemp.elementAt(i+7)+")";
}
%>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i+4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i+6), "&nbsp;")%></td>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder"> <a href='javascript:PageAction("0","<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
      <%}%>
    </tr>
  </table>
 <%
 	}//if(strCYFrom.length()>0)
  }//if subject list is not null;
 }//if vTemp !=null - student is having grade created already.
}//biggest loop == only if the Proceed for Student id is cliecked - checkStudent.compareTo("1") ==0
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action">
<input type="hidden" name="checkStudent" value="<%=WI.fillTextValue("checkStudent")%>">
<input type="hidden" name="remarkName">
<input type="hidden" name="course_type" value="<%=strCourseType%>">

<input type="hidden" name="local_stud" value="<%=WI.fillTextValue("local_stud")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
