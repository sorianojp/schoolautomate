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


function Search()
{
	document.form_.search_.value = "1";
	document.form_.print_page.value="";
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
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.id_number.value = strID;
	document.form_.id_number.focus();
	document.getElementById("coa_info").innerHTML = "";
	document.form_.print_page.value="";
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
	
	if(WI.fillTextValue("print_page").length() > 0){
		if(WI.fillTextValue("edu_level").equals("3")){
	%>
			<jsp:forward page="./parent_consent_for_high_school_print.jsp" />
		<%}else{%>
			<jsp:forward page="./parent_consent_for_elem_print.jsp" />
		<%}	
	return;}
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
														"parent_consent.jsp");
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

String strCurSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strCurSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
String strCurSem    = (String)request.getSession(false).getAttribute("cur_sem");

if(WI.fillTextValue("id_number").length() > 0) {	
	strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("id_number"));
	if(strTemp == null)
		strErrMsg = "ID number does not exist or is invalidated.";
}
boolean bolIsBasic = false;
String strEduLevel = null;
if(strTemp != null){	

	
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number"));	
	if(vBasicInfo == null)
		strErrMsg = OAdm.getErrMsg();
	else{
		strTemp = "select edu_level from bed_level_info where g_level ="+(String)vBasicInfo.elementAt(14);
		strEduLevel = dbOP.getResultOfAQuery(strTemp, 0);
	
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("id_number"),strCurSYFrom,strCurSYTo,strCurSem);
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
		
		if(vBasicInfo.elementAt(7) == null)
			bolIsBasic = true;
		else{
			strErrMsg = "Only basic education student is allowed.";
			vBasicInfo = null;
		}
	}
	
	
	
}

 
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onLoad="FocusID();">
<form action="./parent_consent.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="2" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PARENT'S CONSENT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td width="2%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="98%" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">

<tr valign="top">
	<td width="2%" >&nbsp;</td>
	<td width="15%" >ID Number. :</td>
	<td>
		<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
	<label id="coa_info" style="width:400px; position:absolute"></label>	
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
			<%
			if(bolIsBasic)
				strTemp = dbOP.getBasicEducationLevelNew(Integer.parseInt((String)vBasicInfo.elementAt(14)));
			else
				strTemp = (String)vBasicInfo.elementAt(14);
			%>
			<td height="25" ><%=WI.getStrValue(strTemp,"N/A")%></td>
		</tr>
	<%if(!bolIsBasic){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major</td>
			<td colspan="2" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
	  </tr>
	 <%}%>
	</table>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>		
		<td width="42%" align="right"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>		</td>
	</tr>
</table>





<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td height="10" colspan="9">&nbsp;</td></tr>
<tr><td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td></tr>
</table>

	<input type="hidden" name="search_" value="" />
	<input type="hidden" name="edu_level" value="<%=strEduLevel%>">
	<input type="hidden" name="print_page" >

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
