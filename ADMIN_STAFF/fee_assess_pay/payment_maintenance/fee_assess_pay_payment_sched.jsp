<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.pmtsch.editRecord.value = 0;
	document.pmtsch.deleteRecord.value = 0;
	document.pmtsch.addRecord.value = 0;
	document.pmtsch.prepareToEdit.value = 1;
	document.pmtsch.info_index.value = strInfoIndex;
	document.pmtsch.submit();

}
function AddRecord()
{
	if(document.pmtsch.prepareToEdit.value == 1)
	{
		EditRecord(document.pmtsch.info_index.value);
		return;
	}
	document.pmtsch.editRecord.value = 0;
	document.pmtsch.deleteRecord.value = 0;
	document.pmtsch.addRecord.value = 1;

	document.pmtsch.hide_save.src = "../../../images/blank.gif";
	document.pmtsch.submit();
}
function EditRecord(strTargetIndex)
{
	document.pmtsch.editRecord.value = 1;
	document.pmtsch.deleteRecord.value = 0;
	document.pmtsch.addRecord.value = 0;

	document.pmtsch.info_index.value = strTargetIndex;

	document.pmtsch.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.pmtsch.editRecord.value = 0;
	document.pmtsch.deleteRecord.value = 1;
	document.pmtsch.addRecord.value = 0;

	document.pmtsch.info_index.value = strTargetIndex;
	document.pmtsch.prepareToEdit.value == 0;

	document.pmtsch.submit();
}
function CancelRecord()
{
	location = "./fee_assess_pay_payment_sched.jsp";
}
function UpdateSched() {
	var win=window.open("./payment_sched_specificSY.jsp","myfile",'dependent=yes,width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSpecificCourse() {
	var win=window.open("./payment_sched_specificCourse.jsp","myfile",'dependent=yes,width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateExamDate() {
	var win=window.open("./payment_sched_date.jsp","myfile",'dependent=yes,width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Payment schedule","fee_assess_pay_payment_sched.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"fee_assess_pay_payment_sched.jsp");
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

FAPmtMaintenance FA = new FAPmtMaintenance();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addPSch(dbOP,request))
		strErrMsg = "Payment schedule added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(FA.editPSch(dbOP,request))
			strErrMsg = "Payment schedule edited successfully.";
		else
		{
			bolProceed = false;
			strErrMsg = FA.getErrMsg();
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";

			if(FA.delPSch(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Payment schedule deleted successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();

if(bolProceed)
{
	vRetResult = FA.viewPSch(dbOP, null, true);//to view all
	if(vRetResult ==null)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewPSch(dbOP,request.getParameter("info_index"), false);//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
}

dbOP.cleanUP();

//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	return;
}
%>


<form name="pmtsch" action="./fee_assess_pay_payment_sched.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          PAYMENT SCHEDULE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" >&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Examination Period Order</td>
      <td><select name="exam_period_order">
          <option value="1">1st</option>
          <%
if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("exam_period_order");
	if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") == 0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") == 0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") == 0)
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") == 0)
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") == 0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") == 0)
{%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}if(strTemp.compareTo("8") == 0)
{%>
          <option value="8" selected>8th</option>
          <%}else{%>
          <option value="8">8th</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%">Examination Period Name</td>
      <td width="69%"> <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("exam_name");
	if(strTemp == null) strTemp = "";
	%> <input name="exam_name" type="text" size="36" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Examination Schedule</td>
      <td> 
<%
 //get index of date here == mm/dd/yyyy -
 	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("exam_sch_date");
%> 		
		<font size="1"> 
        <input name="exam_sch_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('pmtsch.exam_sch_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Grading Period Name </td>
      <td style="font-size:9px;">
<%
 	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = WI.fillTextValue("grading_name");
%> 		
	  <input name="grading_name" type="text" size="16" maxlength="32" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      (Leave blank if this is not a grading period) </td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Click Update to set number of payment Schedule and duration for a specific school year/Term. <a href="javascript:UpdateSched();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Click Update to change Number of Payment Schedule for a specific COURSE. <a href="javascript:UpdateSpecificCourse();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><font color="#0000FF">Click Update to Last date of Payment 
        Schedule</font><a href="javascript:UpdateExamDate();"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%if(true){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="left"></div></td>
      <td><%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%> <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to add</font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
        <font size="1">click to cancel or go previous</font> <%}%></td>
    </tr>
    <%}
	}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%" colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">LIST OF EXISTING PAYMENT
          SCHEDULE ENTRIES</div></td>
    </tr>
  </table>

  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="15%" height="25"><div align="center"><font size="1"><strong>Period Order </strong></font></div></td>
      <td width="45%"><div align="center"><font size="1"><strong>Period Name </strong></font></div></td>
      <td width="20%" align="center" style="font-size:9px; font-weight:bold">Grading Name </td>
      <td width="20%" align="center" style="font-size:9px; font-weight:bold">Last Due Date </td>
      <!--      <td width="34%"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>-->
      <td width="20%" align="center"><font size="1"><strong>Edit</strong></font></td>
<!--      <td width="10%" align="center"><font size="1"><strong>DELETE</strong></font></td>-->
    </tr>
<%//System.out.println(vRetResult);
for(int i = 0 ; i< vRetResult.size() ; ++i) {%>
    <tr >
      <td height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=WI.getStrValue(vRetResult.elementAt(i+4),"-")%></td>
      <td><%=WI.formatDate((String)vRetResult.elementAt(i+3), 10)%></td>
      <!--      <td><%=(String)vRetResult.elementAt(i+3)%></td>-->
    	<td align="center">
<%if(iAccessLevel > 1){%>
		<a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>		</td>
        <!--<td align="center">
<%if(iAccessLevel > 1){%>
    	<a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>		</td>-->
    </tr>

<% i = i+4;
	}//end of displaying the entries in loop.
%>
  </table>
<%}//end of displaying the created exising payment schedule entries.
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="6" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">
</form>
</body>
</html>
