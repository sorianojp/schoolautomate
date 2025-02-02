<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function SelectALL() {
	var iMaxDisp = document.form_.max_count.value;
	if(iMaxDisp == 0)
		return;
	var bolIsChecked = false;
	
	if(document.form_.sel_all.checked)
		bolIsChecked = true;
	for(i = 0; i < eval(iMaxDisp); ++i) {
		if(bolIsChecked)
			eval('document.form_.checkbox_'+i+'.checked=true');
		else
			eval('document.form_.checkbox_'+i+'.checked=false');
	}
}
var vStop = false;
function ConvertIncToFailed() {
	var vFGrade = prompt("Please enter failed grade","Failed grade");
	if(vFGrade == null || vFGrade == '' || vFGrade.lenth == 0 || isNaN(vFGrade) ) {
		alert("Please enter a valid failed grade (either 74 or 1 or 5 depending on current grading system)");
		vStop = true;
		return;
	}
	vStop = false;
	document.form_.failed_grade.value = vFGrade;
	document.form_.page_action.value = "1";
}
function SubmitOnce() {
	if(vStop)
		return false;
	return this.SubmitOnceButton(document.form_);
}
</script>
<body bgcolor="#D2AE72">
<form name="form_" action="./convert_inc_failed.jsp" method="post" onSubmit="return SubmitOnce();">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;


//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Convert Inc To Failed","convert_inc_failed.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Modification",request.getRemoteAddr(),
									null);

}

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
Vector vRetResult = null;

GradeSystemExtn gsExtn = new GradeSystemExtn();

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0) {//convert grade here. 
	gsExtn.convertIncToFailed(dbOP, request, 1);
	strErrMsg = gsExtn.getErrMsg();	//success / failure err msg.
	//System.out.println(strErrMsg);
}
if(request.getParameter("page_action") != null) {
	vRetResult = gsExtn.convertIncToFailed(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" valign="bottom" >Course</td>
      <td colspan="2" valign="bottom" >
	  <input type="text" name="scroll_course" size="16" style="font-size:12px" 
		  onKeyUp="AutoScrollList('form_.scroll_course','form_.course_index',true);" class="textbox">
        <font size="1">(enter course code to scroll course list - Optional)</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">
	  <select name="course_index" style="font-size:10px;font-weight:bold">
        <option value="">Select Course</option>
<%
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_code asc";
%>
        <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,WI.fillTextValue("course_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom" >Student ID      </td>
      <td height="25" valign="bottom" ><input type="text" name="stud_id" size="16" style="font-size:12px" class="textbox" value="<%=WI.fillTextValue("stud_id")%>"> 
        (optional) </td>
      <td height="25" valign="bottom" >&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" valign="bottom" >How Old? </td>
      <td height="25" valign="bottom" >
	  <select name="how_old">
	  <option value="1">1 month</option>
	  <%
	  int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("how_old"),"1"));
	  for(int i = 2; i < 25; ++i){
	  	if(iDefVal == i)
			strTemp = " selected";
		else	
			strTemp = "";
	  %>
	  <option value="<%=i%>"<%=strTemp%>><%=i%></option>
	  <%}%>	
	  </select></td>
      <td width="60%" valign="bottom" ><a href="javascript:document.form_.page_action.value='';document.form_.submit();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom" style="font-size:9px;">Inc Remark </td>
      <td height="25" valign="bottom" style="font-size:9px;">
	  	  <select name="remark_inc" style="font-size:11px;color:#0000FF; font-weight:bold">
        <%=dbOP.loadCombo("remark_index","remark +' - '+remark_abbr"," from remark_status where IS_INTERNAL=1 and remark_abbr='inc' and is_del=0",
			WI.fillTextValue("remark_inc"), false)%>
      </select>
	  </td>
      <td valign="bottom" style="font-size:9px;">Failed Grade Reference : 
	  	  <select name="remark_failed" style="font-size:11px;color:#0000FF; font-weight:bold">
        <%=dbOP.loadCombo("remark_index","remark +' - '+remark_abbr"," from remark_status where IS_INTERNAL=1 and (remark_abbr not like 'p%' or remark not like '%withdraw%') and is_del=0",
			WI.fillTextValue("remark_failed"), false)%>
      </select>
	  </td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" align="right" width="11%">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5"><div align="center">LIST OF STUDENTS WITH INC GRADE </div></td>
    </tr>
  </table>
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="52%" height="25" style="font-size:9px;font-weight:bold">Total Displayed : <%=vRetResult.size()/7%></td>
      <td width="48%" style="font-size:9px;font-weight:bold"><span class="thinborder">
        <input type="submit" name="1" value="Convert Inc To Failed" style="font-size:11px; height:26px;border: 1px solid #FF0000;"
	   onClick="ConvertIncToFailed()">
      </span></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="4%" class="thinborder"><font size="1"><strong>SL. #</strong></font></td> 
      <td width="12%"  height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID </strong></font></div></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME </strong></font></div></td>
      <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold;">SUB CODE </td>
      <td width="28%" align="center" class="thinborder" style="font-size:9px; font-weight:bold;">SUBJECT TITLE </td>
      <td width="12%" align="center" class="thinborder" style="font-size:9px; font-weight:bold;">SY/TERM</td>
      <td width="8%" align="center" class="thinborder" style="font-size:9px; font-weight:bold;">CONVERT TO FAILED <br>
	  <input type="checkbox" name="sel_all" value="checked" onClick="SelectALL();"></td>
    </tr>
<%
String[] astrConvertToSem = {"SU","FS","SS","TS"};
int i = 0;
for(; i < vRetResult.size(); i += 7){%>
    <tr>
      <td class="thinborder"><%=i/7 + 1%>.</td> 
      <td  height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td align="center" class="thinborder"><%=vRetResult.elementAt(i + 5)%>, 
  	  <%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%></td>
      <td align="center" class="thinborder"><input type="checkbox" name="checkbox_<%=i/7%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%}%>
<input type="hidden" name="max_count" value="<%=i/7%>">
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%">&nbsp;</td>
      <td width="60%">&nbsp; </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
</table>
<%}//if vRetResult is not null %>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="failed_grade">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
