<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Excluded subject list</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../..//css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strAction,strInfoIndex)
{
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	else
		document.form_.hide_delete.src = "../../../images/gif";
/**
	if(document.form_.max_count) {
		var iCount = document.form_.max_count.value;
		for(i =0; i < iCount; ++i) {
			alert(document.form_._rb.checked);
			if(!document.form_._rb[i] || !document.form_._rb[i].checked)
				continue;
			eval('document.form_.req_sub_fee.value = document.form_.req_sub_fee'+i+'.value');
		}
	}
**/
	//alert(document.form_.max_count.value);
	document.form_.submit();
}
function OnSelectRequestedSub(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
}
function updateAmtEntered(e, icount, strInfoIndex) {
	if(document.form_.max_count && document.form_.max_count.value == '1')
		document.form_.checkbox.checked=true;
	else	
		document.form_.checkbox[icount].checked=true;
		
	eval('document.form_.req_sub_fee.value = document.form_.req_sub_fee'+icount+'.value');
	OnSelectRequestedSub(strInfoIndex);
	
	if(e.keyCode == 13)
		this.PageAction('1','');
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenanceVairable,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI        = new WebInterface(request);

	String strTemp         = null;
	String strErrMsg       = null;
	Vector vRetResult      = null;
	Vector vShowSubToReq   = null;//this is the detail of the subject to be requested.


//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Fee Assessment & Payments-assessment","re_assessment.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														"re_assessment.jsp");
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
FAFeeMaintenanceVairable faFeeMaintenance = new FAFeeMaintenanceVairable();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() >0)
{
	if(faFeeMaintenance.operateOnRequestedSub(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = faFeeMaintenance.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
vRetResult = faFeeMaintenance.operateOnRequestedSub(dbOP,request,4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = faFeeMaintenance.getErrMsg();
if(WI.fillTextValue("sub_code").length() > 0) {
	vShowSubToReq = faFeeMaintenance.operateOnRequestedSub(dbOP,request,3);
	if(vShowSubToReq == null || vShowSubToReq.size() ==0)
		strErrMsg = faFeeMaintenance.getErrMsg();
}
%>
<form name="form_" action="./re_assessment.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          RE-ASSESSMENT (REQUESTED SUBJECT CHARGES) PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td width="85%" height="25"> <%
String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
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
	  readonly="yes"> 
        &nbsp; <select name="semester" >
          <option value="">ALL</option>
          <%
String strSemester =WI.fillTextValue("semester");
if(strSemester.length() ==0) 
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strSemester.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strSemester.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strSemester.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>      </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="11%" height="25">Subject</td>
      <td height="25">
	  <select name="sub_code" style="font-size:11px; width: 400px" onChange="ReloadPage();">
        <%=dbOP.loadCombo("subject.sub_code","subject.sub_code,sub_name"," from subject where is_del=0 and exists (select sub_sec_index from e_sub_section where sub_index = subject.sub_index and offering_sy_from = "+strSYFrom+" and offering_sem = "+strSemester+" and is_valid = 1) order by subject.sub_code ",WI.fillTextValue("sub_code"), false)%>
      </select>	  </td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td height="39">&nbsp;</td>
      <td height="39"> <a href="javascript:ReloadPage();"> <img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
    <%
if(vShowSubToReq != null && vShowSubToReq.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25"><div align="center">LIST OF OFFERING(S) FOR 
          SUBJECT <strong><%=WI.fillTextValue("sub_code").toUpperCase()%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr style="font-weight:bold"> 
      <td width="20%" height="34"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>SCHEDULE/ROOM #</strong></font></div></td>
      <td width="11%"><div align="center"><strong><font size="1">NO. OF STUDENTS IN CLASS</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">MIN. NO. OF STUDENTS REQ. IN CLASS </font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1"> OFFERING TYPE</font></strong></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>SELECT TO RE-ASSESS CHARGES </strong></font></div></td>
      <td width="10%" align="center"><font size="1">NEW RATE (IF APPLICABLE)</font></td>
    </tr>
    <%int iCount = 0;
 for(int i=0; i< vShowSubToReq.size(); i += 9){
 %>
    <tr> 
      <td height="25"><%=(String)vShowSubToReq.elementAt(i+4)%></td>
      <td><%=(String)vShowSubToReq.elementAt(i+1)%></td>
      <td> <%=(String)vShowSubToReq.elementAt(i+2)%><!-- -- Room location & sched-->      </td>
      <td><%=WI.getStrValue(vShowSubToReq.elementAt(i+6),"&nbsp;")%></td>
      <td align="center"><%=(String)vShowSubToReq.elementAt(i+5)%></td>
      <td align="center"><%=(String)vShowSubToReq.elementAt(i+7)%></td>
      <td align="center"><input type="radio" name="checkbox" value="checkbox" 
	  	onClick='OnSelectRequestedSub("<%=(String)vShowSubToReq.elementAt(i)%>");'></td>
      <td align="center">
	  <input type="textbox" name="req_sub_fee<%=iCount++%>" value="" class="textbox" size="10" onKeyUp="updateAmtEntered(event, <%=iCount - 1%>,'<%=(String)vShowSubToReq.elementAt(i)%>');">
	  </td>
    </tr>
    <%
}%>
<input type="hidden" name="max_count" value="<%=iCount%>">
  </table>
  <table width="100%" height="46" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
      <td height="46"><div align="center">
	  <a href='javascript:PageAction("1","");'>
	  	<img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click 
          to save re-assessment </font></div></td>
  </tr>
</table>
  <%}//end of showing if subject to be saved as requested subjects.
  
  if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <tr>
	<td height="25" bgcolor="#B9B292" align="center">REQUESTED SUBJECT DETAIL </td>
 </tr>
</table>  
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="20%" height="34"><div align="center"><font size="1"><strong>SUBJECT CODE (DESCRIPTION)</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>SECTION </strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>SCHEDULE/ROOM #</strong></font></div></td>
      <td width="11%"><div align="center"><strong><font size="1">NO. OF STUDENTS IN CLASS</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">MIN. NO. OF STUDENTS REQ. IN CLASS </font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">REQUESTED SUBJECT FEE</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1"> DELETE REQUESTED SUBJECT </font></strong></div></td>
    </tr>
    <%
 for(int i=0; i< vRetResult.size(); i += 9){
 %>
    <tr> 
      <td height="25"><strong><%=(String)vRetResult.elementAt(i+3)%></strong><%=" ("+
	  	(String)vRetResult.elementAt(i+4)+")"%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td> <%=(String)vRetResult.elementAt(i+2)%> 
        <!-- -- Room location & sched-->      </td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+8), "&nbsp;")%></td>
      <td align="center">
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
	  <img src="../../../images/delete.gif" border="0" name="hide_delete"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index">
<input type="hidden" name="req_sub_fee">

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
