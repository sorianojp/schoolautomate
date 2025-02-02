<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
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
<title>Untitled Document</title>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function FocusID() {
	document.form_.emp_id.focus();
}

function ViewPrintDetails(strEmpID, strYear,strYearTo,strSemester,strLeaveIndex){
	var pgLoc = "./leave_apply.jsp?view_only=1&emp_id="+ strEmpID  +
		"&sy_from="+strYear+"&sy_to="+strYearTo+"&semester="+strSemester+"&avail_leave_index=" + strLeaveIndex;
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
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
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
 	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;
	boolean bolUseYearly = true;
	String strLeaveScheduler = null;

//add security here.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_summary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strLeaveScheduler = readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0");
		bolUseYearly = strLeaveScheduler.equals("0");
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
														"leave_summary.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, allow applying leave.
		//if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		//else 
		//	iAccessLevel = 1;

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
Vector vEmpRec = null; 

HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}


if (strTemp.length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
}

//if Emp ID is empty. I have to get it from session.getAttribute("encoding_in_progress_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	
strTemp = WI.getStrValue(strTemp);
 
 if (WI.fillTextValue("view_all").equals("1")) {
	vRetResult = hrPx.getLeaveSummary(dbOP, request);
 
	if (vRetResult == null){
		strErrMsg = hrPx.getErrMsg();
	}
 }
 
 
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./leave_summary.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
        HR : LEAVE SUMMARY ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <% if (!bolMyHome) {%>
    <tr> 
      <td width="31%" height="25">&nbsp;&nbsp;Employee ID : 
        <input name="emp_id"  type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="16" 
				maxlength="32" onKeyUp="AjaxMapName(1);">
		
		</td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="63%"><input type="image" src="../../../images/form_proceed.gif" border="0"> <label id="coa_info"></label>
      </td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;Employee ID : <font size="3" color="#FF0000"><strong><%=WI.getStrValue(strTemp)%></strong></font> <input name="emp_id" type= "hidden" class="textbox" value="<%=WI.getStrValue(strTemp)%>">
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <input name="image" type="image" src="../../../images/form_proceed.gif" border="0"> 
      </td>
    </tr>
    <%}%>
		<%
		if(strLeaveScheduler.equals("0") || strLeaveScheduler.equals("2") || strLeaveScheduler.equals("3")){%>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%if(bolIsSchool){%>SY / SEM<%}else{%>Year<%}%>&nbsp;: 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) {
	if(!bolIsSchool) 
		strTemp = WI.getTodaysDate().substring(0,4);
	else	
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
}
%> <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="DisplaySYTo('form_', 'sy_from', 'sy_to')"> 

	<%
	strSYTo = WI.fillTextValue("sy_to");
	if(strSYTo.length() ==0)
		strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>

<%if(bolIsSchool){%>
        - &nbsp; <input name="sy_to" type= "text" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" size="4" maxlength="4" 
		onBlur="style.backgroundColor='white'"  value="<%=strSYTo%>" readonly="yes"> 
        &nbsp;&nbsp; <select name="semester">
          <option value="1"> 1st Sem</option>
	<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
		if (strTemp.equals("2")) {
	%>
          <option value="2" selected> 2nd Sem</option>
          <%}else{%>
          <option value="2"> 2nd Sem</option>
          <%} if ( strTemp.equals("3")){%>
          <option value="3" selected> 3rd Sem</option>
          <%}else{%>
          <option value="3"> 3rd Sem</option>
          <%}if ( strTemp.equals("0")){%>
          <option value="0" selected> Summer</option>
          <%}else{%>
          <option value="0"> Summer</option>
          <%}%>
        </select> 
<%}else{///for companies.%>
<input type="hidden" name="sy_to" value="<%=strTemp%>">
<input type="hidden" name="semester" value="1">
<%}%>
		</td>
    </tr>
		<%}else{%>
		<%
		strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() == 0) {
			if(bolIsSchool)
				strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
			else
				strTemp = WI.getTodaysDate(12);
		}
		%>
		<input name="sy_from" type= "hidden" class="textbox" value="<%=WI.getStrValue(strTemp)%>">
		<input type="hidden" name="sy_to" value="<%=strTemp%>">
		<input type="hidden" name="semester" value="1">	
 		<%}%>
  </table>
<%  if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0
		&& WI.fillTextValue("sy_from").length() != 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%" height="25">  
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%> <%=strTemp%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=strTemp%></strong><br> <font size="1"><%=strTemp2%></font><br> <font size="1"><%=strTemp3%></font><br> </td>
          </tr>
        </table>
        <br>
		<br> <% if (vRetResult != null && vRetResult.size() > 0) {%> 
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td height="21" colspan="4" align="center" bgcolor="#F2EDE6" class="thinborder"><strong>SUMMARY OF LEAVE </strong></td>
          </tr>
          <tr> 
            <td width="31%" height="25" class="thinborder"><strong> &nbsp;Type 
              of Leave</strong></td>
            <td width="28%" class="thinborder"><strong>&nbsp;&nbsp;Available Leave </strong></td>
            <td width="25%" class="thinborder"><strong>&nbsp; Consumed Leave </strong></td>
            <td width="16%" align="center" class="thinborder"><strong>View 
                / Print</strong></td>
          </tr>
          <% for (int i =0 ; i < vRetResult.size() ; i+=11) {%>
          <tr> 
           <td height="25" class="thinborder">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
           <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> </td>
           <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
           <td align="center" class="thinborder">&nbsp;
<%//	if(!((String)vRetResult.elementAt(i+4)).equals("0.00")){%> 
		   <a href="javascript:ViewPrintDetails('<%=(String)vRetResult.elementAt(i+5)%>','<%=strSYFrom%>','<%=strSYTo%>','<%=strSemester%>','<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
<%//}%> 		   
		   
		    </td>
          </tr>
          <%} // end for loop %>
        </table>
        <%} %> </td>
    </tr>
  </table>
<% } %>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<% if (!bolMyHome) {%>
  <script language="JavaScript">
	FocusID();
  </script>
<%}%>
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="view_all" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
