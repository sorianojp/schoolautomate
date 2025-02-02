<%@ page language="java" import="utility.*,enrollment.Authentication,java.util.Vector,java.util.StringTokenizer" buffer="16kb"%>
<%
//System.out.println("User index in session from profile page. : "+request.getSession(false).getAttribute("userIndex"));
//System.out.println("Prev ID. : "+request.getSession(false).getCreationTime());
//String strSchCode2 = (String)request.getSession(false).getAttribute("school_code");
///added code for HR/companies.
///added code for HR/companies.
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>
<script language="JavaScript">
function ViewInfo()
{
	document.staff_profile.page_action.value="0";
}
function AddRecord()
{
	document.staff_profile.page_action.value="1";
}
function EditRecord()
{
	document.staff_profile.page_action.value="2";
}
function DeleteRecord()
{
	document.staff_profile.page_action.value="3";
}
function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.staff_profile.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.staff_profile.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		hideLayer(strTextBoxID);
		eval('document.staff_profile.'+strOthFieldName+'.disabled=true');
	}
}
function OpenSearch() {
	var pgLoc = "../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddMoreCollege() {
	if(document.staff_profile.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "./profile_add_more.jsp?emp_id="+escape(document.staff_profile.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	if(document.staff_profile.fname)
		document.staff_profile.fname.focus();
	else	
		document.staff_profile.emp_id.focus();
}


///ajax here to load major..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.staff_profile.c_index[document.staff_profile.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	//return;
		var strCompleteName = document.staff_profile.emp_id.value;
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.staff_profile.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.ViewInfo();
	document.staff_profile.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = "";
	String strTemp   = null;
	String strTemp2  = null;

	String strImgFileExt = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-User Management","profile.jsp");

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
														"System Administration","User Management",request.getRemoteAddr(),
														null);
if(iAccessLevel ==0) {//not allowed
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"profile.jsp");

}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Authentication auth = new Authentication();
Vector vRetResult = new Vector();
String strInfoIndex = "";
boolean bolFatalErr = false;

request.setAttribute("inc_nonemployee", "1");
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolShowNonEmployeeSetting = false;

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("0") ==0)
{
	vRetResult = auth.operateOnBasicInfo(dbOP, request,"0");
	if(vRetResult == null) {
		strErrMsg = auth.getErrMsg();bolFatalErr= true;
	}
	else
		strInfoIndex = (String)vRetResult.elementAt(0);
}
else if(strTemp.compareTo("1") == 0)//add
{
	if(auth.operateOnBasicInfo(dbOP, request,"1") == null)
	{strErrMsg = auth.getErrMsg();bolFatalErr = true;}
	else
		strErrMsg = auth.getErrMsg();
}
else if(strTemp.compareTo("2") == 0)//edit
{
	if(auth.operateOnBasicInfo(dbOP, request,"2") == null)
	{strErrMsg = auth.getErrMsg();bolFatalErr = true;strInfoIndex=request.getParameter("info_index");}
	else
		strErrMsg = "Staff information edited successfully.";
}
else if(strTemp.compareTo("3") == 0)//delete
{
	if(auth.operateOnBasicInfo(dbOP, request,"3") == null)
	{strErrMsg = auth.getErrMsg();bolFatalErr= true;strInfoIndex=request.getParameter("info_index");}
	else
		strErrMsg = "Staff removed from database.";
}
//added to set the employee as non-employee.. 
if(strSchCode.startsWith("CIT"))
	bolShowNonEmployeeSetting = true;
else {
	strTemp = "select prop_val from read_property_file where prop_name = 'ENABLE_NON_EMPLOYEE_SETTING'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("0"))
		bolShowNonEmployeeSetting = true;
}

if(bolShowNonEmployeeSetting) {
	if(!bolFatalErr && (strTemp.equals("1") || strTemp.equals("2"))) {
		boolean bolSetNonEmployee = false;
		if(strTemp.equals("1")) {//added..
			//if cit, i have to check if NAS, if not cit, check the field is_non_employee
			if(strSchCode.startsWith("CIT")) {
				strTemp = "select emp_type_name from user_table "+
					"join info_faculty_basic on (info_faculty_basic.user_index = user_table.user_index) "+
					"join HR_EMPLOYMENT_TYPE on (HR_EMPLOYMENT_TYPE.EMP_TYPE_INDEX = info_faculty_basic.EMP_TYPE_INDEX) "+
					"where id_number = '"+WI.fillTextValue("emp_id")+"'";
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				//System.out.println(strTemp);
				if(strTemp != null && strTemp.equals("NAS"))
					bolSetNonEmployee = true; 
			}
			else if(WI.fillTextValue("is_non_employee").length() > 0) 
				bolSetNonEmployee = true;
			
			if(bolSetNonEmployee) {
				strTemp = "update user_table set is_valid = 2 where id_number = '"+WI.fillTextValue("emp_id")+"'";
				dbOP.executeUpdateWithTrans(strTemp,null,null,false);
				dbOP.commitOP();
			}
		}
		else {//edit.
			if(strSchCode.startsWith("CIT")) {
				strTemp = "select emp_type_name from user_table "+
					"join info_faculty_basic on (info_faculty_basic.user_index = user_table.user_index) "+
					"join HR_EMPLOYMENT_TYPE on (HR_EMPLOYMENT_TYPE.EMP_TYPE_INDEX = info_faculty_basic.EMP_TYPE_INDEX) "+
					"where id_number = '"+WI.fillTextValue("emp_id")+"'";
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				//System.out.println(strTemp);
				if(strTemp != null && strTemp.equals("NAS"))
					bolSetNonEmployee = true; 
			}
			else if(WI.fillTextValue("is_non_employee").length() > 0) 
				bolSetNonEmployee = true;
			
			if(bolSetNonEmployee)
				strTemp = "update user_table set is_valid = 2 where id_number = '"+WI.fillTextValue("emp_id")+"'";
			else {
				strTemp = "select is_valid from user_table where id_number = '"+WI.fillTextValue("emp_id")+"'";
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				if(strTemp != null && strTemp.equals("2"))
					strTemp = "update user_table set is_valid = 1 where id_number = '"+WI.fillTextValue("emp_id")+"'";
				else
					strTemp = null;
			}
			if(strTemp != null) {
				dbOP.executeUpdateWithTrans(strTemp,null,null,false);
				dbOP.commitOP();
			}
		}
	}
}

if(strSchCode.startsWith("CIT")) //do not show option.
	bolShowNonEmployeeSetting = false;
	
if(request.getParameter("reloadPage") != null && request.getParameter("reloadPage").compareTo("1") ==0)
{
	//reload page is called, so keep the pervious values
	bolFatalErr = true;
	vRetResult  = null;
}
if(strErrMsg == null) 
	strErrMsg = "";


%>

<form action="./profile.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROFILE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="32%">Login ID<font size="1">&nbsp;(Employee or Student ID)</font></td>
      <td width="21%"><input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">      </td>
      <td width="45%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" border="0"></a><font size="1">click to search 
	  
	  <input type="checkbox" name="new_" value="checked" <%=WI.fillTextValue("new_")%> onClick="document.staff_profile.submit();">Auto create Employee ID (for new ID)
	  <br>
<%
boolean bolResetYear = false;
if(strSchCode.startsWith("WNU"))
	bolResetYear = true;
else	
	bolResetYear = false;
%>
	  <b>ID Format is : YYxxx-XXXX - YY - 2 digit year, xxx - Security code, XXXX - counter <%if(bolResetYear){%> (Every year counter will be reset)<%}%></b>
	  </font>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="right"><input name="image" type="image"  onClick="ViewInfo();" src="../../images/form_proceed.gif"></td>
      <td colspan="2"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(WI.fillTextValue("emp_id").length() > 0 || WI.fillTextValue("new_").length() > 0){%>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td valign="bottom" align="right" width="16%">&nbsp; </td>
      <td valign="bottom" align="right"> 
        <%strTemp = "<img border=1 src=\"../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
        <%=strTemp%></td>
      <td width="7%" valign="bottom">&nbsp; </td>
    </tr>
<%if(strSchCode.startsWith("CIT")){
	strTemp = "select is_valid from user_table where id_number = '"+WI.fillTextValue("emp_id")+"'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("2")) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td></td>
		  <td colspan="3"><font style="font-size: 22px; color:#FF0000">User already set as Non-Employee</font></td>
		</tr>
	<%}
}%>

<%if(bolShowNonEmployeeSetting){
	strTemp = "select is_valid from user_table where id_number = '"+WI.fillTextValue("emp_id")+"'";
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp != null && strTemp.equals("2"))
		strTemp = " checked";
	else	
		strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px; color:#0000FF">Set as Non-Employee </td>
      <td colspan="3" style="font-weight:bold; font-size:11px; color:#0000FF"><input type="checkbox" name="is_non_employee" value="1" <%=strTemp%>> Is Non-Employee
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  
	  <%if(strTemp.length() > 0) {%>
	  	<font style="font-size: 22px; color:#FF0000; font-weight:normal">User already set as Non-Employee</font>
	  <%}%>
	  
	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom"><font size="1">First name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Middle 
        name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last 
        name</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Name</td>
      <td colspan="3"> <%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(1);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("fname");

%> <input type="text" name="fname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(2);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("mname");

%> <input type="text" name="mname" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(3);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("lname");

%> <input type="text" name="lname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Gender</td>
      <td colspan="3"> <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(4);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("gender");

%> <select name="gender">
          <option value="0">Male</option>
          <%
if(strTemp.compareTo("1") == 0)
{%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Birth</td>
      <td> <%
	String strDDMMYYYY = "";
	if(vRetResult != null && vRetResult.size() > 0)
		strDDMMYYYY = WI.getStrValue(vRetResult.elementAt(5), "");
	else if(bolFatalErr)
		strDDMMYYYY = WI.fillTextValue("dob");
%> <input name="dob" type="text" size="12" maxlength="12" value="<%=strDDMMYYYY%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		 onKeyUp="AllowOnlyIntegerExtn('staff_profile','dob','/');">      </td>
      <td colspan="2"><a href="javascript:show_calendar('staff_profile.dob',
	  <%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (mm/dd/yyyy)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="2">Date of Employment</font></td>
      <td> 
        <%
	strDDMMYYYY = "";
	if(vRetResult != null && vRetResult.size() > 0)
		strDDMMYYYY = WI.getStrValue(vRetResult.elementAt(6), "");
	else if(bolFatalErr)
		strDDMMYYYY = WI.fillTextValue("doe");
%>
        <input name="doe" type="text" size="12" maxlength="12" value="<%=strDDMMYYYY%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td colspan="2"><a href="javascript:show_calendar('staff_profile.doe');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (mm/dd/yyyy)</td>
    </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25">End of Contract</td>
            <td height="25" colspan="3">
<%	
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(27), "");
else if (bolFatalErr) 
	strTemp = WI.fillTextValue("dol");
else  strTemp = "";
%> 
	<input name="dol" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('staff_profile.dol');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
              (mm/dd/yyy)</font>
			<font style="font-weight:bold; color:#0000FF; font-size:10px;">
			(In case contract is not renewed, employee is considered as separated after specified date)			</font>			</td>
          </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Contact Nos.</td>
      <td height="25" colspan="3"><font size="1"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(7);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("tel_no");

%>
        <input name="tel_no" type="text" size="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Address</td>
      <td colspan="3"> <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(8);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("address");

%>
        <textarea name="address" cols="65" rows="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>      </td>
    </tr>
    <tr> 
      <td  colspan="5"height="25"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Emp. Type/Position</td>
      <td width="78%">
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp2 = (String)vRetResult.elementAt(9);
else if(bolFatalErr)
	strTemp2 = WI.fillTextValue("emp_type");

%>
        <select name="emp_type" onChange='ShowHideOthers("emp_type","oth_emp_type","emp_type_");'>
          <option value="0">Others(Pl specify)</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
        </select>
        <%
strTemp = WI.fillTextValue("reloadPage");
if(strTemp.compareTo("1") ==0)
	strTemp = WI.fillTextValue("oth_emp_type");
else strTemp = "";
%>
        <input name="oth_emp_type" type="text" size="16" value="<%=WI.getStrValue(strTemp)%>" id="emp_type_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%
if(strTemp2 != null && strTemp2.compareTo("0") != 0){%>
<script language="JavaScript">
ShowHideOthers("emp_type","oth_emp_type","emp_type_");
</script>
<%}%>
	 </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Emp. Tenureship </td>
      <td height="25"><strong>
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp2 = (String)vRetResult.elementAt(10);
else if(bolFatalErr)
	strTemp2 = WI.fillTextValue("status");

%>
        <select name="status" onChange='ShowHideOthers("status","oth_status","status_");'>
          <option value="0">Others(Pl specify)</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp2, false)%>
        </select>
        <%
strTemp = WI.fillTextValue("reloadPage");
if(strTemp.compareTo("1") ==0)
	strTemp = WI.fillTextValue("oth_status");
else strTemp = "";
%>
        <input name="oth_status" type="text" size="16" value="<%=strTemp%>" id="status_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </strong></td>
<%
if(strTemp2 != null && strTemp2.compareTo("0") != 0){%>
<script language="JavaScript">
ShowHideOthers("status","oth_status","status_");
</script>
<%}%>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="0">N/A</option>
          <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(11);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select>
		<%if(strInfoIndex != null && strInfoIndex.length() > 0 && bolIsSchool) {%>
        <a href="javascript:AddMoreCollege();"><img src="../../images/update.gif" border="0"></a> 
		<font size="1">click to add college assigned to</font><%}%>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25">
<label id="load_dept">
<%
String strTemp3 = null;
if(strTemp.compareTo("0") ==0 && false) //only if non college show others.
	strTemp2 = " onChange='ShowHideOthers(\"d_index\",\"oth_dept\",\"dept_\");'";
else
	strTemp2 = "";
%>
	  <select name="d_index" <%=strTemp2%>>
<%
if(strTemp.compareTo("0") ==0 && false){//only if from non college.%>
          <option value="0">Others(Pl specify)</option>
<%}else{%>
          <option value="">All</option>
<%}
strTemp3 = "";
if(vRetResult != null && vRetResult.size() > 0)
	strTemp3 = (String)vRetResult.elementAt(12);
else if(bolFatalErr)
	strTemp3 = WI.fillTextValue("d_index");

if(strTemp.length() == 0 || strTemp.equals("0"))
	strTemp = " (c_index is null or c_index = 0) ";
else	
 	strTemp = " c_index = "+strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and "+strTemp+" order by d_name asc",strTemp3, false)%>
        </select>
</label>

<%
strTemp2 = WI.fillTextValue("reloadPage");
if(strTemp2.compareTo("1") ==0)
	strTemp2 = WI.fillTextValue("oth_dept");
else strTemp2 = "";

if(strTemp.compareTo("0") ==0 && false){%>
			 <input type="text" name="oth_dept" value="<%=WI.getStrValue(strTemp2)%>" id="dept_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">

        <%}
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(11);
else if(bolFatalErr)
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";

if(strTemp.compareTo("0") ==0 && strTemp3 != null && strTemp3.compareTo("0") != 0 && strTemp.length() > 0){%>
        <script language="JavaScript">
//ShowHideOthers("d_index","oth_dept","dept_");
</script>
        <%}%>
      </td>
    </tr>
<%
if( iAccessLevel >1){%>
   <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">
        <%if(strInfoIndex.trim().length() > 0){%>
        <input type="image"  onClick="EditRecord();" src="../../images/edit.gif">
        <font size="1">Click to edit personal information </font>(OR)
        <%
		if(iAccessLevel ==2){%>
		<!--<input name="image" type="image"  onClick="DeleteRecord();" src="../../images/delete.gif">
        <font size="1">Click to delete staff from database</font>-->
		<%}else{%>No delete privilege<%}%>
		 <a href="./profile.jsp"><img src="../../images/cancel.gif" border="0"></a><font size="1">click
        to cancel and clear entries</font>
        <%}else{%>
        <input type="image" src="../../images/save.gif" onClick="AddRecord();">
        <font size="1">click to save entries</font>
        <%}%>
      </td>
    </tr>
<%}

}//only if user Id is entered.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="my_home" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
