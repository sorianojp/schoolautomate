<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.question.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLEResult,OLExam.OLECommonUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSubName = null;
	String[] astrSchYrInfo = null;
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
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


//end of security code.
OLEResult oleResult 	= new OLEResult();
OLECommonUtil comUtil 	= new OLECommonUtil();
Vector vSubSection  	= null;
Vector vSubList 		= null;
Vector vStudList        = null;

astrSchYrInfo = dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
//if subject is selected, display subject section index,
if(!bolFatalErr && WI.fillTextValue("college").compareTo("0") !=0 && WI.fillTextValue("college").length() > 0)
{
	vSubList = comUtil.getSubjectList(dbOP,request.getParameter("college"));
	if(vSubList == null)
		strErrMsg = comUtil.getErrMsg();
}
if(WI.fillTextValue("subject").length() > 0 && WI.fillTextValue("subject").compareTo("0") !=0 )
{
	vSubSection = comUtil.getSectionOfferedByTheSubject(dbOP, request.getParameter("subject"),astrSchYrInfo[0],astrSchYrInfo[1],
															astrSchYrInfo[2]);
	if(vSubSection == null)
		strErrMsg = comUtil.getErrMsg();
}



if(strErrMsg == null) strErrMsg = "";
%>
<form name="question" method="post" action="./exam_result_encode.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td width="88%" height="25" colspan="8"><div align="center"><strong> <font color="#FFFFFF" >
          </font><font color="#FFFFFF" size="2" >:::: EXAM RESULTS - ENCODE RESULTS
          PAGE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="4"> <font size="3">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></font></td>
    </tr>
    <%
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}%>
    <tr>
      <td>&nbsp;</td>
      <td colspan="3">Offering school year/term : <strong><%=astrSchYrInfo[0]%>
        - <%=astrSchYrInfo[1]%> / <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%></strong>
        <input type="hidden" name="semester" value="<%=astrSchYrInfo[2]%>"> <input type="hidden" name="sy_from" value="<%=astrSchYrInfo[0]%>">
        <input type="hidden" name="sy_to" value="<%=astrSchYrInfo[1]%>"> </td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td colspan="3">College of
        <select name="college" onChange="ReloadPage();">
          <option value="0"> Select a College offering subject</option>
          <%=dbOP.loadCombo("C_INDEX","C_NAME"," from COLLEGE where IS_DEL=0 order by C_NAME asc", request.getParameter("college"), false)%>
        </select></td>
    </tr>
    <%
if(vSubList != null && vSubList.size() > 0){%>
    <tr>
      <td>&nbsp;</td>
      <td width="26%" valign="bottom" >Subject</td>
      <td width="44%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
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
        Subject Title : <strong><%=strSubName%></strong> </td>
    </tr>
    <%
if(vSubSection != null && vSubSection.size() > 0){%>
    <tr>
      <td>&nbsp;</td>
      <td valign="bottom" >Section</td>
      <td valign="bottom" >Examination Period </td>
      <td valign="bottom" >&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td ><font color="#000000" size="2">
        <select name="section">
          <%
strTemp =WI.fillTextValue("section");
for(int i = 0; i< vSubSection.size(); ++i)
{
	if(strTemp.compareTo((String)vSubSection.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vSubSection.elementAt(i++)%>" selected><%=(String)vSubSection.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vSubSection.elementAt(i++)%>"><%=(String)vSubSection.elementAt(i)%></option>
          <%}
}
%>
        </select>
        </font></td>
      <td ><select name="exam_period" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc", request.getParameter("exam_period"), false)%>
        </select></td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="bottom" >Date of Examination</td>
      <td valign="bottom" >Time of Examination</td>
      <td valign="bottom" >Room #</td>
    </tr>
    <tr>
      <td height="21">&nbsp;</td>
      <td ><input name="exam_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("exam_date")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('question.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        <font size="1">(mm/dd/yyyy)</font> </td>
      <td ><input name="textfield4" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
        <input name="textfield5" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		 <select name="select3">
          <option>AM</option>
          <option>PM</option>
        </select>
        to
        <input name="textfield42" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
        <input name="textfield52" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		 <select name="select6">
          <option>AM</option>
          <option>PM</option>
        </select></td>
      <td ><input name="textfield43" type="text" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td >&nbsp;</td>
      <td ><img src="../../../images/form_proceed.gif" width="81" height="21"></td>
      <td >&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" colspan="2" bgcolor="#B9B292"><div align="center">EXAMINATION
          RESULT FOR SUBJECT <strong>$subject </strong>SECTION <strong>$section</strong>
          FOR <strong>$exam_period</strong> EXAMINATION</div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="10%" height="21" rowspan="2"><div align="center"><font size="1">STUDENT
          ID</font></div></td>
      <td width="22%" rowspan="2"><div align="center"><font size="1">STUDENT NAME</font></div></td>
      <td width="20%" rowspan="2" align="center"><font size="1">COURSE/MAJOR</font></td>
      <td width="4%" rowspan="2"><div align="center"><font size="1">YEAR</font></div></td>
      <td colspan="5"><div align="center"><font size="1">QUESTION ASKED</font></div></td>
      <td colspan="5"><div align="center"><font size="1">CORRECT ANSWER</font></div></td>
      <td width="7%" rowspan="2"><div align="center"><font size="1">TOTAL SCORE</font></div></td>
      <td width="7%" rowspan="2"><div align="center"><font size="1">PERCENT-AGE
          (%) </font></div></td>
    </tr>
    <tr>
      <td width="3%" align="center">I</td>
      <td width="3%" align="center">II</td>
      <td width="3%" align="center">III</td>
      <td width="3%" align="center">IV</td>
      <td width="3%" align="center">V</td>
      <td width="3%" align="center">I</td>
      <td width="3%" align="center">II</td>
      <td width="3%" align="center">III</td>
      <td width="3%" align="center">IV</td>
      <td width="3%" align="center">V</td>
    </tr>
    <tr>
      <td height="25"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td></td>
      <td align="center"><input name="textfield7510" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield759" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield758" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield757" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield756" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield755" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield754" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield753" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield752" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield75" type="text" size="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td align="center"><input name="textfield7511" type="text" size="3" class="textbox_noborder"></td>
      <td align="center"><input name="textfield7512" type="text" size="3" class="textbox_noborder"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="71%" height="25"><div align="center"><img src="../../../images/save.gif" width="48" height="28"><font size="1">click
          to save entries</font></div></td>
      <td width="29%"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
        to print this page</font></td>
    </tr>

<%
		}//if subject list is not null;
	}//if vSubSection != null
%>



  </table>
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
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">

 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
