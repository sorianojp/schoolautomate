<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function EditRecord()
{
	document.question.editRecord.value ="1";
}
function ReloadPage()
{
	document.question.reloadPage.value="1";
	document.question.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLESchedule,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	Vector vTemp = null;
	boolean bolFatalErr = false;

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.

//check for add - edit or delete rd
OLECommonUtil comUtil = new OLECommonUtil();
OLESchedule qS = new OLESchedule();
Vector vQNList = null;
Vector vTeacherList = null;
Vector vEditInfo = new Vector();

strTemp = WI.fillTextValue("editRecord");
if(strTemp.compareTo("1") == 0)
{
	if(qS.operateOnExamSch(dbOP,request,1) == null)
	{
		bolFatalErr = true;
		strErrMsg = qS.getErrMsg();
	}
	else
		strErrMsg = "Exam schedule information edited successfully.";
}

vEditInfo = qS.operateOnExamSch(dbOP,request,2);
if(vEditInfo == null)
{
	bolFatalErr = true;
	strErrMsg = qS.getErrMsg();
}
if(!bolFatalErr)
{
	vTeacherList = comUtil.getTeacherListAll(dbOP,request);
	if(vTeacherList == null)
	{
		bolFatalErr = true;
		if(strErrMsg != null)
			strErrMsg += comUtil.getErrMsg();
		else
			strErrMsg = comUtil.getErrMsg();
	}
}
if(!bolFatalErr)
{
	if(WI.fillTextValue("realoaPage").compareTo("1") ==0)
		strTemp = request.getParameter("exam_period");
	else
		strTemp = (String)vEditInfo.elementAt(4);

	vQNList = comUtil.getQuestionnairList(dbOP,(String)vEditInfo.elementAt(6),strTemp);
}
if(strErrMsg == null) strErrMsg = "&nbsp;";

%>
<form name="question" method="post" action="./online_exam_sched_edit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td width="88%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF">::::
          EXAM SCHEDULING PAGE - ADD/CREATE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><strong><%=strErrMsg%></strong>
<%
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}
%>
</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%">Subject <strong> </strong></td>
      <td> <%=(String)vEditInfo.elementAt(7)%> (<%=(String)vEditInfo.elementAt(8)%>)
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Examination Period</td>
      <td><select name="exam_period" onChange="ReloadPage();">
<%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp = WI.fillTextValue("exam_period");
else
	strTemp = (String)vEditInfo.elementAt(4);
%>
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc",strTemp, false)%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="3" height="25"><hr></td>
    </tr>
   <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="21%">Questionnaire</td>
      <td width="76%">
	  <%
boolean bolNotFound = true;
int iTemp = 0;
if(vQNList != null){%>

<select name="qn" onChange="ReloadPage();">
          <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("qn");
else
	strTemp = (String)vEditInfo.elementAt(1);
strTemp2 = null;
for(int i = 0; i< vQNList.size(); ++i)
{
	if(strTemp.compareTo((String)vQNList.elementAt(i)) ==0)
	{
	  	   iTemp = Integer.parseInt((String)vQNList.elementAt(i+2));
		   strTemp2 = ConversionTable.convertMinToHHMM(iTemp);
		   bolNotFound = false;
	%>
          <option value="<%=(String)vQNList.elementAt(i++)%>" selected><%=(String)vQNList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vQNList.elementAt(i++)%>"><%=(String)vQNList.elementAt(i)%></option>
          <%}
++i;
}
if(bolNotFound){%>
        <option value="0" selected>Not found</option>
<%}%>

        </select>
<%}else{//show default %>
<%=(String)vEditInfo.elementAt(2)%>
<input type="hidden" name="qn" value="<%=(String)vEditInfo.elementAt(1)%>">
<%}%>
        Batch
        <select name="batch">
          <option value="0">N/A</option>
          <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("batch");
else
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Batch 1</option>
          <%}else{%>
          <option value="1">Batch 1</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="2" selected>Batch 2</option>
          <%}else{%>
          <option value="2">Batch 2</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="3" selected>Batch 3</option>
          <%}else{%>
          <option value="3">Batch 3</option>
          <%}%>
        </select> <font size="1">(same section is having different questionnaire)</font></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Duration of exam</td>
      <td>
<%
if(bolNotFound)
{
	iTemp = Integer.parseInt((String)vEditInfo.elementAt(3));
	strTemp2 = ConversionTable.convertMinToHHMM(iTemp);
}
%>

	 <%=strTemp2%> <input type="hidden" name="dur_in_min" value="<%=iTemp%>"></td>
    </tr>
    <tr>
      <td  colspan="3" height="20"><hr></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="21%">Section</td>
      <td width="76%"> <%=(String)vEditInfo.elementAt(10)%>
	  <input type="hidden" name="sub_sec_index" value="<%=(String)vEditInfo.elementAt(9)%>">
         </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Examiner name</td>
      <td> <select name="teacher">
          <%
if(vTeacherList != null)
{
	if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
		strTemp =WI.fillTextValue("teacher");
	else
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(11));
bolNotFound = true;

	for(int i = 0; i< vTeacherList.size(); ++i)
	{
		if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
		{
			bolNotFound = false;
			%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
          <%}
	}


}else{%>
<option value="<%=(String)vEditInfo.elementAt(11)%>"><%=(String)vEditInfo.elementAt(12)%></option>
<%}%>
</select> 		</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Date of exam</td>
      <td>
<%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("exam_date");
else
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
%>
	  <input name="exam_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox">
        <a href="javascript:show_calendar('question.exam_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        (mm/dd/yyyy) </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Exam start time</td>
      <td> <select name="hr">
          <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("hr");
else
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
	  if(strTemp.length() ==0) strTemp ="0";
	  for(int i=1; i< 13; ++i)
	  {
	  	if(strTemp.compareTo(Integer.toString(i)) == 0)
	  {%>
          <option value="<%=i%>" selected><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
	 }%>
        </select>
        :
        <select name="min">
          <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("min");
else
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(16));
	  if(strTemp.length() ==0) strTemp ="0";
	  for(int i=0; i< 61; ++i)
	  {
	  	if(strTemp.compareTo(Integer.toString(i)) == 0)
	  	{%>
          <option value="<%=i%>" selected><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
	 }%>
        </select> <select name="AMPM">
          <option value="0">AM</option>
          <%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp =WI.fillTextValue("AMPM");
else
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(17));

	if(strTemp.compareTo("1") ==0)
	{%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Exam room number</td>
      <td>
<%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp = WI.fillTextValue("room_no");
else
	strTemp = (String)vEditInfo.elementAt(18);
%>
	  <input name="room_no" type="text" size="16" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Room location</td>
      <td>
<%
if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
	strTemp = WI.fillTextValue("room_loc");
else
	strTemp = (String)vEditInfo.elementAt(19);
%>
	  <input name="room_loc" type="text" size="16" value="<%=strTemp%>"></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="127">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td><div align="right"></div></td>
      <td width="850"><input type="image" src="../../../images/edit.gif" onClick="EditRecord();"><font size="1">click
        to save entries</font></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
 <input type="hidden" name="editRecord" value="0">
 <input type="hidden" name="reloadPage">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
