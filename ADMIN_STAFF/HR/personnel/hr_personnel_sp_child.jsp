<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoDependent"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function viewInfo(){
	document.form_.prepareToEdit.value = "";	
	document.form_.page_action.value = "";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}

function FocusID() {
	<% if (!WI.fillTextValue("my_home").equals("1")){%> 
		document.form_.emp_id.focus();
	<%}%>
}
function UpdateAge(){
var	strDateToday = "<%=WI.getTodaysDate(1)%>";
	document.form_.age.value = 
		calculateAge(document.form_.dob.value,strDateToday,true);
}

function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	this.SubmitOnce("form_");
}
function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = "1";
	document.form_.showDB.value = "1";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value ="0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./hr_personnel_sp_child.jsp?emp_id="+document.form_.emp_id.value+"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<%
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
	
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

		boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-dependent","hr_personnel_sp_child.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact dbase admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_sp_child.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
Vector vRetResult = null;
Vector vEditInfo  = null;
Vector vEmpRec = null;
boolean bolNoError = false;

HRInfoDependent hrDep = new HRInfoDependent();

if(WI.fillTextValue("page_action").compareTo("0") == 0){
	if (hrDep.operateOnSpChild(dbOP,request,0) != null){
		strErrMsg = " Information removed successfully";
		strPrepareToEdit = "";
	}else
		strErrMsg = hrDep.getErrMsg();
}else if (WI.fillTextValue("page_action").compareTo("1") == 0){
	if (hrDep.operateOnSpChild(dbOP,request,1) != null)
		strErrMsg = " Information recorded successfully";
	else
		strErrMsg = hrDep.getErrMsg();
}else if (WI.fillTextValue("page_action").compareTo("2") == 0){	
	if (hrDep.operateOnSpChild(dbOP,request,2) != null){
		strErrMsg = " Information updated successfully";
		strPrepareToEdit = "";
	}else
		strErrMsg = hrDep.getErrMsg();
}

if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrDep.operateOnSpChild(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = hrDep.getErrMsg();
}
	

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}

if(strTemp.length() > 0) {
	vRetResult = hrDep.operateOnSpChild(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null ) 
		strErrMsg = hrDep.getErrMsg();
	//System.out.println(vRetResult);
}

if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vEditInfo != null && vEditInfo.size() > 0))  bolNoError = false;
	else bolNoError = true;

String[] astrRelationship ={"Spouse","Child","Brother", "Sister","Parent"};
String[] astrGender ={"Male","Female","&nbsp;"};
%>

<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="hr_personnel_sp_child.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SPOUSE / CHILDREN'S RECORD ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	    <label id="coa_info"></label>
		 </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
  <% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="3">
    <tr> 
      <td width="100%"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br> 
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="4" align="right"><font size="1">Note 
              : Items mark with <font color="#FF0000">*</font> are required 
              items.&nbsp;&nbsp;</font></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">&nbsp;</td>
            <% if (!bolNoError) strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(12));
				else strTemp2 = WI.fillTextValue("emp_id2"); 
				if (WI.fillTextValue("same_comp").length() > 0) strTemp  = "checked";
					else strTemp = "";
				if (!bolNoError && WI.getStrValue((String)vEditInfo.elementAt(12)).length()> 0)  
					strTemp= "checked";
			%>
            <td height="25" colspan="2"><input type="checkbox" name="same_comp" value="1" onClick="viewInfo()" <%=strTemp%>>
              If working in same 
			  <% if (!bolIsSchool) {%>
			  company<%}else{%>school <%}%>  (please check)</td>
          </tr>
          <% if (strTemp.length() > 0) {%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2">Employee ID<font color="#FF0000">*</font></td>
            <td width="21%" height="25"> <input name="emp_id2" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
			onblur="style.backgroundColor='white'" value="<%=strTemp2%>" size="16">            </td>
            <td width="61%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
          </tr>
          <%}else{%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom"><font size="1">First name<font color="#FF0000"><strong>*</strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#000000">Middle 
              name&nbsp;&nbsp;&nbsp;</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font color="#FF0000">&nbsp;</font></strong>Last 
              name<font color="#FF0000">*</font></font></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2">Name</td>
            <td height="25" colspan="2"> <% if (!bolNoError) strTemp2 = (String)vEditInfo.elementAt(4);
		else strTemp2 = WI.fillTextValue("fname");%> <input name="fname" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp2%>" size="20" maxlength="32"> 
              &nbsp;&nbsp; <% if (!bolNoError) strTemp2 = (String)vEditInfo.elementAt(5);
		else strTemp2 = WI.fillTextValue("mname");%> <input name="mname" type="text" class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp2)%>" size="20" maxlength="32"> 
              &nbsp;&nbsp; <% if (!bolNoError) strTemp2 = (String)vEditInfo.elementAt(6);
		else strTemp2 = WI.fillTextValue("lname");%> <input name="lname" type="text" class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp2%>" size="20" maxlength="32"></td>
          </tr>
          <%} // end strTemp.length()> 0%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2">Relationship<font color="#FF0000">*</font></td>
            <td height="25" colspan="2"> 
<% if (!bolNoError) 
strTemp3 = (String)vEditInfo.elementAt(2);
		else 
			strTemp3 = WI.fillTextValue("relationship");
		
		if (strTemp.length() !=0) strTemp2 = "";
		else strTemp2 = "onChange=\"ReloadPage()\"";
		%> <select name="relationship" <%=strTemp2%>>
                <option value="1">Child</option>
                <% if (strTemp3.compareTo("0")  == 0){%>
                <option value="0" selected>Spouse</option>
                <%}else{%>
                <option value="0">Spouse</option>
                <%}
				if (!strSchCode.startsWith("AUF")){
				  if (strTemp3.equals("2")) {  
				%>
				<option value="2" selected>Brother</option>
				<%}else{%> 
				<option value="2">Brother</option>				
                <%}if (strTemp3.equals("3")){%>
                <option value="3" selected>Sister</option>
                <%}else{%>
                <option value="3">Sister</option>
				<%}if (strTemp3.equals("4")){%>
                <option value="4" selected>Parent</option>
                <%}else{%>
                <option value="4">Parent</option>
				<%} // end if else
				} // show only in vmuf%>
              </select> </td>
          </tr>		  
          <% if (strTemp.length() == 0){ %>
		  <tr>
		  	<td height="25">&nbsp;</td>
            <td colspan="2">Religion</td>
            <td colspan="2">
				<%	
					if (!bolNoError)
						strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(15));
					else
						strTemp2 = WI.fillTextValue("religion");
				%>
				<select name="religion">
					<option value="">Select Religion</option>
					<%=dbOP.loadCombo("RELIGION_INDEX","RELIGION"," FROM HR_PRELOAD_RELIGION",strTemp2,false)%> 
				</select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Date of Birth<font color="#FF0000">*</font></td>
            <td height="25" colspan="2"> <% if (!bolNoError) strTemp2 = (String)vEditInfo.elementAt(7);
		else strTemp2 = WI.fillTextValue("dob");%> <input name="dob" type="text" size="10" maxlength="10" value="<%=WI.getStrValue(strTemp2)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAge();style.backgroundColor='white'" onKeyUP="AllowOnlyIntegerExtn('form_','dob','/');UpdateAge()"> 
              <a href="javascript:show_calendar('form_.dob',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
              (mm/dd/yyy)</font></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2">Age</td>
            <td height="25" colspan="2"> <input type="text" name="age" value="" class="textbox_noborder" readonly="yes">            </td>
          </tr>
          <script language="JavaScript">
		  this.UpdateAge();
		  </script>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2">Gender <font color="#FF0000">*</font></td>
            <td height="25" colspan="2"> <% if (!bolNoError) strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(8));
		else strTemp2 = WI.fillTextValue("gender");
		if (strTemp2.length() == 0){
			if(vEmpRec.elementAt(4) != null && ((String)vEmpRec.elementAt(4)).compareTo("0") == 0)
				strTemp2 =  "1";  else strTemp2 = "0";
		}
		%> <select name="gender">
				<% if (!strTemp3.equals("3")) {%> 
                <option value="0">Male</option>
                <%}
				if (!strTemp3.equals("2")) { 
					if(strTemp2.compareTo("1") == 0){%>
                <option value="1" selected>Female</option>
                <%}else{%>
                <option value="1">Female</option>
                <%}
				}%>
              </select></td>
          </tr>
	<%
		String strTempVal = WI.getStrValue(WI.fillTextValue("relationship"), "1");
		//if child and not same comp
		if(strTempVal.equals("1")){%>
		<tr>
            <td height="25">&nbsp;</td>
            <td colspan="2">Civil Status </td>
            <td colspan="2">
				<%
					if (!bolNoError)
						strTempVal = WI.getStrValue((String)vEditInfo.elementAt(17));
					else
						strTempVal = WI.fillTextValue("cstatus");
				%>
				<select name="cstatus">
                <option value="1">Single</option>
                <% if (strTempVal.compareTo("2") == 0) {%>
                <option value="2" selected>Married</option>
                <%}else{%>
                <option value="2">Married</option>
                <%} if (strTempVal.compareTo("3") == 0) {%>
                <option value="3" selected>Divorced/Separated</option>
                <%}else{%>
                <option value="3" >Divorced/Separated</option>
                <%} if (strTempVal.compareTo("4") == 0) {%>
                <option value="4" selected>Widow/Widower</option>
                <%}else{%>
                <option value="4" >Widow/Widower</option>
                <%}
			if(bolAUF){
				if (strTempVal.compareTo("5") == 0) {%>
                <option value="5" selected>Annuled</option>
                <%}else{%>
                <option value="5">Annuled</option>
                <%}if (strTempVal.compareTo("6") == 0) {%>
                <option value="6" selected>Living Together</option>
                <%}else{%>
                <option value="6">Living Together</option>
                <%}
			}%>
			</select></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td colspan="2">Occupation</td>
            <td colspan="2">
				<%
					if (!bolNoError)
						strTempVal = WI.getStrValue((String)vEditInfo.elementAt(16));
					else
						strTempVal = WI.fillTextValue("occupation");
				%>
				<input name="occupation" type="text" class="textbox" value="<%=strTempVal%>" size="64" maxlength="128"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>
	<%}
	
	if (strTemp3.compareTo("1")  != 0 && strTemp3.length()!= 0) {%>        
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="4"><u>Spouse Employment Information:</u>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td width="3%" height="25">&nbsp;</td>
            <td width="13%" height="25">Employer </td>
            <td height="25" colspan="2"> <% if (!bolNoError) strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(9));
		else strTemp2 = WI.fillTextValue("employer");%> <input name="employer" type="text"  size="64" maxlength="128" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp2%>"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25">Position</td>
            <td height="25" colspan="2"> <% if (!bolNoError) strTemp2 = (String)vEditInfo.elementAt(10);
		else strTemp2 = WI.fillTextValue("position");%> <input name="position" type="text" size="64" maxlength="128" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp2%>"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25">Emp. Status</td>
            <td height="25" colspan="2"><select name="status">
                <option value="">Select Status</option>
                <% if (!bolNoError) strTemp2 =(String)vEditInfo.elementAt(11);
				else strTemp2 = WI.fillTextValue("status");	%>
                <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp2, false)%> </select></td>
          </tr>
          <%} // do not show if relation is spouse
} // do not show if same_comp is checked%>
          <tr valign="bottom"> 
            <td width="2%" height="51">&nbsp;</td>
            <td height="51" colspan="4" align="center"> 
              <% if (iAccessLevel > 1){
			  	if (strPrepareToEdit.compareTo("1") != 0){%>
					<a href='javascript:AddRecord();'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
              <font size="1">click to save entries</font> 
              <%}else{ %>              <a href='javascript:EditRecord();'><img src="../../../images/edit.gif" border="0"></a> 
              <font size="1">click to save changes</font> 
              <%}
}%>              <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> </td>
          </tr>
        </table>
        <% if (vRetResult != null && vRetResult.size() > 0) {%> 

<table width="100%" border="0" celslpadding="3" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableColumn">
    <tr>
      <td colspan="9"><!--<div align="right"><img src="../../../images/print.gif"  border="0"><font size="1">click 
          to print list of dependents</font></div> --> &nbsp;</td>
      </tr>
 </table>

		<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr> 
            <td height="25" colspan="9" align="center" bgcolor="#768580"  class="thinborder"><strong><font color="#FFFFFF">SUMMARY 
              OF SPOUSE / CHILDREN'S DATA</font></strong></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="17%" class="thinborder"><font size="1"><strong> NAME</strong></font></td>
			<td width="9%" align="center"  class="thinborder"><font size="1"><strong>RELATION</strong></font></td>
			<td width="9%" align="center" class="thinborder"><font size="1"><strong>DATE OF 
			  BIRTH</strong></font></td>
			<td width="6%" align="center" class="thinborder"><strong><font size="1">AGE</font></strong></td>
            <td width="7%" class="thinborder"><font size="1"><strong>GENDER</strong></font></td>
            <td width="20%" align="center" class="thinborder"><font size="1"><strong>EMPLOYER</strong></font></td>
            <td width="10%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
            <td width="7%" align="center" class="thinborder"><font size="1"><strong>EMP. STATUS</strong></font></td>
            <td width="15%"  class="thinborder"><font size="1"><b>OPTIONS</b></font></td>
          </tr>
          <%  for (int i = 0; i < vRetResult.size(); i +=18){
		  	strTemp = (String)vRetResult.elementAt(i+9);
			if (strTemp != null && strTemp.compareTo("0") == 0) 
				strTemp = SchoolInformation.getSchoolName(dbOP,false,false);
		  %>
          <tr> 
            <td bgcolor="#FFFFFF"  class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),
																   (String)vRetResult.elementAt(i+6),4)%></font></td><td  class="thinborder"><font size="1"><%=astrRelationship[Integer.parseInt((String)vRetResult.elementAt(i+2))]%></font></td>
            <td align="center"  class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
            <td align="center"  class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></td>
            <td align="center"  class="thinborder" ><font size="1"><%=astrGender[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+8),"2"))]%></font></td>
            <td width="20%"  class="thinborder" ><font size="1"><%=WI.getStrValue(strTemp,"&nbsp;")%></font></td>
            <td width="10%"  class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></font></td>
            <td width="7%"  class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+14),"&nbsp;")%></font></td>
            <td bgcolor="#FFFFFF"  class="thinborder">&nbsp;<% if (iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'> 
			
			<% if (iAccessLevel == 2) {%>
              <img src="../../../images/edit.gif" border="0"></a><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a> 
              <%} // if iAccessLevel == 2
			  }%> </td>
          </tr>
          <% } // end for loop %>
        </table>
        <%}%> </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="showDB" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
