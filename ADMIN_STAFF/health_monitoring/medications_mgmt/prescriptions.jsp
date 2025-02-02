<%@ page language="java" import="utility.*, health.ClinicVisitLog, health.MedicationMgmt,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel()
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EmpSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.stud_id.value;

		if(strCompleteName.length <=2)
			return;

		var objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vCaseData = null;
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strMedChange = "";
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strUserIndex = "";
	String strMedfor = "";
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Medications Management","prescriptions.jsp");
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
														"Health Monitoring","Medications Management",request.getRemoteAddr(),
														"prescriptions.jsp");
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
Vector vBasicInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//called for adde,edit or delete.

}
//get all levels created.
if(WI.fillTextValue("stud_id").length() > 0) {
	if(bolIsSchool) {
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
		}
		else {//check if student is currently enrolled
			Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
			(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
			if(vTempBasicInfo != null)
				bolIsStudEnrolled = true;
		}
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	else{//check faculty only if not school...
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
			if(vBasicInfo == null)
				strErrMsg = "Employee Information not found.";;
	}
}
	MedicationMgmt medMgmt = new MedicationMgmt();
	strTemp = WI.fillTextValue("page_action");
	strMedChange = WI.fillTextValue("change_med");

	if(strTemp.length() > 0) {
		if(medMgmt.operateOnPrescriptionEntry(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				strPrepareToEdit = "";
				}
		else
				strErrMsg = medMgmt.getErrMsg();
	}

	if(strPrepareToEdit.compareTo("1") == 0) {
		 if (strMedChange.length()==0)
	      strMedChange = "1";
    	vEditInfo = medMgmt.operateOnPrescriptionEntry(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = medMgmt.getErrMsg();
	}

	if (vBasicInfo!=null && request.getParameter("visit_index")!= null){
	if (request.getParameter("visit_index").length()>0)
		{
			ClinicVisitLog CVlog = new ClinicVisitLog();
			request.setAttribute("info_index",request.getParameter("visit_index"));
			vCaseData = CVlog.operateOnClinicVisit(dbOP, request, 3);
		}
	}
	vRetResult = medMgmt.operateOnPrescriptionEntry(dbOP, request, 4);
	iSearchResult = medMgmt.getSearchCount();
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = medMgmt.getErrMsg();
%>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<form action="./prescriptions.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td height="28" colspan="6" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
      MEDICATIONS MANAGEMENT - PRESCRIPTIONS ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="18" colspan="6" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td width="2%"  height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="15%" height="28" bgcolor="#FFFFFF">Enter ID No. :</td>
      <td width="16%" height="28" bgcolor="#FFFFFF"> <%strTemp = WI.fillTextValue("stud_id");%>
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName('1');">      
	  </td>
      <td width="25%" height="28" bgcolor="#FFFFFF">
	  <%if(bolIsSchool){%>
		<a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for student</font>
	  <%}%>		</td>
      <td width="39%" rowspan="2" valign="top" bgcolor="#FFFFFF"> <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
          <tr>
            <td><font size="1">
              Record Last Updated :<br>
              <br>
              </font><font size="1">Updated by : <br>
              </font></td>
          </tr>
        </table></td>
      <td width="3%" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="28" bgcolor="#FFFFFF"><a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for employee</font></td>
      <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="3" bgcolor="#FFFFFF"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="18" colspan="6" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
  </table>
  <%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <%strUserIndex = (String)vBasicInfo.elementAt(12);%>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled <%}else{%>
        Not Currently Enrolled <%}%></td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
 <%strUserIndex = (String)vBasicInfo.elementAt(0);%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/
	  <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
   <tr>
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <%if (vBasicInfo != null && vBasicInfo.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td >CASE #</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
      <%
      if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);
	else
			strTemp = WI.fillTextValue("visit_index");%>
      <select name="visit_index" onChange="ReloadPage();">
          <option value="">Select case</option>
<%=dbOP.loadCombo("VISIT_LOG_INDEX","CASE_NO"," FROM HM_CLINIC_VISIT WHERE  IS_VALID = 1 AND IS_DEL = 0 AND USER_INDEX = "+strUserIndex+
" AND PRESCRIPTION_GIVEN = 1 AND IS_CLOSED = 0", strTemp, false)%>
        </select></td></td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Attended</td>
      <td height="25"><font size="1"><%if (vCaseData !=null){%><%=(String)vCaseData.elementAt(1)%><%}else{%>&nbsp;<%}%></font></td>
      <td height="25">Doctor/Nurse ID </td>
      <td width="38%" height="25"><font size="1"><%if (vCaseData !=null){
		if(vCaseData.elementAt(3) == null && vCaseData.elementAt(20) == null)
			strTemp = "&nbsp;";
		else if(vCaseData.elementAt(3) != null && vCaseData.elementAt(20) == null)
			strTemp = "("+vCaseData.elementAt(6)+") "+WI.formatName((String)vCaseData.elementAt(3), (String)vCaseData.elementAt(4), (String)vCaseData.elementAt(5),7);
		else if(vCaseData.elementAt(3) == null && vCaseData.elementAt(20) != null)
			strTemp = "("+vCaseData.elementAt(19)+") "+WI.formatName((String)vCaseData.elementAt(21), (String)vCaseData.elementAt(22), (String)vCaseData.elementAt(23),7);
		else if(vCaseData.elementAt(3) != null && vCaseData.elementAt(20) != null)
			strTemp = "("+vCaseData.elementAt(6)+") "+WI.formatName((String)vCaseData.elementAt(3), (String)vCaseData.elementAt(4), (String)vCaseData.elementAt(5),7) +" <br>"+
			"("+vCaseData.elementAt(19)+") "+WI.formatName((String)vCaseData.elementAt(21), (String)vCaseData.elementAt(22), (String)vCaseData.elementAt(23),7);
	  
	  %><%=strTemp%><%}else{%>&nbsp;<%}%></font></td>
    </tr>
    <tr>
      <td  width="3%"height="25">&nbsp;</td>
      <td width="19%" height="25">Prescription for </td>
      <td width="24%" height="25"><%

      if (vEditInfo!= null && vEditInfo.size()>0 && strMedChange.length()==0)
            strTemp = (String)vEditInfo.elementAt(16);
      	else
		    strTemp = WI.fillTextValue("med_for_index");%>
      <select name="med_for_index" onChange="ReloadPage();">
          <option value="">Select Usage</option>
			<%=dbOP.loadCombo("MEDICATION_FOR_INDEX","MEDICATION_FOR"," FROM HM_PRELOAD_MED_FOR", strTemp, false)%>
        </select></td>
      <td width="16%" colspan="2">Medication Name - Form - Strength</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Dosage</td>
      <td height="25">

      <%if(vEditInfo != null && vEditInfo.size() > 0){
			if (vEditInfo.elementAt(10)!=null)
				strTemp = (String)vEditInfo.elementAt(10);
			else
				strTemp = "";
			}
		else
			strTemp = WI.fillTextValue("dosage");
		%>
      <input name="dosage" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","dosage")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","dosage");style.backgroundColor="white"' value="<%=strTemp%>"><font size="1">&nbsp;total dosage</font></td>
      <td height="25" colspan="2"><%
      strMedfor = WI.fillTextValue("med_for_index");
      if (vEditInfo!= null && vEditInfo.size()>0)
            strTemp = (String)vEditInfo.elementAt(17);
      	else
      		strTemp = WI.fillTextValue("med_index");%>
      <%if (strMedfor.length()>0){%>
      <select name="med_index" style="font-size:11px">
          <option value="">Select Medication</option>
			<%=dbOP.loadCombo("DISTINCT MEDICATION_INDEX","MEDICATION_NAME+'-'+MEDICATION_FORM+'-'+MEDICATION_STRENGTH",
			" FROM HM_MEDICATION JOIN HM_PRELOAD_MED_NAME ON (HM_PRELOAD_MED_NAME.MEDICATION_NAME_INDEX = HM_MEDICATION.MEDICATION_NAME_INDEX) "+
			" JOIN HM_PRELOAD_MED_STRENGTH ON (HM_PRELOAD_MED_STRENGTH.MEDICATION_STRENGTH_INDEX = HM_MEDICATION.MEDICATION_STRENGTH_INDEX) "+
			" JOIN HM_PRELOAD_MED_FORM ON (HM_PRELOAD_MED_FORM.MEDICATION_FORM_INDEX = HM_MEDICATION.MEDICATION_FORM_INDEX) "+
			" WHERE HM_MEDICATION.MEDICATION_FOR_INDEX = "+strMedfor+" AND HM_MEDICATION.IS_VALID = 1 AND HM_MEDICATION.IS_DEL = 0", strTemp, false)%>
        </select><%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Dosage Interval</td>
      <td height="25" colspan="4">
            <%if(vEditInfo != null && vEditInfo.size() > 0){
				if (vEditInfo.elementAt(12)!=null)
					strTemp = (String)vEditInfo.elementAt(12);
				else
					strTemp = "";
			}
		else
			strTemp = WI.fillTextValue("dosage_intv");
		%>
      <input name="dosage_intv" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","dosage_intv")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","dosage_intv");style.backgroundColor="white"' value="<%=strTemp%>">
        <font size="1">(hrs) time between intervals</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Dosage Qty</td>
      <td height="25" colspan="2">
            <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else
			strTemp = WI.fillTextValue("dosage_qty");
		%>
      <input name="dosage_qty" type="text" size="4" class="textbox" onKeyUp= 'AllowOnlyInteger("form_","dosage_qty")' onFocus="style.backgroundColor='#D3EBFF'"
      onblur='AllowOnlyInteger("form_","dosage_qty");style.backgroundColor="white"' value="<%=strTemp%>">
      <font size="1">&nbsp;amount to take per interval</font>
      </td>

      <td height="25" colspan="1">
               <%if (false){%>
      <input type="checkbox" name="alert" value="1">
        <font color="#FF0000"><strong>ALERT<font color="#000000" size="1"> (click
        to activate ALERT) </font></strong></font>
        <%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Instruction : </td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
		else
			strTemp = WI.fillTextValue("txt_instr");
		%>
		<textarea name="txt_instr" cols="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur='style.backgroundColor="white"'><%=strTemp%></textarea></td>
      <td height="25" colspan="2"> 
	  <%
	  if(iAccessLevel > 1) {
	  if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to add entry
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
        Click to clear entries
        <%}
	}%> </td>
    </tr>

  </table>
  <%}%>
   <%if (vRetResult!=null && vRetResult.size()>0){%>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF"	>
    <tr>
      <td colspan="11" height="35"><div align="right"><img src="../../../images/print.gif" ><font size="1">click
          to print record</font></div></td>
    </tr>
  </table>
-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF"	class="thinborder">
    <tr>
      <td height="25" colspan="11" bgcolor="#FFFF9F" class="thinborder"><div align="center"><strong>LIST
          OF PRESCRIPTIONS </strong></div></td>
    </tr>
    <tr>
    <td colspan="5" class="thinborderBOTTOMLEFT"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">TOTAL
        :<strong><%=iSearchResult%></strong></font></td>
    <td colspan="4" class="thinborderBOTTOMRIGHT" align="right" style="font-size:9px;">
      <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/medMgmt.defSearchSize;
		if(iSearchResult % medMgmt.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>&nbsp;<%}%></td>
    </tr>
    <tr >
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>CASE #</strong></font></div></td>
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>DATE
          ATTENDED </strong></font></div></td>
      <td width="16%" class="thinborder"> <div align="center"><font size="1"><strong>ATTENDING DR./NURSE
          </strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>PRESCRIPTION
          FOR </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>MEDICATION</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1"> DOSAGE</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">INSTRUCTION</font></strong></div></td>
      <td width="8%" colspan="2" class="thinborder">&nbsp;</td>
    </tr>
    <%for (int i =0; i<vRetResult.size(); i+=24){
		if(vRetResult.elementAt(i + 3) == null && vRetResult.elementAt(i + 20) == null)
			strTemp = "&nbsp;";
		else if(vRetResult.elementAt(i + 3) != null && vRetResult.elementAt(i + 20) == null)
			strTemp = "("+vRetResult.elementAt(i+6)+") "+WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7);
		else if(vRetResult.elementAt(i + 3) == null && vRetResult.elementAt(i + 20) != null)
			strTemp = "("+vRetResult.elementAt(i+19)+") "+WI.formatName((String)vRetResult.elementAt(i+21), (String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23),7);
		else if(vRetResult.elementAt(i + 3) != null && vRetResult.elementAt(i + 20) != null)
			strTemp = "("+vRetResult.elementAt(i+6)+") "+WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7) +" <br>"+
			"("+vRetResult.elementAt(i+19)+") "+WI.formatName((String)vRetResult.elementAt(i+21), (String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23),7);
	
	%>
    <tr >
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder" align="center" style="font-size:9px;"><%=strTemp%></td>
      <td class="thinborder" align="center" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder"><font size="1">
      Name: <%=(String)vRetResult.elementAt(i+7)%><br>
      Form: <%=(String)vRetResult.elementAt(i+8)%><br>
      Strength: <%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1">Dosage: <%=(String)vRetResult.elementAt(i+11)%><br>
      Interval: <%=WI.getStrValue((String)vRetResult.elementAt(i+12),"","hrs","-")%><br>
      Total : <%=WI.getStrValue((String)vRetResult.elementAt(i+10),"-")%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+14)%></font></td>
      <td class="thinborder"><font size="1">
        <% if(iAccessLevel >1 && ((String)vRetResult.elementAt(i+19)).compareTo("0")==0){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i+15)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Cannot edit
        <%}%>
        </font></td>
      <td class="thinborder"><font size="1">
        <% if(iAccessLevel ==2){// && ((String)vRetResult.elementAt(i+19)).compareTo("0")==0){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i+15)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Cannot delete
        <%}%>
        </font></td>
    </tr>
    <%}%>

  </table>
       <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="10" bgcolor="#FFFFFF">&nbsp;</td>
    <tr>
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="change_med"  value="<%=strMedChange%>">
<input type="hidden" name="show_close" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
