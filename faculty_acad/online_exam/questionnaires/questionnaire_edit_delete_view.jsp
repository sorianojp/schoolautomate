<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPage() {
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	var loadPg = "./questionnaires_print.jsp?teacher="+document.question.teacher[document.question.teacher.selectedIndex].value+"&subject="+
		document.question.subject[document.question.subject.selectedIndex].value+"&exam_period="+
		document.question.exam_period[document.question.exam_period.selectedIndex].value+
		"&q_by="+escape(document.question.teacher[document.question.teacher.selectedIndex].text)+"&s_code="+
		escape(document.question.subject[document.question.subject.selectedIndex].text)+"&e_name="+
		escape(document.question.exam_period[document.question.exam_period.selectedIndex].text)+
		"&s_name="+escape(document.question.subject[document.question.subject.selectedIndex].text);

	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=200,left=150,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EditRecord(strIndex) {
	location = "./questionnaires_edit.jsp?info_index="+strIndex;
}
function ReloadPage() {
	document.question.submit();
}
function DeleteRecord(strInfoIndex) {
	if(!confirm("Do you want to delete all information? Data can't be retrieved after ok is clicked."))
		return;
	document.question.info_index.value = strInfoIndex;
	document.question.submit();
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionnair,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg    = null;
	String strTemp      = null;
	String strSubName   = null;
	Vector vRetResult   = new Vector();
	boolean bolFatalErr = false;
		
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
OLECommonUtil oleComUtil = new OLECommonUtil();
Vector vTeacherList = new Vector();
Vector vSubList = new Vector(); String strSubIndex = null;


vTeacherList = oleComUtil.getTeacherList(dbOP,request);
if(vTeacherList == null) {
	strErrMsg = oleComUtil.getErrMsg();
	bolFatalErr = true;
}
else
{
	strTemp = WI.fillTextValue("teacher");
	if(vTeacherList.indexOf(strTemp) == -1)
		strTemp = (String)vTeacherList.elementAt(0);

	request.setAttribute("fac_index",strTemp);
	vSubList = oleComUtil.getSubjectList(dbOP,request);
	if(vSubList == null)
		strErrMsg = oleComUtil.getErrMsg();
	else {
	strSubIndex = WI.fillTextValue("subject");
	if(strSubIndex.length() == 0)
		strSubIndex = (String)vSubList.elementAt(0);
		request.setAttribute("sub_index", strSubIndex);
	}

}

if(!bolFatalErr) {
	//I have to remove qn if delete is clicked.
	if(WI.fillTextValue("info_index").length() > 0) {
		OLEQuestionnair OLEQN = new OLEQuestionnair(); 
		if(OLEQN.deleteQN(dbOP, request))
			strErrMsg = "Information removed successfully.";
		else	
			strErrMsg = OLEQN.getErrMsg();
	} 
		
	vRetResult = oleComUtil.getQuestionnairList(dbOP,request);
	if(vRetResult == null)
		strErrMsg = oleComUtil.getErrMsg();
}

if(strErrMsg == null) strErrMsg = "";

%>
<form name="question" method="post" action="./questionnaire_edit_delete_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF" >:::: 
          QUESTIONNAIRES PAGE - EDIT/DELETE/VIEW ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="5"> <font size="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></font></td>
    </tr>
    
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="4">Questionnaire prepared by(fname,last name)
        <select name="teacher">
          <%
strTemp = WI.fillTextValue("teacher");

for(int i = 0; i< vTeacherList.size(); ++i)
{
	if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
          <%}
}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4"><hr> </td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="25%">Subject 
        <strong> </strong></td>
      <td colspan="2"><select name="subject" style="font-size:10px;">
<%
for(int i = 0; i< vSubList.size(); ++i)
{
	if(strSubIndex.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
        <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
        <%}else{%>
        <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
        <%}
}%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Examination Period</td>
      <td width="26%"><select name="exam_period">
        <option value="0">All</option>
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%> 
        </select></td>
      <td width="46%"><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
<%
if(vRetResult != null)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center">LIST OF QUESTIONNAIRES </div></td>
    </tr>
    <tr>
      <td height="25" colspan="6">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
        to print this page</font></td>
    </tr>
  </table>
	
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%" height="27"><div align="center"><strong><font size="1">SUBJECT 
          CODE</font></strong></div></td>
      <td width="33%"><div align="center"><strong><font size="1">SUBJECT TITLE</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">EXAMINATION PERIOD</font></strong></div></td>
      <td width="29%"><div align="center"><strong><font size="1">QUESTIONNAIRE 
          NAME</font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">DURATION</font></strong></div></td>
      <td width="5%" style="font-size:9px; font-weight:bold">UPDATE</td>
      <td width="5%" style="font-size:9px; font-weight:bold" align="center">REMOVE</td>
    </tr>
    <%
for(int i=0;i<vRetResult.size(); ++i)
{%>
    <tr> 
      <td height="25" style="font-size:11px;"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td style="font-size:11px;"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td style="font-size:11px;"> <a href='javascript:EditRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/edit.gif" border="0"></a></td>
      <td style="font-size:11px;"><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
i = i+5;
}%>
  </table>
 <%
 }//end of showing questionnairs
 %>
  <table bgcolor="#FFFFFF" width="100%">
    <tr> 
      <td width="100%" colspan="3">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<!-- all hidden fields go here -->
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="printPg" value="0">

<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>