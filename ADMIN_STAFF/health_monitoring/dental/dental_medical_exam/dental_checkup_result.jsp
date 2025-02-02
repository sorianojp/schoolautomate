<%@ page language="java" import="utility.*, health.HealthExamination ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src ="../../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">

function PageAction(){
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function Search()
{
	document.form_.search_.value = "1";
	document.form_.submit();
}

function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.submit();
}


function  FocusID() {
	document.form_.id_number.focus();
}

function AjaxMapName() {
	var strCompleteName;
	strCompleteName = document.form_.id_number.value;

	if(strCompleteName.length <=2)
		return;

	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.id_number.value = strID;
	document.form_.id_number.focus();
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./dental_checkup_result_print.jsp" />

	<%return;}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","dental_checkup_result.jsp");
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
														"dental_checkup_result.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vBasicInfo = null;

boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
HealthExamination HE = new HealthExamination();
boolean bolShowPrint = false;
Vector vRetResult = null;

if(WI.fillTextValue("id_number").length() > 0) {	
	strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("id_number"));
	if(strTemp == null)
		strErrMsg = "ID number does not exist or is invalidated.";
}


if(strTemp != null){	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(HE.operateOnDentalMedicalExamination(dbOP, request, 1) == null)
			strErrMsg = HE.getErrMsg();
		else{
			strErrMsg = "Dental result updated successfully.";
			bolShowPrint = true;
		}
	}
	
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number"));	
	if(vBasicInfo == null)
		strErrMsg = OAdm.getErrMsg();
	else{
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number"),
		(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
	}
	
	vRetResult = HE.operateOnDentalMedicalExamination(dbOP, request, 5);
	if(vRetResult != null && vRetResult.size() > 0)
		bolShowPrint = true;
	
}

 
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onLoad="FocusID();">
<form action="dental_checkup_result.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DENTAL EXAM RESULT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">

<tr valign="top">
	<td width="2%" >&nbsp;</td>
	<td width="15%" >Enter ID No. :</td>
	<td>
		<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
	<label id="coa_info" style="width:300px; position:absolute"></label>	
	</td>		
</tr>
<tr><td height="5" colspan="3"></td></tr>
<tr>
	<td colspan="2">&nbsp;</td>
	<td><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
</tr>

</table>  


<%if(vBasicInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr><td height="18" colspan="4" ><hr size="1"></td></tr>
    
		<tr >
			<td  width="2%" height="25">&nbsp;</td>
			<td width="18%">Student Name</td>
			<td width="55%"><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),(String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
			<td width="25%" rowspan="3" valign="top" align="left">
				<%if(strImgFileExt != null){%> 
				<table bgcolor="#FFFFFF">
					<tr>
						<td>
							<img src="../../../../upload_img/<%=WI.fillTextValue("id_number").toUpperCase()%>.<%=strImgFileExt%>" width="85" height="85" border="1">
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
	</table>
	
<%if(bolShowPrint){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>		
		<td width="42%" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>		</td>
	</tr>
</table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="2" height="25" align="center"><strong>LIST OF DENTAL PROBLEMS</strong></td></tr>
	<tr><td width="50%" height="20" align="right">
		<%
		strTemp = WI.fillTextValue("field_1");
		if(strTemp.equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
		<input type="checkbox" name="field_1" <%=strTemp%> value="1" ></td>
		<td>&nbsp; Cavity for Filling</td></tr>
	<tr><td height="20" align="right">
		<%
			strTemp = WI.fillTextValue("field_2");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>
		<input type="checkbox" name="field_2" value="1" <%=strTemp%> ></td>
		<td>&nbsp; Tooth/Teeth for Extraction</td></tr>
	<tr><td height="20" align="right">
		<%
			strTemp = WI.fillTextValue("field_3");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
		%>
		<input type="checkbox" name="field_3" value="1" <%=strTemp%> ></td>
		<td>&nbsp; Oral Prohylaxis</td></tr>
		
		
</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">

<tr>
	    <td width="13%" height="22">&nbsp;</td>		
	    <td width="15%">School Dentist</td>
	    <td width="72%">
			<select name="school_physician_index" style="width:300px;" onChange="Search();">
				<option value="">Select School Dentist</option>
				<%
				strTemp = " from HM_DENTAL_MEDICAL_EXAM where is_valid =1 and report_type = 2"+
					" order by school_physician ";
				
				strErrMsg = WI.fillTextValue("school_physician_index");				
				%>
				<%=dbOP.loadCombo("distinct school_physician","school_physician",strTemp,strErrMsg,false)%>
			</select></td>
	    </tr>
	<tr>
	    <td height="22">&nbsp;</td>
	    <td>License No.</td>
		<%
		strTemp = WI.fillTextValue("license_no");		
			
		String strDisabled = "";
		if(WI.fillTextValue("school_physician_index").length()  >0){
			strErrMsg = "select distinct license_no from HM_DENTAL_MEDICAL_EXAM where is_valid =1  "+
				" and SCHOOL_PHYSICIAN = "+WI.getInsertValueForDB(WI.fillTextValue("school_physician_index"), true, null);
			strTemp = dbOP.getResultOfAQuery(strErrMsg,0 );
			
			strDisabled = "readonly";
		}
		%>
	    <td>
			<input name="license_no" type="text" size="40" maxlength="256" class="textbox" 
				value="<%=WI.getStrValue(strTemp)%>"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>

</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="58%" align="center">
			<a href="javascript:PageAction();"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save result</font>		</td>		
		
	</tr>
	
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td height="10" colspan="9">&nbsp;</td></tr>
<tr><td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td></tr>
</table>

	<input type="hidden" name="search_" value="" />
	<input type="hidden" name="no_of_fields" value="3" /> <!--do not forget to update this is you add some fields-->
	<input type="hidden" name="page_action" value="" >
	<input type="hidden" name="is_dental" value="1">
	<input type="hidden" name="print_page" >
	<input type="hidden" name="report_type" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
