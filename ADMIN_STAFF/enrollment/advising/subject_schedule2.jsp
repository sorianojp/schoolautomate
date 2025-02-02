<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Schedule Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function copyValueToParent()
{
	eval('window.opener.document.'+document.subschedule.form_name.value+'.'+document.subschedule.sec_index_name.value+'.value=\"'+document.subschedule.sub_sec_index.value+'\"');
	eval('window.opener.document.'+document.subschedule.form_name.value+'.'+document.subschedule.sec_name.value+'.value=\"'+document.subschedule.sec_name_value.value+'\"');

	window.close();
}
function AssignSecIndex(subSecIndex,section)
{
	document.subschedule.sub_sec_index.value = subSecIndex;
	document.subschedule.sec_name_value.value = section;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous
	//selected schedule

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//end of security code.
String strCurIndex = request.getParameter("cur_index");
//strCurIndex = "88";
String strSYFrom = request.getParameter("syf");
String strSYTo = request.getParameter("syt");

Advising advising = new Advising();
Vector vSectionDetail = new Vector();
Vector vSchedule = new Vector();
Vector vSubInfo = advising.getSubjectInfo(dbOP,strCurIndex );
if(vSubInfo == null)
	strErrMsg = advising.getErrMsg();
else /// do all processing here.
{
	vSectionDetail = advising.getSubSectionDetail(dbOP,strCurIndex,strSYFrom,strSYTo);
	if(vSectionDetail == null || vSectionDetail.size() == 0)
		strErrMsg = advising.getErrMsg();
}



%>
<form name="subschedule">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SUBJECT SCHEDULE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null)
{%>	<tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td><%=strErrMsg%></td>

    </tr>
<%dbOP.cleanUP();return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td  width="2%" height="25">&nbsp;</td>
      <td width="28%" height="25">Code: <strong><%=(String)vSubInfo.elementAt(0)%></strong></td>
      <td  colspan="3" height="25">Name: <strong><%=(String)vSubInfo.elementAt(1)%></strong></td>
      <td width="33%">Category: <strong><%=(String)vSubInfo.elementAt(2)%></strong></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Lec. units :<strong><%=(String)vSubInfo.elementAt(3)%></strong></td>
      <td width="37%" height="25">Lab. units :<strong><%=(String)vSubInfo.elementAt(4)%></strong></td>
      <td colspan="2" width="33%" height="25">Total units :<strong><%=Float.parseFloat((String)vSubInfo.elementAt(3))+Float.parseFloat((String)vSubInfo.elementAt(4))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td colspan="6" height="25">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">SUBJECT
          SCHEDULES </div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" height="25">&nbsp;</td>
      <td width="16%" height="25" colspan="6">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="11%"><div align="center"><strong><font size="1">SUBJECT CODE</font></strong></div></td>
      <td width="5%"><div align="center"><strong><font size="1">LEC/LAB</font>
          </strong></div></td>
      <td width="8%" height="25"><div align="center"><strong><font size="1">SECTION</font></strong></div></td>
      <td width="19%"><div align="center"><font size="1"><strong>SCHEDULE (Days/Time)
          </strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>COURSE OFFERING
          THE SUBJECT</strong></font></div></td>
      <td width="5%"><div align="center"><font size="1"><strong>REGULAR / IRREGULAR</strong></font></div></td>
      <td width="5%"><div align="center"><strong><font size="1">MAX. NO. OF STUDENTS</font></strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>NO. OF STUDENTS
          ENROLLED</strong></font></div></td>
      <td width="3%"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="17%"><div align="center"><font size="1"><strong>SELECT</strong></font></div></td>
    </tr>
    <%
strTemp = "Open";//System.out.println(vSectionDetail.size());
for(int i=0; i< vSectionDetail.size(); ++i){
if(Integer.parseInt((String)vSectionDetail.elementAt(i+6)) <= Integer.parseInt((String)vSectionDetail.elementAt(i+7)))
	strTemp = "Closed";
 %>
    <tr bgcolor="#FFFFFF">
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td height="25" align="center"><%=(String)vSectionDetail.elementAt(i+2)%></td>
      <td align="center"> <%=advising.getSubjectScheduleTime(dbOP,(String)vSectionDetail.elementAt(i+1),request.getParameter("sec_index_list"),bolConflict)%>
      </td>
      <td align="center"><%=(String)vSectionDetail.elementAt(i+3)%></td>
      <td align="center"><%=(String)vSectionDetail.elementAt(i+4)%>/<%=(String)vSectionDetail.elementAt(i+5)%></td>
      <td align="center"><%=(String)vSectionDetail.elementAt(i+6)%></td>
      <td align="center"><%=(String)vSectionDetail.elementAt(i+7)%></td>
      <td align="center"><%=strTemp%></td>
      <td><div align="center">
          <!-- do not show the radio button if it is a conflict -->
          <%if(!bolConflict[0]){%>
          <input type="radio" name="radiobutton" value="radiobutton" onClick='AssignSecIndex("<%=(String)vSectionDetail.elementAt(i+1)%>","<%=(String)vSectionDetail.elementAt(i+2)%>")'>
          <%}else{%>
          Conflict
          <%
		bolConflict[0] = false;}%>
        </div></td>
    </tr>
    <%	i = i+7;}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <td width="12%"></tr>
    <tr bgcolor="#FFFFFF">
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="sub_sec_index" value="0">
  <input type="hidden" name="sec_name_value" value="0">

  <input type="hidden" name="form_name" value="<%=request.getParameter("form_name")%>">
  <input type="hidden" name="sec_name" value="<%=request.getParameter("sec_name")%>">
  <input type="hidden" name="sec_index_name" value="<%=request.getParameter("sec_index_name")%>">
  <input type="hidden" name="sec_index_list" value="<%=request.getParameter("sec_index_list")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
