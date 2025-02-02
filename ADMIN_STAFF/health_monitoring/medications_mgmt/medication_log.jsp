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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function TakeMedication(strPrescIndex, strDosage, strIntv, strTotal)
{
	var pgLoc = "./med_log_detail.jsp?presc_index="+strPrescIndex+"&dosage="+strDosage+"&interval="+strIntv+"&total_dose="+strTotal;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
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
function DocSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.doc_id";
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
	Vector vMedications = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String strConsentMsg = null;
	String strCaseNo = null;
	String [] astrYN = {"No", "Yes"};
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

	int iSearchResult = 0;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Medications Management","medication_log.jsp");
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
														"medication_log.jsp");
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
			strConsentMsg = dbOP.mapOneToOther("HM_MED_GUARDIAN_CONSENT","USER_INDEX",(String)vBasicInfo.elementAt(12),"AUTHORIZED_BY"," AND IS_VALID = 1 AND IS_DEL = 0");

			if (strConsentMsg !=null)
				strConsentMsg = "You are allowed to give medicine to this person";
			else
				strConsentMsg = "You do not have the consent of the guardian to give medicine to this person.";

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
	vMedications = medMgmt.operateOnMedicationLog(dbOP, request, 4);
	if (vMedications == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = medMgmt.getErrMsg();

%>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<form action="./medication_log.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td height="28" colspan="6" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          MEDICATIONS MANAGEMENT - MEDICATION LOG/TRACKING ENTRY PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="18" colspan="6" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td width="2%"  height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="15%">Enter ID No. :</td>
      <td width="16%" height="28"><%strTemp = WI.fillTextValue("stud_id");%>
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName('1');">
      </td>
      <td width="25%">
	  <%if(bolIsSchool){%>
		  <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for student</font>
	  <%}%>
	  	  </td>
      <td width="39%" rowspan="2" valign="top"> <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
          <tr>
            <td><font size="1"><br>
              Record Last Updated :<br>
              <br>
              </font><font size="1">Updated by : <br>
              <br>
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
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF" colspan="4"><font color="red"><strong><%=WI.getStrValue(strConsentMsg)%></strong></font>
	  <label id="coa_info" style="font-size:11px;"></label></td>
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
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
     <%
	if (vMedications != null && vMedications.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#FFFFCA">
      <td height="25" colspan="6" class="thinborder"><div align="center" class="thinborder"><strong>LIST OF MEDICATIONS</strong></div></td>
    </tr>

    <tr>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Medication for</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Medication</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Dosage</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Instruction</strong></font></div></td>
	<td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Prescribed by</strong></font></div></td>
	<td width="10%" class="thinborder">&nbsp;</td>
    </tr>
<%
	for (int i =0; i<vMedications.size(); i+=16){
%>
<tr>
<td class="thinborder"><font size="1"><%=(String)vMedications.elementAt(i+6)%></font></td>
<td class="thinborder"><font size="1">
      Name: <%=(String)vMedications.elementAt(i+7)%><br>
      Form: <%=(String)vMedications.elementAt(i+8)%><br>
      Strength: <%=(String)vMedications.elementAt(i+9)%></font></td>
<td class="thinborder"><font size="1">Dosage: <%=(String)vMedications.elementAt(i+11)%><br>
      Interval: <%=WI.getStrValue((String)vMedications.elementAt(i+12),"","hrs","-")%><br>
      Total : <%=WI.getStrValue((String)vMedications.elementAt(i+10),"-")%></font></td>
<td class="thinborder"><%=(String)vMedications.elementAt(i+13)%></td>
<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vMedications.elementAt(i+2),"(",")","")%><br><%=WI.formatName((String)vMedications.elementAt(i+3), (String)vMedications.elementAt(i+4), (String)vMedications.elementAt(i+5),7)%></font></td>
<td class="thinborder"><a href='javascript:TakeMedication(<%=(String)vMedications.elementAt(i+14)%>, <%=(String)vMedications.elementAt(i+11)%>,
<%=(String)vMedications.elementAt(i+12)%>, <%=(String)vMedications.elementAt(i+10)%>)'><img src="../../../images/assign.gif" border="0"></a></td>
</tr>
	<%}%>
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="10" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
