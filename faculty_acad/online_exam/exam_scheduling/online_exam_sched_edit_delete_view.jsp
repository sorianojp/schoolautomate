<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ShowSchedule()
{
	document.question.exam_period_name.value = document.question.exam_period[document.question.exam_period.selectedIndex].text;
	document.question.showSchedule.value = "1";
	
	document.question.action="./online_exam_sched_edit_delete_view.jsp";
}
function ReloadPage()
{
	document.question.action="./online_exam_sched_edit_delete_view.jsp";
	document.question.submit();
}
function DeleteRecord(strIndex)
{
	document.question.deleteRecord.value = "1";
	ReloadPage();
}
function EditRecord(strIndex)
{
	location="./online_exam_sched_edit.jsp?info_index="+strIndex;
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
	String strTemp = null;
	String strSubName = null;
	String strTemp2 = "";
	Vector vTemp = null;
	
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
Vector vExamSch = new Vector();
//delete record if it is called. 
if(WI.fillTextValue("deleteRecord").compareTo("1") ==0)
{
	if(qS.operateOnExamSch(dbOP,request,0) == null)
		strErrMsg = "Exam schedule deleted successfully.";
	else
		strErrMsg = qS.getErrMsg();
}
strTemp = WI.fillTextValue("showSchedule");
if(strTemp.compareTo("1") == 0)
{
	vExamSch = qS.getExamSchedule(dbOP,request, true);//show only the valid exam schedules.
	if(vExamSch == null || vExamSch.size() ==0)
		strErrMsg = qS.getErrMsg();
}

Vector vSubList = new Vector();
vSubList = comUtil.getSubjectList(dbOP,request.getParameter("college"));
if(vSubList == null)
{//System.out.println("I am here ");
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}

if(strErrMsg == null) strErrMsg = "&nbsp;";
%>


<form name="question" method="post" action="">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong> <font color="#FFFFFF" > 
          :::: EXAM SCHEDULING PAGE - VIEW SCHEDULES ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <%
if(strErrMsg == null) strErrMsg = "";
%>
      <td colspan="5"> <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="4">College of 
        <select name="college" onChange="ReloadPage();">
          <option value="0"> Select a College offering subject</option>
          <%=dbOP.loadCombo("C_INDEX","C_NAME"," from COLLEGE where IS_DEL=0 order by C_NAME asc", request.getParameter("college"), false)%> 
        </select>
		<input type="hidden" name="college_name">
		</td>
    </tr>
<%
if(vSubList != null){%>
    <tr> 
      <td>&nbsp;</td>
      <td width="41%" >Subject</td>
      <td width="7%">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="29%">Examination Period</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" ><select name="subject" onChange="ReloadPage();">
          <option value="0">Select a subject</option>
          <%
strTemp =WI.fillTextValue("subject");

for(int i = 0; i< vSubList.size(); ++i)
{
	if(strTemp.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
          <%}
}%>
        </select> 
        <%
//get the subject name here. 
strSubName = dbOP.mapOneToOther("subject","sub_index",request.getParameter("subject"),"sub_name",null);
if(strSubName == null)
	strSubName = "";
%>
        Subject Title : <strong><%=strSubName%></strong>
		<input type="hidden" name="subject_name" value="<%=strSubName%>"%> </td>
      <td > 
        <select name="exam_period" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%> 
        </select>
		<input type="hidden" name="exam_period_name" value="">
        </td>
    </tr>
<%
if(strSubName.length() > 0)
{%>    <tr> 
      <td height="23" colspan="5"><div align="center">
	  <input type="image" src="../../../images/form_proceed.gif" border="0" onClick="ShowSchedule();"></div></td>
    </tr>
<%}%>
  </table>
<%
if(vExamSch != null && vExamSch.size() >0)
{%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center">LIST OF 
          EXAMINATION SCHEDULES FOR SUBJECT <strong><%=request.getParameter("subject_name")%> </strong>FOR <strong><%=request.getParameter("exam_period_name")%></strong> 
          EXAMINATION</div></td>
    </tr>
    <tr>
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
	
  <table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="8%" height="21"><div align="center"><font size="1">EXAM ID</font></div></td>
      <td width="10%" height="21"><div align="center"><font size="1">EXAMINER 
          NAME</font></div></td>
      <td width="12%" align="center"><font size="1">SECTION</font></td>
      <td width="10%" align="center"><font size="1">BATCH</font></td>
      <td width="8%" align="center"><font size="1">ROOM #</font></td>
      <td width="12%" align="center"><font size="1">ROOM LOCATION</font></td>
      <td width="8%" align="center"><font size="1">DURATION</font></td>
      <td width="8%" align="center"><font size="1">DATE OF EXAM (mm/dd/yyyy)</font></td>
      <td width="8%" align="center"><font size="1">EXAM TIME</font></td>
      <td width="4%">&nbsp;</td>
      <td width="4%" align="center">&nbsp;</td>
    </tr>
    <%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertBatch={"N/A","Batch 1","Batch 2","Batch 3"};

for(int i=0; i< vExamSch.size(); ++i){%>
    <tr> 
      <td height="25" align="center"><font size="1"><%=(String)vExamSch.elementAt(i+12)%></font></td>
      <td height="25" align="center"><font size="1"><%=(String)vExamSch.elementAt(i+1)%> 
        - <%=(String)vExamSch.elementAt(i+2)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+3)%></font></td>
      <td align="center"><font size="1"><%=astrConvertBatch[Integer.parseInt((String)vExamSch.elementAt(i+11))]%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+4)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+5)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+6)%> mins</font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+7)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+8)%>:<%=(String)vExamSch.elementAt(i+9)%> 
        <%=astrConvertAMPM[Integer.parseInt((String)vExamSch.elementAt(i+10))]%></font></td>
      <td align="center">
	  <a href='javascript:EditRecord("<%=(String)vExamSch.elementAt(i)%>")'><img src="../../../images/edit.gif" width="33" height="24" border="0"></a></td>
      <td align="center"><a href='javascript:DeleteRecord("<%=(String)vExamSch.elementAt(i)%>")'><img src="../../../images/delete.gif" width="39" height="21" border="0"></a></td>
    </tr>
    <%
i = i+12;
}%>
  </table>

<%			}//vSubject list is not null and not empty.
}//vExamSched is not null. 
%>  

  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="showSchedule">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>