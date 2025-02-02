<%@ page language="java" import="utility.*,health.RecordHealthInformation,java.util.Vector " %>
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
<title>Patient Health Status..</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function UpdateBG() {
	if(document.form_.stud_id.value.length == 0) {
		alert("Please enter student ID.");
		return;
	}

	var loadPg = "./blood_group.jsp?stud_id="+escape(document.form_.stud_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function UpdateRecord(){
	document.form_.page_action.value = "1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function ViewInfo(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
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
function ViewPastRecord() {
	document.form_.info_index.value = "";
	document.form_.submit();
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
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-PAST MEDICAL HISTORY","past_mh_entry.jsp");
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
														"Health Monitoring","PAST MEDICAL HISTORY",request.getRemoteAddr(),
														"past_mh_entry.jsp");
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
Vector vBasicInfo = null; Vector vHealthInfo = null; Vector vAdditionalInfo = null;
Vector vLTInfo    = null; Vector vUTestInfo  = null; Vector vRecords = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
RecordHealthInformation RH = new RecordHealthInformation();

//get all levels created.
	if(WI.fillTextValue("stud_id").length() > 0) {	
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		if(strTemp == null)
			strErrMsg = "ID number does not exist or is invalidated.";
	}

//if(WI.fillTextValue("stud_id").length() > 0) {	
if(strTemp != null){
	if(bolIsSchool)
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
	{
		request.setAttribute("emp_id",request.getParameter("stud_id"));
		vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vBasicInfo != null)
			bolIsStaff = true;
	}
	else if(bolIsSchool) {//check if student is currently enrolled
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
		(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
	}
	if(vBasicInfo == null)
		strErrMsg = OAdm.getErrMsg();
}
//gets health info.
if(vBasicInfo!= null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		//I have to add / edit here.
		if(RH.operateOnPastHealthInfo(dbOP, request,1) == null)
			strErrMsg = RH.getErrMsg();
		else
			strErrMsg = "Health Record successfully updated.";
	}
	
	if(WI.fillTextValue("info_index").length() > 0)
		vHealthInfo = RH.operateOnPastHealthInfo(dbOP, request, 4);
		
	if(vHealthInfo == null)
		strErrMsg = RH.getErrMsg();
	else {
		vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
		vLTInfo = (Vector)vHealthInfo.elementAt(1);
		if(vLTInfo == null)
			strErrMsg = RH.getErrMsg();
		vUTestInfo = (Vector)vHealthInfo.elementAt(2);
		if(vUTestInfo == null)
			strErrMsg = RH.getErrMsg();
		else if(vUTestInfo.size() == 0)
			vUTestInfo = null;

		if(vAdditionalInfo.size() ==0)
			vAdditionalInfo = null;
	}
	
	vRecords = RH.operateOnPastHealthInfo(dbOP, request, 5);
	if(vRecords == null)
		strErrMsg = RH.getErrMsg();
}
%>
<form action="past_mh_rec.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr >
			<td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" >
				<strong>:::: PAST MEDICAL RECORD VIEW PAGE ::::</strong></font></div></td>
		</tr>
		<tr >
			<td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;
				<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
		<tr >
			<td width="2%">&nbsp;</td>
			<td width="15%">Enter ID No. :</td>
			<td width="20%">
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				 onKeyUp="AjaxMapName('1');"></td>
			<td colspan="2">
				<%if(bolIsSchool){%>
					<a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a>
					<font size="1">Click to search for student </font>
				<%}%>
				<a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a>
				<font size="1"> Click to search for employee </font>
			<label id="coa_info" style="font-size:11px;"></label>
			</td>
			<td width="3%" valign="top" >&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="6">&nbsp;</td>
		</tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ViewPastRecord();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="21%" >&nbsp;</td>
      <td width="39%" valign="top" >&nbsp;</td>
      <td valign="top" >&nbsp;</td>
    </tr>
  </table>
<%
if(vBasicInfo != null){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15"><hr size="1"></td>
		</tr>
	</table>
	
	<%if(vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date Recorded: </td>
			<td colspan="2"><%=(String)vAdditionalInfo.elementAt(0)%></td>
			<td valign="top" >
				<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
					<tr>
						<td><font size="1">Record Last Updated :
							<%if(vAdditionalInfo != null){%>
								<%=(String)vAdditionalInfo.elementAt(5)%>
							<%}%></font>
							<br><br>
							<font size="1">Updated by :
							<%if(vAdditionalInfo != null){%>
								<%=(String)vAdditionalInfo.elementAt(6)%>
							<%}%></font></td>
					</tr>
				</table>
			</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td height="15" width="2%">&nbsp;</td>
			<td width="15%">&nbsp;</td>
			<td width="20%">&nbsp;</td>
			<td width="21%">&nbsp;</td>
			<td width="39%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
		
	</table>
	<%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(!bolIsStaff){%>
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled
        <%}else{%>
        Not Currently Enrolled
        <%}%></td>
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
      <td>Emp. Name :</td>
      <td><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></strong></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
  </table>
<%
}///only if vBasicInfo is not null

if(vBasicInfo != null && vHealthInfo != null){%>

  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#FFFF9F">
      <td width="38%" height="25">&nbsp;</td>
      <td width="7%"><div align="center">Yes</div></td>
      <td width="7%"><div align="center">No</div></td>
      <td width="48%">Remark</td>
    </tr>
    <%
for(int i = 3 ; i < vHealthInfo.size(); i +=4){
	strTemp =  WI.getStrValue((String)vHealthInfo.elementAt(i + 2),"0");
	%>
    <tr bgcolor="#FFFFFF">
      <td height="25"><%=(String)vHealthInfo.elementAt(i + 1)%></td>
      <td align="center">&nbsp;
<%if(strTemp.compareTo("1") ==0) {%>
			<img src="../../../images/tick.gif"><%}%></td>
      <td align="center">&nbsp;
<%if(strTemp.compareTo("0") ==0) {%>
			<img src="../../../images/tick.gif"><%}%></td>
      <td><%=WI.getStrValue(vHealthInfo.elementAt(i + 3),"&nbsp;")%></td>
    </tr>
<%
}//end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr valign="bottom" bgcolor="#FFFFFF">
      <td height="25">Surgical Operations (pls specify) :</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1),"&nbsp;")%></strong></td>
    </tr>
    <tr valign="bottom" bgcolor="#FFFFFF">
      <td height="25">Last hospitalization Date: <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(2),"&nbsp;")%></strong></td>
    </tr>
    <tr valign="bottom" bgcolor="#FFFFFF">
      <td height="25">Hospitalization Reason : <strong><%=WI.getStrValue(vAdditionalInfo.elementAt(3),"&nbsp;")%></strong></td>
    </tr>
    <tr valign="bottom" bgcolor="#FFFFFF">
      <td height="25">Others (pls specify) : </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(4),"&nbsp;")%></strong></td>
    </tr>
  </table>
<%
if(vLTInfo != null && vLTInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
    <tr bgcolor="#FFFF9F">
      <td width="36%" height="25"><strong>Last Taken</strong></td>
      <td width="23%"><div align="center"><strong>Date</strong></div></td>
      <td width="41%"><strong>Result/Remarks</strong></td>
    </tr>
<%
for(int i = 0 ; i < vLTInfo.size() ; i+= 4) {%>
    <tr bgcolor="#FFFFFF">
      <td height="25"><%=(String)vLTInfo.elementAt(i+1)%></td>
      <td align="center"><%=WI.getStrValue(vLTInfo.elementAt(i + 2),"&nbsp;")%></td>
      <td><%=WI.getStrValue(vLTInfo.elementAt(i + 3),"&nbsp;")%></td>

    </tr>
<%}//end of for loop%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//only if vLTInfo is not null%>
			
	<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
		<tr bgcolor="#FFFFFF">
			<td height="25" colspan="2"><strong>Urine Test (Quantitative Analysis)</strong></td>
			<td width="31%">Date : <strong><%=WI.getStrValue(vUTestInfo.elementAt(20))%></strong></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td width="57%" height="25">&nbsp;</td>
			<td width="12%"><div align="center"><strong>Normal/Negative<br><font size="1">(Specific Value)</font></strong></div></td>
			<td><div align="center"><strong>Not Normal/ Positive<br><font size="1">(Specific Value)</font></strong></div></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Urobilinogen</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(0))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(1))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Glucose</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(2))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(3))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Ketones</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(4))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(5))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Bilirubin</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(6))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(7))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Protein</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(8))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(9))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Nitrite</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(10))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(11))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">pH</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(12))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(13))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Blood</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(14))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(15))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Specific Gravity</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(16))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(17))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Leukocytes</td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(18))%></td>
			<td><%=WI.getStrValue(vUTestInfo.elementAt(19))%></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%}//only if vBasicInfo is not null%>

	<%if(vRecords != null && vRecords.size() > 0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr> 
		  		<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder" align="center">
					<strong>::: LIST OF PAST RECORDS :::</strong></td>
			</tr>
			<tr>
				<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Effective Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Recorded Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Updated Date</strong></td>
				<td width="25%" align="center" class="thinborder"><strong>Updated By</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
			</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRecords.size(); i+=7,iCount++){%>
			<tr>
				<td height="25" align="center" class="thinborder"><%=iCount%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+2)%> - <%=(String)vRecords.elementAt(i+3)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+1)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+4)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+5)%>
					<%=WI.getStrValue((String)vRecords.elementAt(i+6), "(", ")", "&nbsp;")%></td>
			    <td align="center" class="thinborder">
					<a href="javascript:ViewInfo('<%=(String)vRecords.elementAt(i)%>');">
						<img src="../../../images/view.gif" border="0"></a></td>
			</tr>
		<%}%>
		</table>
	<%}%>

	<table  width="100%" border="0" cellpadding="0" cellspacing="0" >
		<tr >
			<td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr >
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
