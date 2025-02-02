<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");//System.out.println(strSchCode);
String strInfo5 = (String)request.getSession(false).getAttribute("info5");//System.out.println(strSchCode);
if(strSchCode == null)
	strSchCode = "";
String strPrintURL = null;
if(strSchCode.startsWith("CPU"))
	strPrintURL = "./admission_slip_print_cpu.jsp";
else if(strSchCode.startsWith("CGH"))
	strPrintURL = "./admission_slip_print_cgh.jsp";
else if(strSchCode.startsWith("UDMC"))
	strPrintURL = "./admission_slip_print_udmc.jsp";
else if(strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT") || 
		strSchCode.startsWith("UB") || strSchCode.startsWith("UPH") || strSchCode.startsWith("MARINER")) {
	if(strInfo5 != null && strInfo5.startsWith("jonelta"))
		strPrintURL = "./admission_slip_print_jonelta.jsp";
	else	
		strPrintURL = "./admission_slip_print_auf.jsp";
}
else if(strSchCode.startsWith("PHILCST"))
	strPrintURL = "./admission_slip_print_philcst.jsp";
else if(strSchCode.startsWith("EAC"))
	strPrintURL = "./admission_slip_print_eac.jsp";
else if(strSchCode.startsWith("UC"))
	strPrintURL = "./admission_slip_print_uc.jsp";
else	
	strPrintURL = "./admission_slip_print.jsp";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg()
{
	var loadPg = "<%=strPrintURL%>?stud_id="+
		document.form_.stud_id.value+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&offering_sem="+
		document.form_.offering_sem[document.form_.offering_sem.selectedIndex].value+
		"&pmt_schedule="+
		document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax.
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));		
			if(iAccessLevel == 0) 
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));		
		}
		//may be called from Guidance.
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS-ADMISSION SLIP"),"0"));		
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Admission slip","admission_slip.jsp");
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
/**CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(),
														"admission_slip.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0 && !comUtil.IsAuthorizedModule(dbOP,(String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling"))//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
**/
//end of authenticaion code.
enrollment.EnrlAddDropSubject enrlADSub = new enrollment.EnrlAddDropSubject();
ReportEnrollment repEnrolment = new ReportEnrollment();

Vector vRetResult = null;
Vector vStudDetail= null;
if(WI.fillTextValue("sy_to").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	vStudDetail = enrlADSub.getEnrolledStudInfo(dbOP, null, WI.fillTextValue("stud_id"), WI.fillTextValue("sy_from"), 
					WI.fillTextValue("sy_to"), WI.fillTextValue("offering_sem"));
	if(vStudDetail == null)
		strErrMsg = enrlADSub.getErrMsg();					
}
if(vStudDetail != null && vStudDetail.size() > 0) {
	vRetResult = repEnrolment.getExamORList(dbOP, (String)vStudDetail.elementAt(0), WI.fillTextValue("sy_from"),
					WI.fillTextValue("sy_to"), WI.fillTextValue("offering_sem"), 
					WI.fillTextValue("pmt_schedule"));
	if(vRetResult == null)
		strErrMsg = repEnrolment.getErrMsg();
}
%>
<form action="./admission_slip.jsp" method="post" name="form_">

  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ADMISSION SLIP PAGE ::::</strong></font></strong></font></div></td>
    </tr>
  </table>


  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr valign="top"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%">School Year : </td>
      <td> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td colspan="3">Term : 
        <select name="offering_sem">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
    <tr valign="top"> 
      <td height="25">&nbsp;</td>
      <td height="25">Exam Period</td>
      <td height="25" colspan="3">
        <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%> 
        </select>
		</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr valign="top"> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID : </td>
      <td width="20%" height="25"><input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="2%"><a href="javascript:OpenSearch();"></a></td>
      <td width="10%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
      <td width="54%" height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <td  colspan="6" height="10"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudDetail != null && vStudDetail.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%" height="25">Student Name : </td>
      <td width="48%" height="25"><strong><%=(String)vStudDetail.elementAt(1)%></strong></td>
      <td width="34%" height="25">Year : <strong><%=WI.getStrValue(vStudDetail.elementAt(4),"N/A")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : </td>
      <td height="25"><strong><%=(String)vStudDetail.elementAt(2)%><%=WI.getStrValue((String)vStudDetail.elementAt(3),"/","","")%></strong></td>
      <td align="right">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#cccccc"> 
      <td width="37%" height="20">&nbsp;<b><font size="1">Exam Name</font></b></td>
      <td width="40%">&nbsp;<b><font size="1">OR NUMBER</font></b></td>
      <td width="23%">&nbsp;<b><font size="1">PRINT</font></b></td>
<%if(strSchCode.startsWith("UI")){%>
      <td width="23%"><font size="1"><strong>ALREADY PRINTED</strong></font></td>
<%}%>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 3) {%>
    <tr bgcolor="#ffffff"> 
      <td height="20">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td>&nbsp;<a href='javascript:PrintPg();'> 
        <img src="../../../images/print.gif" border="0"></a></td>
<%if(strSchCode.startsWith("UI")){%>
      <td align="center"><%
	  if( ((String)vRetResult.elementAt(i + 2)).compareTo("0") == 0){%>
	  <img src="../../../images/x.gif"><%}else{%><img src="../../../images/tick.gif"><%}%></td>
<%}//show for UI only. 
%>    </tr>
    <%}%>
  </table>
<%}//only if vRetResult > 0

}//if student info not null%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center"></div></td>
      <td width="26%" align="right">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reloadPage" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>