<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	int j=0; //this is the max display variable.
	String[] astrSchYrInfo = {WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester")};
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	String strDegreeType = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.messageBox {
		height: 250px; width:auto; overflow: auto; border: inset black 1px;
}

.nav {
     /**color: #000000;**/
     /**background-color: #FFFFFF;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     /**background-color: #FAFCDD;**/
     background-color:#BCDEDB;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function ComputeAddCount(strCheckboxIndex) {
	var iAddCount = document.chngsubject.addSubCount.value;
	if(eval('document.chngsubject.checkbox'+strCheckboxIndex+'.checked'))
		++iAddCount;
	else
		--iAddCount;
	document.chngsubject.addSubCount.value = iAddCount;
	//alert(iAddCount);
}
function ReloadPage()
{
	document.chngsubject.submit();
}
function AddSubject()
{
	//check how many selected to change schedule.. 
	var iMaxDisp = document.chngsubject.maxDisplay.value;
	var iSelected = 0;
	var obj;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.chngsubject.checkbox'+i);
		if(!obj)
			continue;
		if(obj.checked)
			++iSelected;
	}
	document.chngsubject.addSubCount.value = iSelected;
	
	document.chngsubject.addSubject.value="1";
	document.chngsubject.hide_save.src = "../../../images/blank.gif";
	ReloadPage();
}
function LoadPopup(secName,sectionIndex, strCurIndex, strSubIndex, strIndexOf) //curriculum index is different for all courses.
{
//this will check conflict with the schedule of other subjects taken. pass user id, all the sub_section_index,
//if check box is not checked - it is considered as not selected.
	var subSecList = "";
	//I have to get the sub section list. I have to use the new section index if it is selected.
	var iMaxDisplay = document.chngsubject.maxDisplay.value;
	for(var i = 0; i < iMaxDisplay; ++i) {
		if(eval('document.chngsubject.cur_index'+i+'.value') == strCurIndex)
			continue;
		if(eval('document.chngsubject.checkbox'+i+'.checked')) {
			if(subSecList.length == 0)
				subSecList = eval('document.chngsubject.sec_index'+i+'2.value');
			else
				subSecList +=","+ eval('document.chngsubject.sec_index'+i+'2.value');
		}
		else {
			if(subSecList.length == 0)
				subSecList = eval('document.chngsubject.sec_index'+i+'.value');
			else
				subSecList +=","+ eval('document.chngsubject.sec_index'+i+'.value');
		}
	}
//alert(subSecList);

	var loadPg = "../advising/subject_schedule.jsp?form_name=chngsubject&cur_index="+strCurIndex+
		"&sub_index="+strSubIndex+"&sec_name="+secName+"&sec_index_name="+sectionIndex+
		"&syf="+document.chngsubject.sy_from.value+"&syt="+document.chngsubject.sy_to.value+"&semester="+document.chngsubject.semester[document.chngsubject.semester.selectedIndex].value+
		"&sec_index_list="+subSecList+"&course_index="+document.chngsubject.ci.value+
		"&major_index="+document.chngsubject.mi.value+"&degree_type="+document.chngsubject.degree_type.value+
		"&year_level=" + document.chngsubject.year_level.value+"&line_number="+strIndexOf+"&add_oc=3";

	//var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,screenX=200,screenY=300,scrollbars=yes,,toolbar=yes,location=yes,directories=yes,status=no,menubar=yes');
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.chngsubject.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=chngsubject.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.chngsubject.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
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
	document.chngsubject.stud_id.value = strID;
	document.chngsubject.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.chngsubject.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function PrintFinalClassSchedule() {
	var strStudID   = document.chngsubject.stud_id.value;
	var strSYFrom   = document.chngsubject.sy_from.value;
	var strSYTo     = document.chngsubject.sy_to.value;
	var strSemester = document.chngsubject.semester.value;
	
	if(strStudID == '') {
		alert("Please enter student ID.");
		return;
	}
	if(strSYFrom == '' || strSYFrom == '') {
		alert("Please enter SY From/To.");
		return;
	}
	if(strSemester == '') {
		alert("Please enter Semester");
		return;
	}

	var pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print_uc_batch.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+
		strSemester+"&stud_id="+strStudID;
		
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SCHEDULE","change_schedule.jsp");
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
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"change_schedule.jsp");
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

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();
Vector vAdviseList = new Vector();

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();

String strCurHistIndex = null;

if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
                                    astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	else {
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
	}
	if(!bolFatalErr)
	{
		strCurHistIndex = "select cur_hist_index from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+" and is_valid = 1 and sy_from = "+
			astrSchYrInfo[0]+" and semester = "+astrSchYrInfo[2];
		strCurHistIndex = dbOP.getResultOfAQuery(strCurHistIndex, 0);
		
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],(String)vStudInfo.elementAt(7),
			(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	//Withdraw subject if it is trigged.
	if(!bolFatalErr && WI.fillTextValue("addSubject").compareTo("1") ==0)
	{
		if(enrlAddDropSub.changeSchedule(dbOP,request))
			strErrMsg = "Subject/s schedule changed successfully.";
		else
		{
			strErrMsg = enrlAddDropSub.getErrMsg();
			bolFatalErr = true;
		}
	}
	if(!bolFatalErr) // show enrolled list
	{
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vEnrolledList ==null)
		{
			bolFatalErr = true;
			strErrMsg = enrlAddDropSub.getErrMsg();
		}
	}
}
if(vStudInfo != null && vStudInfo.size() > 0)
{
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(5), "degree_type",
                                       " and is_valid=1 and is_del=0");

	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
/*	else
	{
		if(strDegreeType.compareTo("1") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_masteral.jsp?stud_id="+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")));

			return;
		}
		else if(strDegreeType.compareTo("2") == 0)
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./add_subject_medicine.jsp?stud_id="+strStudID+"&sy_from="+WI.fillTextValue("sy_from")+
			"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester")));

			return;
		}
	}
*/}
%>

<form action="./change_schedule.jsp" method="post" name="chngsubject">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: CHANGE 
          OF SUBJECTS - CHANGE SCHEDULE ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="24">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" height="25">Enter Student ID </td>
      <td width="20%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="9%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="52%" height="25"><input type="image" src="../../../images/form_proceed.gif" border="0">      </td>
    </tr>
    <tr>
      <td></td>
      <td colspan="4"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term </td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("chngsubject","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;<select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
        </select> </td>
      <td height="25">
	  	  	  <%if (strSchCode.startsWith("UC")) {%>
	  	<input type="button" name="122" value="Print Final Class Schedule" style="font-size:14px; height:28px;border: 1px solid #FF0000;" onClick="PrintFinalClassSchedule();">
	  <%}%>
</td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){

boolean bolAllowChange = false;//do not allow if having grade or due to other conditions.. check below.
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Student name </td>
      <td width="40%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong>
	        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  </td>
      <td width="13%"><!--Date approved--></td>
      <td width="26%"><!--<input name="apv_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("apv_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('chngsubject.apv_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		--> </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25" colspan="3"><strong><%=(String)vStudInfo.elementAt(2)%>
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        </strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td height="25">Year level</td>
      <td height="25" colspan="3"><strong><%=WI.getStrValue((String)vStudInfo.elementAt(4))%></strong>
	  <input type="hidden" name="year_level" value="<%=WI.getStrValue((String)vStudInfo.elementAt(4))%>"></td>
    </tr>
    <tr >
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">SUBJECTS
          ENROLLED</font></div></td>
    </tr>
<%
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="4" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
<%}%>

    <tr >
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
      <td  colspan="2" height="25">Total student load :
<input type="text" name="sub_load" readonly="yes" size="5" style="border: 0; font-weight:bold;font-family:Verdana, Arial, Helvetica, sans-serif;" value="<%=(String)vEnrolledList.elementAt(0)%>"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#ffffff">
      <td width="11%" height="27" align="center"><font size="1"><strong>SUBJECT CODE</strong></font></td>
      <td width="19%" align="center"><font size="1"><strong>SUBJECT TITLE </strong></font></td>
      <%
//show only for UG type.
if(strDegreeType.compareTo("1") != 0 && strDegreeType.compareTo("2") != 0){%>
      <td width="7%" align="center"><font size="1"><strong>LEC/LAB UNITS</strong></font></td>
<%}%>
      <td width="5%" align="center"><font size="1"><strong> UNITS TAKEN</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>ROOM #</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>SCHEDULE</strong></font></td>
      <td width="20%" align="center"><font size="1"><strong>
	  <% if(!strSchCode.startsWith("CPU")){%>SECTION<%}else{%>STUB CODE<%}%></strong></font></td>
      <td width="20%" align="center"><strong><font size="1">NEW SCHEDULE</font></strong></td>
      <td width="6%" align="center"><strong><font size="1">CHANGE SCHED</font></strong></td>
      <td width="5%" align="center"><font size="1">&nbsp;<strong><font size="1">ASSIGN
        SECTION</font></strong></font></td>
    </tr>
    <%
boolean bolGradeEncoded = false;
String strSQLQuery = "select gs_index from g_sheet_final where is_valid = 1 and cur_hist_index = "+strCurHistIndex+" and user_index_ = "+(String)vStudInfo.elementAt(0)+" and s_index = ?";
java.sql.PreparedStatement pstmtGetGrade = dbOP.getPreparedStatement(strSQLQuery);
java.sql.ResultSet rs = null;

 for(int i=1;i<vEnrolledList.size();++i,++j){
 	
	//check if student is having final grade. 
	pstmtGetGrade.setInt(1, Integer.parseInt((String)vEnrolledList.elementAt(i+2)));
	rs = pstmtGetGrade.executeQuery();
	if(rs.next())
		bolGradeEncoded = true;
	else	
		bolGradeEncoded = false;
	rs.close();
	
/** -- Changed to checking grade in each subject for this student... 
	if(dbOP.mapOneToOther("g_sheet_final","sub_sec_index",(String)vEnrolledList.elementAt(i+5),"GS_INDEX",
	" and is_valid = 1 and is_del = 0") == null)
		bolGradeEncoded = false;
	else	
		bolGradeEncoded = true;
**/

 //System.out.println(bolGradeEncoded);
 
if(vEnrolledList.elementAt(i) != null && ((String)vEnrolledList.elementAt(i)).compareTo("0") != 0 && !bolGradeEncoded)
	bolAllowChange = true;
else	
	bolAllowChange = false;
 
 %>
    <tr bgcolor="#ffffff" class="nav" id="msg<%=j%>" onMouseOver="navRollOver('msg<%=j%>', 'on')" onMouseOut="navRollOver('msg<%=j%>', 'off')"
	<%if(bolAllowChange){%>onDblClick='LoadPopup("sec<%=j%>2","sec_index<%=j%>2","<%=(String)vEnrolledList.elementAt(i+1)%>", "<%=(String)vEnrolledList.elementAt(i+2)%>","<%=j%>");' <%}%>>
      <td height="25"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td><%=(String)vEnrolledList.elementAt(i+4)%></td>
<%
//show only for UG type.
if(strDegreeType.compareTo("1") != 0 && strDegreeType.compareTo("2") != 0){%>
      <td><%=(String)vEnrolledList.elementAt(i+11)%>/<%=(String)vEnrolledList.elementAt(i+12)%></td>
<%}%>      <td><%=(String)vEnrolledList.elementAt(i+13)%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+8),"N/A")%></td>
      <td><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%></td>
      <td>
        <!-- all the hidden fileds of enrolled subject information are here. -->
		<input type="hidden" name="enroll_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i)%>">
        <input type="hidden" name="cur_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+1)%>">
        <input type="hidden" name="sec_index<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+5)%>">	
        <!-- all the hidden fileds of change sechedule information -->
		<% if (!strSchCode.startsWith("CPU")) {%> 
			<input type="text" name="sec<%=j%>2" size="12" class="textbox_noborder" 
								value="<%=WI.getStrValue(vEnrolledList.elementAt(i+7),"")%>">
	        <input type="hidden" name="sec_index<%=j%>2"> 
		<%}else{
		
			strTemp = WI.fillTextValue("sec_index"+ j +"2");
			if (strTemp.length() == 0) 
				strTemp = (String)vEnrolledList.elementAt(i+5);
		%> 
			<input type="hidden" name="sec<%=j%>2" class="textbox_noborder" 
								value="<%=WI.getStrValue(vEnrolledList.elementAt(i+7),"")%>">
		
			<input type="text" name="sec_index<%=j%>2" size="12" class="textbox_noborder" 
								value="<%=strTemp%>">
		<%}%>	   </td>
      <td><label id="_<%=j%>" style="font-size:11px;"></label></td>
      <td align="center">
<%
if(vEnrolledList.elementAt(i) != null && ((String)vEnrolledList.elementAt(i)).compareTo("0") != 0 &&
	!bolGradeEncoded){%>
	  <input type="checkbox" name="checkbox<%=j%>" value="1" onClick="ComputeAddCount(<%=j%>);">
<%}else if(bolGradeEncoded){%><font size="1" color="#FF0000">Having grade</font>
	<input type="checkbox" name="checkbox<%=j%>" value="" disabled><%}else {%>
	<input type="checkbox" name="checkbox<%=j%>" value="" disabled><%}%>	  </td>
      <td bgcolor="#ffffff">
<%
if(vEnrolledList.elementAt(i) != null && ((String)vEnrolledList.elementAt(i)).compareTo("0") != 0 && !bolGradeEncoded){%>
	  <a href='javascript:LoadPopup("sec<%=j%>2","sec_index<%=j%>2","<%=(String)vEnrolledList.elementAt(i+1)%>", "<%=(String)vEnrolledList.elementAt(i+2)%>","<%=j%>");'><img src="../../../images/schedule.gif" border="0" width="40" height="20"></a>
<%}%>      </td>
    </tr>
    <%
i = i+13;
}%>
  </table>
<input type="hidden" name="ci" value="<%=(String)vStudInfo.elementAt(5)%>">
<input type="hidden" name="mi" value="<%=WI.getStrValue(vStudInfo.elementAt(6))%>">
<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr><tr>
      <td height="25" align="center"><a href="javascript:AddSubject();">
	  <img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <font size="1">Click to save added subjects</font></td>
    </tr>
</table>

<%
}//only if student information is not null
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="addSubject" value="0">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="maxDisplay" value="<%=j%>">
<input type="hidden" name="addSubCount">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
