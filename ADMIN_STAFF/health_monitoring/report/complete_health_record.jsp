<%@ page language="java" import="utility.*,health.PresentHealthStatus,health.RecordHealthInformation,java.util.Vector " %>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
	var obj = document.getElementById('myADTable1');
	
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	obj = document.getElementById('myADTable2');
	obj.deleteRow(0);
	obj.deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function OpenSearch() {
<%
if(bolIsSchool){%>
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
<%}else{%>
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
<%}%>
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function  FocusID() {
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}</script>
<body onLoad="FocusID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strImgFileExt = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","complete_health_record.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Health Monitoring","Report",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0)
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
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
Vector vBGroup = null;Vector vBasicInfo = null;Vector vHealthInfo = null;Vector vAdditionalInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
PresentHealthStatus presentHealthStat = new PresentHealthStatus();
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
RecordHealthInformation RH = new RecordHealthInformation();

int iGender = -1;

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
	else
		iGender = CommonUtil.getGender(dbOP, WI.fillTextValue("stud_id")); 
}
//gets health info.
if(vBasicInfo!= null) {
	vBGroup = presentHealthStat.operateOnBloodGroup(dbOP, request,3);
	vHealthInfo = RH.operateOnPresentHealthInfo(dbOP, request,4);
	if(vHealthInfo == null)
		strErrMsg = RH.getErrMsg();
	else {
		vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
		if(vAdditionalInfo.size() ==0)
			vAdditionalInfo = null;
	}
}
%>
<form method="post" name="form_" action="./complete_health_record.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
		<tr >
			<td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic">
				<div align="center"><font color="#FFFFFF" ><strong>:::: COMPLETE HEALTH RECORD ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr valign="top">
			<td width="2%"  >&nbsp;</td>
			<td width="15%" >Enter ID No. :</td>
			<td width="20%" >
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
			<td width="21%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a></td>
			<td width="39%" valign="top" ><label id="coa_info" style="font-size:11px;"></label></td>
			<td width="3%" valign="top" >&nbsp;</td>
		</tr>
    <tr >
      <td width="2%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td width="20%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
      <td width="21%" >&nbsp;</td>
      <td width="39%" align="right" style="font-size:9px;">
	  <%if(vAdditionalInfo != null) {%>
	  	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
		Print page.
	  <%}%>
	  </td>
      <td width="3%">&nbsp;</td>
    </tr>
<%if(vAdditionalInfo != null){%>
    <tr >
      <td colspan="6" style="font-size:11px; font-weight:bold;" align="center"><u>COMPLETE  HEALTH RECORD </u></td>
    </tr>
 <tr >
      <td >&nbsp;</td>
      <td >Date Recorded: </td>
      <td colspan="2"  height="25"><%=vAdditionalInfo.elementAt(0)%></td>
      <td valign="top" ><%if(vAdditionalInfo!= null){%>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td><font size="1">
              Record Last Updated :
              <%if(vAdditionalInfo != null){%>
              <%=(String)vAdditionalInfo.elementAt(3)%>
              <%}%>
              <br>
              <br>
              </font><font size="1">Updated by :
                <%if(vAdditionalInfo != null){%>
                <%=(String)vAdditionalInfo.elementAt(4)%>
                <%}%>
              </font></td>
          </tr>
        </table>
      <%}%></td>
      <td valign="top" >&nbsp;</td>
    </tr>
<%}%>
	</table>
	
<%if(vBasicInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="18" colspan="4" ><hr size="1"></td>
		</tr>
    <%if(!bolIsStaff){%>
		<tr >
			<td  width="2%" height="25">&nbsp;</td>
			<td width="18%">Student Name</td>
			<td width="55%"><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
			<td width="25%" rowspan="3" valign="top" align="left">
				<%if(strImgFileExt != null){%> 
				<table bgcolor="#000000">
					<tr>
						<td>
							<img src="../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85">
						</td>
					</tr>
				</table>
				<%}%>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status</td>
			<td height="25">
		<%if(bolIsStudEnrolled){%>
			Currently Enrolled
		<%}else{%>
			Not Currently Enrolled
		<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td >Year</td>
			<td height="25" ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major</td>
			<td colspan="2" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
	  </tr>
    <%}//if not staff
	else{%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Emp. Name</td>
			<td><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
			<td rowspan="3" valign="top" align="left">
			<%if(strImgFileExt != null){%>
				<img src="../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85" border="1">
			<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td >Date of Birth</td>
			<td ><%=(String)vBasicInfo.elementAt(5)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td >Emp. Status</td>
			<td ><%=(String)vBasicInfo.elementAt(16)%> </td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td >Designation</td>
			<td ><%=(String)vBasicInfo.elementAt(15)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%></td>
			<td colspan="2" ><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></td>
		</tr>
	<%}//only if staff %>
		<tr >
			<td>&nbsp;</td>
			<td colspan="3" align="center">
				<table width="50%">
					<tr>
						<td height="25"> Blood Group :
						<%if(vBGroup != null){%><b>
							<%=(String)vBGroup.elementAt(2)%> <%=(String)vBGroup.elementAt(3)%></b> 
						<%}%></td>
					</tr>
				</table>
				<br>
			</td>
		</tr>
	</table>
<%}///only if vBasicInfo is not null

if(vHealthInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#3366FF">
      <td height="25" colspan="6" class="thinborder">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">PRESENT
        HEALTH STATUS</font></strong></td>
    </tr>
    <tr bgcolor="#FFFFBF">
      <td width="36%" height="25" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder"><div align="center"><strong>Yes</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>No</strong></div></td>
      <td width="36%" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder"><div align="center"><strong>Yes</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>No</strong></div></td>
    </tr>
    <%
for(int i = 1 ; i < vHealthInfo.size(); i +=3){
	//get in here if it is yes/no type.
	strTemp = (String)vHealthInfo.elementAt(i + 1);
	if(strTemp != null){//this is for Yes/ No
	%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vHealthInfo.elementAt(i)%></td>
      <td class="thinborder"><div align="center">
          <%
strTemp = WI.getStrValue((String)vHealthInfo.elementAt(i + 1), "0");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
if(strTemp.length() > 0){%>
          <img src="../../../images/tick.gif">
          <%}%>
          &nbsp;</div></td>
      <td class="thinborder"><div align="center">
          <%if(strTemp.length() == 0){%>
          <img src="../../../images/tick.gif">
          <%}%>
          &nbsp;</div></td>
      <td class="thinborder"> <%
	  i += 3;
	  if(i < vHealthInfo.size()) {
	  		strTemp = (String)vHealthInfo.elementAt(i + 1);
			if(strTemp == null){//change to duration options.
				i -= 3;
			}
	 	}

	  if(strTemp != null && i < vHealthInfo.size()){%> <%=(String)vHealthInfo.elementAt(i)%> <%}%> &nbsp;</td>
      <td class="thinborder"><div align="center">&nbsp;
          <%if(strTemp != null && i < vHealthInfo.size()){%>
          <%
strTemp2 = WI.getStrValue((String)vHealthInfo.elementAt(i + 1), "0");
if(strTemp2.compareTo("1") ==0)
	strTemp2 = " checked";
else
	strTemp2 = "";
%>
          <%if(strTemp2.length() > 0){%>
          <img src="../../../images/tick.gif">
          <%}}%>
        </div></td>
      <td class="thinborder"><div align="center">&nbsp;
          <%
		if(strTemp != null && i < vHealthInfo.size()){%>
          <%if(strTemp2.length() == 0){%>
          <img src="../../../images/tick.gif">
          <%}}%>
        </div></td>
    </tr>
    <%}//end of loop if response type is yes/ no
else{%>
    <tr>
      <td height="25"><%=(String)vHealthInfo.elementAt(i)%> </td>
      <td colspan="5"><%=WI.getStrValue((String)vHealthInfo.elementAt(i + 2),"N/A")%></td>
    </tr>
    <%}

}//end of for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="bottom">
      <td height="31"><strong><u>Present medications taken :</u></strong> </td>
    </tr>
    <tr>
      <td height="25"><%=WI.getStrValue(vAdditionalInfo.elementAt(1), "No Record")%>&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td height="30"><strong><u>Additional Comments : </u></strong></td>
    </tr>
    <tr>
      <td height="25"> <%=WI.getStrValue(vAdditionalInfo.elementAt(2),"None")%>&nbsp;</td>
    </tr>
  </table>
<%}//only if Health Info is not null;/// end of present medical record
//I have to get Family history here.
vHealthInfo = null;
if(vBasicInfo!= null)
	vHealthInfo = RH.operateOnFamilyHealthInfo(dbOP, request,4);
//System.out.println(vHealthInfo);
if(vHealthInfo != null){
vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
	if(vAdditionalInfo.size() ==0)
		vAdditionalInfo = null;
	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr >
      <td height="25" colspan="4" bgcolor="#3366FF" class="thinborder">&nbsp;&nbsp;&nbsp;
	  <strong><font color="#FFFFFF">FAMILY HEALTH RECORD</font></strong></td>
    </tr>
    <tr >
      <td width="25%" height="25" bgcolor="#FFFFAF" class="thinborder">&nbsp;</td>
      <td width="7%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><strong>Yes</strong></div></td>
      <td width="7%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><strong>No</strong></div></td>
      <td width="61%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><strong>Specify Relationship</strong></div></td>
    </tr>
    <%
int j = 0 ;
for(int i = 1 ; i < vHealthInfo.size(); i += 4, ++j){%>
    <input type="hidden" name="HM_ENTRY_INDEX<%=j%>" value="<%=(String)vHealthInfo.elementAt(i)%>">
    <tr>
      <td height="25" class="thinborder"><%=(String)vHealthInfo.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"> <%
strTemp = WI.getStrValue((String)vHealthInfo.elementAt(i + 2), "0");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";

if(strTemp.length() > 0){%> <img src="../../../images/tick.gif">
        <%}%> &nbsp;</td>
      <td align="center" class="thinborder"> <%if(strTemp.length() == 0){%> <img src="../../../images/tick.gif"> <%}%> &nbsp;</td>
      <td class="thinborder"><%=RH.getRelationList(dbOP, (String)vHealthInfo.elementAt(i + 3), j, true)%>&nbsp;</td>
    </tr>
    <%}//end of for loop%>
    <input type="hidden" name="health_record_count" value="<%=j%>">
    <tr valign="bottom">
      <td height="30" colspan="4"><strong>Comments/Remarks :</strong> </td>
    </tr>
    <tr >
      <td height="30" colspan="4"> <%=WI.getStrValue(vAdditionalInfo.elementAt(1),"None")%></td>
    </tr>
  </table>
<%}//only if vHealthInfo is not null/// end of Past family history
//get past medical history here.
Vector vLTInfo    = null;
Vector vUTestInfo = null;
vHealthInfo       = null;

if(vBasicInfo!= null) {
	strTemp = RH.getLastPastRecordInfo(dbOP, request, (String)vBasicInfo.elementAt(0));	
	if(strTemp != null)
		request.setAttribute("health_index",strTemp);

	vHealthInfo = RH.operateOnPastHealthInfo(dbOP, request, 4);
	
	if(vHealthInfo != null) {
		vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
		vLTInfo = (Vector)vHealthInfo.elementAt(1);
		if(vLTInfo == null)
			strErrMsg = RH.getErrMsg();
		vUTestInfo = (Vector)vHealthInfo.elementAt(2);
		if(vUTestInfo == null)
			strErrMsg = RH.getErrMsg();
		else if(vUTestInfo.size() == 0)
			vUTestInfo = null;
	}
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
if(strSchCode.startsWith("TSUNEISHI"))
	vHealthInfo = null;
	
if(vHealthInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr bgcolor="#3366FF">
			<td height="25" colspan="4" class="thinborder">&nbsp;&nbsp;&nbsp; <strong><font color="#FFFFFF">PAST HEALTH RECORD</font></strong></td>
		</tr>
		<tr bgcolor="#FFFFAF">
			<td width="38%" height="25" class="thinborder">&nbsp;</td>
			<td width="7%" class="thinborder"><div align="center"><strong>Yes</strong></div></td>
			<td width="7%" class="thinborder"><div align="center"><strong>No</strong></div></td>
			<td width="48%" class="thinborder"><strong>Remark</strong></td>
		</tr>
    <%
for(int i = 3 ; i < vHealthInfo.size(); i +=4){
	strTemp =  WI.getStrValue((String)vHealthInfo.elementAt(i + 2),"0");
	%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vHealthInfo.elementAt(i + 1)%></td>
      <td align="center" class="thinborder">&nbsp; <%if(strTemp.compareTo("1") ==0) {%> <img src="../../../images/tick.gif"> <%}%></td>
      <td align="center" class="thinborder">&nbsp; <%if(strTemp.compareTo("0") ==0) {%> <img src="../../../images/tick.gif"> <%}%></td>
      <td class="thinborder"><%=WI.getStrValue(vHealthInfo.elementAt(i + 3),"&nbsp;")%></td>
    </tr>
    <%
}//end of for loop%>
  </table>
			
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr valign="bottom">
			<td height="25"><strong><u>Surgical Operations (pls specify) :</u></strong></td>
		</tr>
		<tr>
			<td height="25"><%=WI.getStrValue(vAdditionalInfo.elementAt(1),"None")%></td>
		</tr>
		<tr valign="bottom">
			<td height="25"><strong><u>Last hospitalization Date:</u></strong> <%=WI.getStrValue(vAdditionalInfo.elementAt(2),"No Record")%></td>
		</tr>
		<tr valign="bottom">
			<td height="25"><strong><u>Hospitalization Reason :</u></strong> <%=WI.getStrValue(vAdditionalInfo.elementAt(3),"No Record")%></td>
		</tr>
		<tr valign="bottom">
			<td height="25"><strong><u>Others (pls specify) : </u></strong></td>
		</tr>
		<tr>
			<td height="25"><%=WI.getStrValue(vAdditionalInfo.elementAt(4),"None")%></td>
		</tr>
	</table>
	
<%if(vLTInfo != null && vLTInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF">
      <td width="36%" height="25" class="thinborder"><strong>Last Taken</strong></td>
      <td width="23%" class="thinborder"><div align="center"><strong>Date</strong></div></td>
      <td width="41%" class="thinborder"><strong>Result/Remarks</strong></td>
    </tr>
<%
for(int i = 0 ; i < vLTInfo.size() ; i+= 4) {%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vLTInfo.elementAt(i+1)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vLTInfo.elementAt(i + 2),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vLTInfo.elementAt(i + 3),"&nbsp;")%></td>

    </tr>
<%}//end of for loop%>
  </table>
  <br>&nbsp;
<%}//only if vLTInfo is not null%>			
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="2" class="thinborder"><strong>Urine Test (Quantitative Analysis)</strong></td>
			<td width="31%" class="thinborder">Date : <strong><%=WI.getStrValue(vUTestInfo.elementAt(20))%></strong></td>
		</tr>
		<tr>
			<td width="57%" height="25" class="thinborder">&nbsp;</td>
			<td width="12%" class="thinborder"><div align="center"><strong>Normal/Negative<br>
				<font size="1">(Specific Value)</font></strong></div></td>
			<td class="thinborder"><div align="center"><strong>Not Normal/ Positive<br>
				<font size="1">(Specific Value)</font></strong></div></td>
		</tr>
			<tr>
			<td height="25" class="thinborder">Urobilinogen</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(0), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(1), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Glucose</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(2), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(3), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Ketones</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(4), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(5), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Bilirubin</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(6), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(7), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Protein</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(8), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(9), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Nitrite</td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(10), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(11), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">pH</td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(12), "&nbsp;")%></td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(13), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Blood</td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(14), "&nbsp;")%></td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(15), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Specific Gravity</td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(16), "&nbsp;")%></td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(17), "&nbsp;")%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Leukocytes</td>
			<td class='thinborder'><%=WI.getStrValue(vUTestInfo.elementAt(18), "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue(vUTestInfo.elementAt(19), "&nbsp;")%></td>
		</tr>
	</table>	
<%}//only if vHealthInfo is not null/// end of Past medical history.
//print here SOCIAL HISTORY.
vHealthInfo = null;
if(vBasicInfo!= null) {
	vHealthInfo = RH.oprateOnSocialHistory(dbOP, request,4);
}
String[] astrConvertYN ={"No","Yes"};
String[] astrConvertSticksPD ={"None","1-5","6-10","11-15","16-20","More"};
String[] astrConvertAlcoholFreq ={"Never","Daily","Weekly","Monthly","Occasionally"};
if(vHealthInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="3" bgcolor="#3366FF" class="thinborder">&nbsp;&nbsp;&nbsp;<strong><font color="#FFFFFF">SOCIAL HISTORY</font></strong></td>
		</tr>
		<tr >
			<td width="30%" height="25" class="thinborder">Smoking: <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(1),"0"))]%></td>
			<td width="33%" class="thinborder">Age Started : <%=WI.getStrValue((String)vHealthInfo.elementAt(2), "N/A")%></td>
			<td width="37%" class="thinborder">Sticks per day : <%=astrConvertSticksPD[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(3),"0"))]%></td>
		</tr>
		<tr >
			<td height="25" class="thinborder">Alcohol : <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(4),"0"))]%></td>
			<td class="thinborder">How often : <%=astrConvertAlcoholFreq[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(5),"0"))]%></td>
			<td class="thinborder">Food Preference :<%=WI.getStrValue((String)vHealthInfo.elementAt(6),"Not Set")%></td>
		</tr>
	</table>
<%}//only if vHealthInfo is not null //END OF SOCIAL HISTORY
//get OB GYN history.
if(vBasicInfo!= null) {
	vHealthInfo = RH.oprateOnOBGyn(dbOP, request,4);
}
String[] astrParity ={"F","P","A","L"};
if(vHealthInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td height="25" colspan="2" bgcolor="#3366FF" class="thinborder">&nbsp;&nbsp;&nbsp;
				<strong><font color="#FFFFFF">OB GYN HISTORY</font></strong></td>
		</tr>
	<%if(iGender == 1){%>
		<tr>
			<td height="25" colspan="2" class="thinborder"><strong><font color="#FF0000">For Female Personnel</font></strong></td>
		</tr>
		<tr>
			<td height="25" colspan="2" class="thinborder">Menarche : <%=(String)vHealthInfo.elementAt(1)%>
				Cycle : <%=(String)vHealthInfo.elementAt(2)%>
				Duration : <%=(String)vHealthInfo.elementAt(3)%></td>
		</tr>
		<tr>
			<td height="25" colspan="2" class="thinborder">Parity: <%=astrParity[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(4),"0"))]%></td>
		</tr>
		<tr >
			<td width="56%" height="25" class="thinborder">Papsmear done: <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(5),"0"))]%></td>
			<td width="44%" class="thinborder"> Date : <%=WI.getStrValue((String)vHealthInfo.elementAt(6))%></td>
		</tr>
		<tr >
			<td height="25" class="thinborder">Self Breast Examination : <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(7),"0"))]%></td>
			<td class="thinborder">Date : <%=WI.getStrValue((String)vHealthInfo.elementAt(8))%></td>
		</tr>
		<tr >
			<td height="29" class="thinborder">Mass Noted : <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(9),"0"))]%></td>
			<td class="thinborder">Where : <%=WI.getStrValue(vHealthInfo.elementAt(10))%></td>
		</tr>
	<%}else{%>
		<tr>
			<td height="25" colspan="2" class="thinborder"><strong><font color="#FF0000">For Male Personnel</font></strong></td>
		</tr>
		<tr>
			<td height="25" class="thinborder">Digital Rectal Examination: <%=astrConvertYN[Integer.parseInt(WI.getStrValue(vHealthInfo.elementAt(11),"0"))]%></td>
			<td class="thinborder">Date: <%=WI.getStrValue((String)vHealthInfo.elementAt(12))%></td>
		</tr>
		<tr>
			<td height="25" colspan="2" class="thinborder">Result : <%=WI.getStrValue((String)vHealthInfo.elementAt(13))%></td>
		</tr>
	<%}%>
	</table>
<%}//only if vBasicInfo is not null//end of ob gyn.%>

	<table  width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
		<tr >
			<td height="25" colspan="9">&nbsp;</td>
		</tr>
		<tr >
			<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
