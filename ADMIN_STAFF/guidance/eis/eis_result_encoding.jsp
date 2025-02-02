<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/floatingTip.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
document.write('<img id="dhtmlpointer" src="../../../images/floatPointer.gif">') //write out pointer image
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.prep_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;

	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function focusID() {
	document.form_.emp_id.focus();
}
-->
</script>
<script language="JavaScript" src="../../../jscript/floatingTip.js"></script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.GDEQ" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vPersonalDetails = null;
	Vector vTable = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrCon = {"Equal to", "Between"};
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Emotional Intelligence Scale-Results Encoding","eis_result_encoding.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Emotional Intelligence Scale",request.getRemoteAddr(),
														"eis_result_encoding.jsp");
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
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;
if (WI.fillTextValue("emp_id").length() > 0) {
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
 	vPersonalDetails = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("emp_id"));
	if(vPersonalDetails == null) //may be it is the teacher/staff
	{
		request.setAttribute("emp_id",request.getParameter("emp_id"));
		vPersonalDetails = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
		if(vPersonalDetails != null)
			bolIsStaff = true;
	}
	else {//check if student is currently enrolled
		Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("emp_id"),
		(String)vPersonalDetails.elementAt(10),(String)vPersonalDetails.elementAt(11),(String)vPersonalDetails.elementAt(9));
		if(vTempBasicInfo != null)
			bolIsStudEnrolled = true;
	}
	if(vPersonalDetails == null)
		strErrMsg = OAdm.getErrMsg();
}
	GDEQ GDEq = new GDEQ();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDEq.operateOnEQResult(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDEq.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDEq.operateOnEQResult(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDEq.getErrMsg();
	}
	
	if(vPersonalDetails != null) {
		vTable = GDEq.operateOnInterpretationTable(dbOP, request, 4);
		vRetResult = GDEq.operateOnEQResult(dbOP, request, 4);
	
		if (vRetResult == null && strErrMsg == null)
			strErrMsg = GDEq.getErrMsg();
	}

String strIntpInfo = "";
if (vTable != null && vTable.size()>0){
	for (int i = 0; i < vTable.size(); i += 5)
		strIntpInfo += astrCon[Integer.parseInt((String)vTable.elementAt(i+3))]+"&nbsp;"+(String)vTable.elementAt(i+1)+
			WI.getStrValue((String)vTable.elementAt(i+2)," and ", "", "&nbsp;")+"::::"+(String)vTable.elementAt(i + 4)+"<br><br>";

	if(strIntpInfo.length() == 0) 
		strIntpInfo = "Interpretation Information not found.<br>Please create information first.";
}
%>


<body bgcolor="#D2AE72" onLoad="focusID();">
<form name="form_" method="post" action="./eis_result_encoding.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: EMOTIONAL INTELLIGENCE SCALE : RESULT ENCODING 
          PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="13%"> ID </td>
       <% strTemp = WI.fillTextValue("emp_id");%>
      <td width="20%"><input type="text" name="emp_id" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="52%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<% if (vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr >
      <td  width="4%" height="25">&nbsp;</td>
      <td width="14%" >Student Name : </td>
      <td width="45%" ><%=WebInterface.formatName((String)vPersonalDetails.elementAt(0),
	  (String)vPersonalDetails.elementAt(1),(String)vPersonalDetails.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" >
        <%if(bolIsStudEnrolled){%>
        Currently Enrolled
        <%}else{%>
        Not Currently Enrolled
        <%}%>
      </td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vPersonalDetails.elementAt(7)%> <%=WI.getStrValue((String)vPersonalDetails.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vPersonalDetails.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><strong><%=WebInterface.formatName((String)vPersonalDetails.elementAt(1),
	  (String)vPersonalDetails.elementAt(2),(String)vPersonalDetails.elementAt(3),4)%></strong></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >College/Office :</td>
      <td > <strong><%=WI.getStrValue(vPersonalDetails.elementAt(13))%>/ <%=WI.getStrValue(vPersonalDetails.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td width="96%">Date of Examination : 
        <%if (vEditInfo != null && vEditInfo.size()>0)
				strTemp = (String)vEditInfo.elementAt(2);
			else
        		strTemp = WI.fillTextValue("exam_date");%> <input name="exam_date" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Prepared by : 
        <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(3);
		else
		    strTemp = WI.fillTextValue("prep_id");%> <input type="text" name="prep_id" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>">
        &nbsp; <a href="javascript:PrepSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <% if(vPersonalDetails != null) {;%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="29">&nbsp;</td>
      <td width="15%" height="29">EQ DIMENSION </td>
      <td height="29" colspan="2">
      <%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(7);
		else
		    strTemp = WI.fillTextValue("dim_index");%>
      <select name="dim_index">
          <option value="">Select Dimension</option>
			<%=dbOP.loadCombo("EQ_DIMENSION_INDEX","EQ_DIMENSION"," FROM GD_EQ_DIMENSION WHERE IS_VALID = 1 AND IS_DEL = 0 ORDER BY ORDER_NO", strTemp, false)%>
        </select></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Raw Score</td>
      <td height="29" colspan="2">
	<%if (vEditInfo != null && vEditInfo.size()>0)
			strTemp = (String)vEditInfo.elementAt(9);
		else
			strTemp = WI.fillTextValue("raw_score");%>
      <input name="raw_score" type="text" size="4" class="textbox"  onKeyUp= 'AllowOnlyInteger("form_","raw_score")' onfocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","raw_score");style.backgroundColor="white"' value="<%=strTemp%>">
      </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Interpretation </td>
      <td width="22%" height="29"><div align="center"><strong><a href="#" onMouseover="ddrivetip('<%=strIntpInfo%>', 300)"; onMouseout="hideddrivetip()">Show table</a></strong></div></td>
      <td width="59%"></td>
    </tr>
    <tr> 
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29"><div align="center"></div></td>
      <td height="29" colspan="2"> 
       <div align="left"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div>
      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><div align="right"><font size="1"><img src="../../../images/print.gif" > 
          click to print</font></div></td>
    </tr>
  </table>
<%}
  if (vRetResult != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#D8D569"> 
      <td height="25" colspan="7" class="thinborder"><div align="center"><font color="#000000" ><strong>EMOTIONAL 
          INTELLIGENCE SCALE RESULT SUMMARY</strong></font></div></td>
    </tr>
	<tr>
		<td width="17%" class="thinborder"><div align="center"><font size="1"><strong>EXAM DATE</strong></font></div></td>
		<td width="17%" class="thinborder"><div align="center"><font size="1"><strong>EQ DIMENSION</strong></font></div></td>
		<td width="12%" class="thinborder"><div align="center"><font size="1"><strong>RAW SCORE</strong></font></div></td>
		<td width="17%" class="thinborder"><div align="center"><font size="1"><strong>INTERPRETATION</strong></font></div></td>
		<td width="17%" class="thinborder"><div align="center"><font size="1"><strong>PREPARED BY</strong></font></div></td>
		<td colspan="2" width="20%" class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
	</tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=11){ %>
	<tr>
		<td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+8)%></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"Undefined")%></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), (String)vRetResult.elementAt(i+6),7)%></font></div></td>
		<td class="thinborder"><div align="center"><font size="1"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>Not authorized to edit<%}%></font></div></td>
        <td class="thinborder"><div align="center"><font size="1"><% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>Not authorized to delete<%}%></font></div></td>
	</tr>
    <%}%>
  </table>
<%}
}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>