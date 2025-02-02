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

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;

	document.form_.page_action.value = strAction;
	document.form_.print_page.value="";
	document.form_.submit();
}

function Search()
{
	document.form_.print_page.value="";
	document.form_.search_.value = "1";
	document.form_.submit();
}

function RefreshPage(){
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "0";
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PrintPg(strInfoIndex){	
	var pgLoc = "./dental_certificate_print.jsp?info_index="+strInfoIndex+"&report_type="+document.form_.report_type.value+
		"&id_number="+document.form_.id_number.value+"&print_page=1";			
	var win=window.open(pgLoc,"PrintPg",'width=1000,height=550,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value = "";
	document.form_.page_action.value="";
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
	
	String strReportType = WI.fillTextValue("report_type");
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./dental_certificate_print.jsp" />

	<%return;}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Report","dental_certificate.jsp");
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
														"dental_certificate.jsp");
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

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
HealthExamination HE = new HealthExamination();

Vector vRetResult = null;
Vector vEditInfo = null;

if(WI.fillTextValue("id_number").length() > 0) {	
	strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("id_number"));
	if(strTemp == null)
		strErrMsg = "ID number does not exist or is invalidated.";
}


if(strTemp != null){	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(HE.operateOnDentalMedicalExamination(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = HE.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Dental result successfully added.";

			if(strTemp.equals("2"))
				strErrMsg = "Dental result successfully updated.";

			if(strTemp.equals("0"))
				strErrMsg = "Dental result successfully deleted.";

			
			strPrepareToEdit = "0";
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
			
		vRetResult = HE.operateOnDentalMedicalExamination(dbOP, request, 5);		
		
		
		if(strPrepareToEdit.equals("1")){
			vEditInfo = HE.operateOnDentalMedicalExamination(dbOP, request, 3);
			if(vEditInfo == null)
				strErrMsg = HE.getErrMsg();
		}
	}
	
	
	
}

 
%>
<body bgcolor="#8C9AAA" class="bgDynamic" onLoad="FocusID();">
<form action="dental_certificate.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
	<%
	if(WI.fillTextValue("report_type").equals("2"))
		strTemp = "DENTAL CERTIFICATE";
	if(WI.fillTextValue("report_type").equals("3"))
		strTemp = "MEDICAL CERTIFICATE";
	if(WI.fillTextValue("report_type").equals("4"))
		strTemp = "EXCUSE SLIP";
	%>
      <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%=strTemp%> ::::</strong></font></div></td>
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
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="5"></td></tr>
	<tr>
		<td height="22" width="2%"></td>
		<td width="17%">Treated from </td>
		<td>
		<font size="1">
<%
strTemp = WI.fillTextValue("treated_from");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
%>
        <input name="treated_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.treated_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>        </font>		</td>
	</tr>
	<%if(WI.fillTextValue("report_type").equals("2") || WI.fillTextValue("report_type").equals("3")){%>	
	<tr>
		<td height="22" width="2%"></td>
		<td width="17%">Treated to</td>
		<td>
		<font size="1">
<%
strTemp = WI.fillTextValue("treated_to");
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
%>
        <input name="treated_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.treated_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>        </font>		</td>
	</tr>	
	<%}%>
	<tr>
		<td height="22">&nbsp;</td>
		<td valign="top">Impression/Remarks:</td>
		<%
		strTemp = WI.fillTextValue("remarks");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		%>
		<td>
		<textarea name="remarks" rows="3" cols="50"class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>		</td>
	</tr>
	
	
	<tr>
	    <td height="22">&nbsp;</td>
		<%
		if(strReportType.equals("2"))
			strTemp = "School Dentist";
		else if(strReportType.equals("3"))
			strTemp = "School Physician";
		else
			strTemp = "School Nurse";
		%>
	    <td><%=strTemp%></td>
	    <td>
			<select name="school_physician_index" style="width:300px;" onChange="Search();">
				<option value="">Select <%=strTemp%></option>
				<%
				strTemp = " from HM_DENTAL_MEDICAL_EXAM where is_valid =1 and report_type = "+strReportType+
					" order by school_physician ";
					
				
				strErrMsg = WI.fillTextValue("school_physician_index");
				if(vEditInfo != null && vEditInfo.size() > 0)
					strErrMsg = (String)vEditInfo.elementAt(13);
				%>
				<%=dbOP.loadCombo("distinct school_physician","school_physician",strTemp,strErrMsg,false)%>
			</select>
			
			<input name="school_physician" type="text" size="40" maxlength="256" value="" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
	    </tr>
	<tr>
	    <td height="22">&nbsp;</td>
	    <td>License No.</td>
		<%
		strTemp = WI.fillTextValue("license_no");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);
			
		String strDisabled = "";
		if(WI.fillTextValue("school_physician_index").length()  >0){
			strErrMsg = "select distinct license_no from HM_DENTAL_MEDICAL_EXAM where is_valid =1  "+
				" and SCHOOL_PHYSICIAN = "+WI.getInsertValueForDB(WI.fillTextValue("school_physician_index"), true, null);
			strTemp = dbOP.getResultOfAQuery(strErrMsg,0 );
			
			strDisabled = "readonly";
		}
		%>
	    <td>
			<input name="license_no" type="text" size="40" <%=strDisabled%> maxlength="256" class="textbox" 
				value="<%=WI.getStrValue(strTemp)%>"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
</table>


<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="58%" align="center">
			<%if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>		
			<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update entry</font>		
			<%}%>
			
			<a href="javascript:RefreshPage();"><img src="../../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to refresh page</font>		
		</td>		
		
	</tr>
</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td class="thinborder" height="22" width="20%" align="center"><strong>TREATED FROM</strong></td>
		<%if(WI.fillTextValue("report_type").equals("2") || WI.fillTextValue("report_type").equals("3")){%>	
		<td class="thinborder" width="20%" align="center"><strong>TREATED TO</strong></td>
		<%}if(!WI.fillTextValue("report_type").equals("2")){%>
		<td class="thinborder" align="center"><strong>REMARKS</strong></td>
		<%}%>
		<td class="thinborder" width="20%" align="center"><strong>OPTION</strong></td>
	</tr>
	
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=15 ){
	%>
	<tr>
		<td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+7)%></td>
		<%if(WI.fillTextValue("report_type").equals("2") || WI.fillTextValue("report_type").equals("3")){%>	
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
		<%}if(!WI.fillTextValue("report_type").equals("2")){%>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
		<%}%>
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+12)%>');"><img src="../../../../images/edit.gif" border="0"></a>
			&nbsp; 
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i+12)%>');"><img src="../../../../images/delete.gif" border="0"></a>
			&nbsp; 
			<a href="javascript:PrintPg('<%=(String)vRetResult.elementAt(i+12)%>');"><img src="../../../../images/print.gif" border="0"></a>
		
		</td>	
	</tr>
	<%}%>
</table>


<%}%>



<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
<tr><td height="10" colspan="9">&nbsp;</td></tr>
<tr><td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td></tr>
</table>

	<input type="hidden" name="search_" value="" />	
	<input type="hidden" name="page_action" value="" >
	<input type="hidden" name="print_page" >
	<input type="hidden" name="report_type" value="<%=strReportType%>">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" >
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
