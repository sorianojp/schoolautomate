<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Summary per Department/College</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
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
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function SearchEmployee(){
	document.form_.print_page.value = "";
	document.form_.view_all.value = '1';
	document.form_.submit();
}
function FocusID() {
	document.form_.emp_id.focus();
}

function ViewPrintDetails(strEmpID, strYear,strYearTo,strSemester,strBenefitIndex){
	var pgLoc = "../leave/leave_apply.jsp?view_only=1&emp_id="+ strEmpID  +
		"&sy_from="+strYear+"&sy_to="+strYearTo+"&semester="+strSemester+"&benefit_index=" + strBenefitIndex;
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}
 
function PrintPg() {
	document.form_.print_page.value = 1;
	document.form_.submit();
}

///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

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
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Exception","must_work.jsp");
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
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"must_work.jsp");
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

HRInfoLeave hil = new HRInfoLeave();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(hil.operateOnMandatoryWorkDay(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hil.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = hil.operateOnMandatoryWorkDay(dbOP, request, 4);
if(strErrMsg == null && vRetResult == null)
	strErrMsg = hil.getErrMsg();


%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./must_work.jsp" method="post" name="form_">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: HR : EMPLOYEE LEAVE EXCEPTION ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" style="font-size:14px; color:#FF0000">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="15%" height="25">&nbsp;Employee ID</td>
      <td width="16%">
			<input name="emp_id"  type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16" 
			maxlength="32" onKeyUp="AjaxMapName();"></td>
      <td width="8%" style="font-size:9px;"><a href="#"><img src="../../../images/view.gif" border="0" onClick="document.form_.page_action.value='';document.form_.submit();"></a>View list</td>
      <td width="61%"><label id="coa_info" style="position:absolute;width:350px;"></label>	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;Date of Exception</td>
      <td>
	<input name="work_date" type= "text" class="textbox"  value="<%=WI.fillTextValue("work_date")%>" size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';">  
	<a href="javascript:show_calendar('form_.work_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	  </td>
      <td colspan="2"><input type="button" name="proceed_btn" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.submit();"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="21" colspan="5" align="center"><strong>SUMMARY OF LEAVE </strong></td>
		</tr>
	</table>
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr>
			<td width="20%" height="25" class="thinborder">Date of Exception</td>
			<td width="50%" align="center" class="thinborder">Reason</td>
			<td width="15%" align="center" class="thinborder">Delete</td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 3){%>
		<tr>
			<td width="20%" height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
			<td width="50%" align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
			<td width="15%" align="center" class="thinborder">
			<input type="button" name="_btn" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>';document.form_.submit();">
			</td>
		</tr>
	<%}%>
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

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
