<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title></title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">

function ViewDetail(strdetail) 
{
	var pgLoc = "./recruitment_report_detailed.jsp?detailed_index="+strdetail+
		"&sy_from="+document.form_.sy_from.value+
		"&semester="+document.form_.semester.value;
	var win=window.open(pgLoc,"ViewDetail",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg()
{
	
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(0);

	
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);

	window.print();

}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.PersonalInfoManagement,java.util.Vector"%>
<%
    DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	//add security here.
	strTemp = request.getParameter("userId");
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","recruitment_report_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
 %>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
      //authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
							"Admission","Student Info Mgmt",
							request.getRemoteAddr(), "recruitment_report_summary.jsp");
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

PersonalInfoManagement pInfoMgmt = new PersonalInfoManagement();
String strSYFrom   = WI.getStrValue(WI.fillTextValue("sy_from"),(String)request.getSession(false).getAttribute("cur_sch_yr_from"));
String strSemester = WI.getStrValue(WI.fillTextValue("semester"),(String)request.getSession(false).getAttribute("cur_sem"));



Vector vRecDtls = new Vector();
vRecDtls = pInfoMgmt.getRecruitmentSummaryReport(dbOP, request, strSYFrom, strSemester);
if(vRecDtls == null)
	strErrMsg = pInfoMgmt.getErrMsg();	

 
	

%>
<form name="form_" action="recruitment_report_summary.jsp" method="post">
  <table width="100%" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable1">
    <tr>
      <td height="20" colspan="5" bgcolor="#B9B292" ><div align="center"><strong>:::  RECRUITMENT INFORMATION REPORT ::: </strong></div></td>
    </tr>
    <tr>
      <td height="20"  colspan="5" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2" >
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="71%">&nbsp; SY-Term
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
       to 
      <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
     &nbsp;
        <select name="semester">
          <%	
if(strSemester.equals("1"))

	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
          <%
if(strSemester.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
          <%
if(strSemester.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
          <%
if(strSemester.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>
        </select>
        <input type="image" src="../../images/refresh.gif">      </td>
      <td width="28%" align="right" valign="bottom"><!--<a href="./recruitment_report_detailed.jsp">Go to Detailed Report</a>--></td>
    </tr>
  </table>
  <% 
	if(vRecDtls != null && vRecDtls.size() > 0)
	{

%>
  <table width="100%" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable3" >
    <tr>
      <td  width="50%" style="font-size:9px; font-weight:bold">Note: Double click any row to view detail.</td>
      <td  width="50%" height="25" align="right"><a href="JavaScript:PrintPg();"> <img src="../../images/print.gif" border="0"> </a></td>
    </tr>
    <tr>
      <td width="100%" colspan="2"><br/>
        <div align="center"> <font style="font-size:13px; font-weight:bold;"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%> </font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%> <br>
          Summary of Recruitment Information<br />
           <br />
        </div></td>
    </tr>
  </table>
  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
    <tr>
      <td height="20" width="35%" class="thinborder"><strong>Recruitment Information</strong></td>
      <td width="35%" class="thinborder"><strong>Student Count</strong></td>
    </tr>
    <% 
	
	for(int i = 0; i < vRecDtls.size(); i += 4)
	{

%>
    <tr ondblclick="ViewDetail('<%=(String)vRecDtls.elementAt(i+1)%>')">
      <td height="25" class="thinborder"><%=(String)vRecDtls.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRecDtls.elementAt(i+3),"0")%>&nbsp;&nbsp;&nbsp; </td>
    </tr>
    <%}%>
	
  </table>
  
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%}%>
</form>
<input type="hidden" name="userId" value="">

</body>
</html>
<%
dbOP.cleanUP();
%>
