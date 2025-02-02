<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,enrollment.Advising,enrollment.CurriculumMaintenance,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strPrintedBy = null;
	String strCollegeName = null;
	String[] astrSchYrInfo = null;
	boolean bolFatalErr = false;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

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

//get here the list of advised subjects.
Advising advising = new Advising();
Vector vAdvisedList = new Vector();
Vector vStudInfo    = new Vector();
Vector vTemp = null;

String strMaxAllowedLoad = null;
String strOverLoadDetail = null;

String strStudIndex = null;
String strStudID	= WI.fillTextValue("stud_id");
if(strStudID.length() ==0)
	strStudID = WI.fillTextValue("temp_id");

String strIsTempStud = "0";//old
astrSchYrInfo 		= dbOP.getCurSchYr();
if(astrSchYrInfo == null)//db error
{
	strErrMsg = dbOP.getErrMsg();
	bolFatalErr = true;
}
if(strStudID.length() == 0)
{
	strErrMsg = "Student ID can't be empty.";
	bolFatalErr = true;
}
//get student information first.
if(!bolFatalErr)
{
	vTemp = advising.getOldStudInfo(dbOP,strStudID,astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vTemp == null || vTemp.size() ==0)
	{
		vTemp = advising.getTempStudInfo(dbOP,strStudID);
		if(vTemp != null && vTemp.size() > 0)//temporary student.
		{
			vStudInfo.addElement(vTemp.elementAt(10));//index.
			vStudInfo.addElement(WebInterface.formatName((String)vTemp.elementAt(0),(String)vTemp.elementAt(1),(String)vTemp.elementAt(2),1));//name
			vStudInfo.addElement(vTemp.elementAt(6));//course inde.x
			vStudInfo.addElement(vTemp.elementAt(8));//major index.
			vStudInfo.addElement(vTemp.elementAt(3));//cy from.
			vStudInfo.addElement(vTemp.elementAt(4));//cy to.
			vStudInfo.addElement(vTemp.elementAt(12));//year level.
			vStudInfo.addElement(vTemp.elementAt(5));//course name,
			vStudInfo.addElement(vTemp.elementAt(7));//major name
			vStudInfo.addElement(vTemp.elementAt(11));//is_enrolled.

			strIsTempStud = "1";
			strStudIndex = (String)vTemp.elementAt(10);//nothing else to format.
		}
	}
	else//old student.
	{
		strStudIndex = (String)vTemp.elementAt(0);//nothing else to format.
		vStudInfo = vTemp;
	}
	if(vTemp == null)
	{
		bolFatalErr = true;
		strErrMsg = "Student enrolling information not found.";
	}
}

//get the student's advised schedule information.
if(!bolFatalErr)
{
	vAdvisedList = advising.getAdvisedList(dbOP, strStudIndex,strIsTempStud,(String)vStudInfo.elementAt(2),
						astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vAdvisedList == null)
	{
		strErrMsg = advising.getErrMsg();
		bolFatalErr = true;
	}
}


if(!bolFatalErr)
{
	strCollegeName = new CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(2));
	strPrintedBy   = CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1);
	Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(6),astrSchYrInfo[2],(String)vStudInfo.elementAt(4),
			(String)vStudInfo.elementAt(5));
	if(vMaxLoadDetail == null)
	{
		bolFatalErr = true;
		strErrMsg = advising.getErrMsg();
	}
	else
	{
		strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
		if(vMaxLoadDetail.size() > 1)
			strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
			" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		if(strMaxAllowedLoad.compareTo("-1") ==0)
			strMaxAllowedLoad = "N/A";
	}
}
//dbOP.cleanUP();
if(bolFatalErr){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center"><%=strErrMsg%></td>
	  </tr>
  </table>
<%
  dbOP.cleanUP();
  return;
}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="7"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
          <br>
          <strong><font size="2"><%=strCollegeName%></font></strong><br>
          <br>
        <strong> <font size="2">STUDENT ENROLMENT LOAD</font></strong><br>
        <%=astrConvertSem[Integer.parseInt(astrSchYrInfo[2])]%>, School Year <%=astrSchYrInfo[0]%>-<%=astrSchYrInfo[1]%></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7"><div align="right">&nbsp; Date and time printed
          :<strong> <%=WI.getTodaysDateTime()%></strong></div></td>
    </tr>
  </table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">Student ID : <strong><%=strStudID%></strong></td>
    <td width="57%" height="25">Course / Major : <strong><%=(String)vStudInfo.elementAt(7)%>
      <%if(vStudInfo.elementAt(8) != null){%>
      / <%=(String)vStudInfo.elementAt(8)%>
      <%}%>
      </strong></td>
  </tr>
  <tr>
    <td height="25">Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    <td height="25">Curriculum SY : <strong><%=(String)vStudInfo.elementAt(4)%>
      - <%=(String)vStudInfo.elementAt(5)%></strong></td>
  </tr>
  <tr>
    <td width="43%" height="25">Student type : <strong><%=WI.fillTextValue("stud_type")%></strong></td>
    <td height="25">Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(6),"N/A")%>
      </strong></td>
  </tr>
  <tr>
    <td height="25">Student's Signature : ________________________________________________</td>
    <td height="25">Parent's Signature : ________________________________________________</td>
  </tr>
</table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>

    <td width="152%" height="10" colspan="6">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(strOverLoadDetail != null){%>
    <tr>
      <td  height="25">&nbsp;</td>
      <td colspan="6">Overload detail : <%=strOverLoadDetail%></td>
    </tr>
<%}%>
   <tr>
      <td width="9" height="25">&nbsp;</td>
      <td height="25" colspan="2">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>

    <td colspan="4" width="326" height="25" >Total student load taken: <strong><%=(String)vAdvisedList.elementAt(0)%></strong></td>
    </tr>
  </table>

<table width="100%" border="1" cellpadding="0" cellspacing="0">
  <tr>
    <td width="20%" height="25" align="center"><strong>SUBJECT CODE</strong></td>
    <td width="35%" align="center"><strong>SUBJECT NAME</strong></td>
    <td width="5%" align="center"><strong>LEC. UNITS</strong></td>
    <td width="5%" align="center"><strong>LAB. UNITS</strong></td>
    <td width="5%" align="center"><strong>TOTAL UNITS</strong></td>
    <td width="5%" align="center"><strong><font size="1">UNITS TAKEN</font></strong></td>
    <td width="5%" align="center"><strong>SECTION</strong></td>
    <td width="5%" align="center"><strong>ROOM #</strong></td>
    <td width="20%" align="center"><strong>SCHEDULE</strong></td>
  </tr>
  <%
for(int i = 1; i<vAdvisedList.size(); ++i)
{%>
  <tr>
    <td height="25"><%=(String)vAdvisedList.elementAt(i)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+1)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+6)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+7)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+8)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+9)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+3)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+4)%></td>
    <td><%=(String)vAdvisedList.elementAt(i+2)%> </td>
  </tr>
  <%
i = i+10;
}%>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">Advised and printed by : </td>
    <td height="25"><strong><u><%=strPrintedBy%></u></strong></td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td width="16%" height="25">&nbsp;</td>
    <td colspan="3" valign="top"><em>Dean / Faculty/Secretary</em></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td width="37%" height="25">&nbsp;</td>
    <td>Approved by : </td>
    <td>___________________________________</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="37%" valign="top"><em>Registrar</em></td>
  </tr>
</table>
<%
if(WI.fillTextValue("print").compareTo("0") !=0){%>
<script language="javascript">
window.print();

</script>
<%}//incase only view
%>
</body>
</html>
