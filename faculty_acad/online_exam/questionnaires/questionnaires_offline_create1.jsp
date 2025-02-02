<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.question.submit();
}
function ShowExamTime()
{
	document.question.showExamTime.value="1";
	document.question.submit();
}
function PrintQN()
{
	var strTemp = document.question.qn_index[document.question.qn_index.selectedIndex].value;
	if(strTemp.length ==0 || strTemp == "0")
	{
		alert("Please select a questionnaire to print.");
		return;
	}
	strTemp = "./print_offline.jsp?qn_index="+strTemp+"&c_name="+
					escape(document.question.college[document.question.college.selectedIndex].text)+"&month="+
					document.question.month[document.question.month.selectedIndex].text+"&year="+
					document.question.year[document.question.year.selectedIndex].text+"&e_period="+
					escape(document.question.exam_period[document.question.exam_period.selectedIndex].text)+"&duration="+
					escape(document.question.duration.value)+"&sub_code="+
					escape(document.question.subject[document.question.subject.selectedIndex].text)+"&sub_name="+
					escape(document.question.sub_name.value)+"&subject="+
					document.question.subject[document.question.subject.selectedIndex].value;
	var win=window.open(strTemp,"myfile",'dependent=yes,width=900,height=600,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=yes');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionnair,java.util.Vector,java.util.Calendar " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	String strSubName = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

//end of security code. 

OLECommonUtil comUtil = new OLECommonUtil();
OLEQuestionnair qN = new OLEQuestionnair();

Vector vSubList = new Vector();
vSubList = comUtil.getSubjectList(dbOP,request.getParameter("college"));
if(vSubList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
}

if(strErrMsg == null) strErrMsg = "&nbsp;";
%>
<form name="question" method="post" action="./questionnaires_offline_create1.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF">:::: 
          QUESTIONNAIRES PAGE - GENERATE (OFFLINE EXAM) ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2">&nbsp; </td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%">College 
        <select name="college" onChange="ReloadPage();">
          <option value="0"> Select a College offering subject</option>
 <%
	strTemp = WI.fillTextValue("college");
%>
          <%=dbOP.loadCombo("C_INDEX","C_NAME"," from COLLEGE where IS_DEL=0 order by C_NAME asc",strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td colspan="2"><hr></td>
    </tr>
  </table>
	
<%
if(vSubList != null){%>
	
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="19%">Subject 
        </td>
      <td colspan="2" style="font-size:10px;"> 
        <select name="subject" onChange="ReloadPage();" style="font-size:10px;">
          <option value="0">Select a subject</option>
 <%
	strTemp = WI.fillTextValue("subject");

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
if(strTemp.length() > 0)
	strSubName = dbOP.mapOneToOther("subject","sub_index",strTemp,"sub_name",null);

if(strSubName == null)
	strSubName = "";
%>
        Subject Title : <strong><%=strSubName%></strong>
		<input type="hidden" name="sub_name" value="<%=strSubName%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Examination Period</td>
      <td width="51%"><select name="exam_period">
<%
	strTemp = WI.fillTextValue("exam_period");
%>
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc",strTemp, false)%> 
        </select></td>
      <td width="27%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td  colspan="3" height="20"><hr></td>
    </tr>
    <tr> 
      <td width="3%" height="20">&nbsp;</td>
      <td width="19%">Questionnaire</td>
      <td width="78%"> 
        <select name="qn_index" onChange="ShowExamTime()">
	<option value="0"></option>
<%
if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("exam_period").length() > 0){%>
<%=dbOP.loadCombo("QN_INDEX","QN_NAME"," from OLE_QN where IS_DEL=0 and EPERIOD_INDEX="+WI.fillTextValue("exam_period")+
					" and subject_index="+WI.fillTextValue("subject")+" order by QN_NAME asc",WI.fillTextValue("qn_index"), false)%> 
<%}%>
        </select>
        </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td>Duration of exam</td>
      <td>
<%
strSubName = null;
if(WI.fillTextValue("qn_index").length() > 0 && WI.fillTextValue("showExamTime").compareTo("1") ==0)
{
	strSubName = dbOP.mapOneToOther("OLE_QN","QN_INDEX",request.getParameter("qn_index"),"duration",null);
	if(strSubName != null)
		strSubName = ConversionTable.convertMinToHHMM(Integer.parseInt(strSubName));
}
if(strSubName == null)
	strSubName = "";
%>
<%=strSubName%>
<input type="hidden" name="duration" value="<%=strSubName%>">
</td>
    </tr>
	    <tr> 
      <td height="20">&nbsp;</td>
      <td>Month/Year of exam</td>
      <td>
<select name="month">
<%
String[] astrConvertToMonth={"January","February","March","April","May","June","July","August","September","October","November","December"};

strTemp = WI.fillTextValue("month");
if(strTemp.length() ==0)
	strTemp = Integer.toString(Calendar.getInstance().get(Calendar.MONTH));

int iDef = Integer.parseInt(strTemp);

for(int i=0; i<12;++i){
	if(i == iDef)
		strErrMsg = " selected";
	else	
		strErrMsg = "";
%>
	<option value="<%=i%>" <%=strErrMsg%>><%=astrConvertToMonth[i]%></option>
<%}%>
</select>
        / 
<select name="year">
<%
strTemp = WI.fillTextValue("year");
if(strTemp.length() ==0)
	strTemp = Integer.toString(Calendar.getInstance().get(Calendar.YEAR));
int iYear = Integer.parseInt(strTemp);
for(int i=iYear-1; i<iYear+6;++i){
if(i == iYear){%>
<option selected><%=i%></option>
<%}else{%>
<option><%=i%></option>
<%}
}%>
</select>		</td>
    </tr>

  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="22%">&nbsp;</td>
      <td width="78%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="right"></div></td>
      <td>
	  <%
	  if(WI.fillTextValue("qn_index").length() > 0 && WI.fillTextValue("qn_index").compareTo("0") != 0
	  && WI.fillTextValue("showExamTime").compareTo("1") ==0){%>
	  <a href="javascript:PrintQN();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
 <%
 }//vSubList ! null
%>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="showExamTime" value="0">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>