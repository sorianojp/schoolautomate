<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COURSES CURRICULUM</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,OLExam.OLETakeExam, java.util.Vector" %>
<%
 	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
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
	
OLETakeExam oleTakeExam = new OLETakeExam();	
Vector vExamResult = oleTakeExam.submitExam(dbOP, request);
if(vExamResult == null || vExamResult.size() ==0)
	strErrMsg = oleTakeExam.getErrMsg();
dbOP.cleanUP();
String[] astrConvertTestNo = {"I","True/False","II","Multiple choice","III","Matching type","IV","Objective","V","Essay"};
int iQTypeIndex = 0;
float fTotalPoints = 0; 
float fTotalScore = 0;

%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#47768F"> 
      <td height="25" colspan="5" ><div align="center"><strong><font color="#FFFFFF">:: 
          ONLINE EXAMINATION - TAKE EXAM - RESULT ::</font></strong></div></td>
    </tr>
    
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
<%
if(strErrMsg != null){%>
	<tr> 
      <td>&nbsp;</td>
      <td colspan="4"><%=strErrMsg%></td>
    </tr>
<%
return;
}%>	
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="31%"> <strong><%=request.getParameter("stud_id")%></strong></td>
      <td width="13%">Name</td>
      <td width="42%"><strong><%=request.getParameter("stud_name")%></strong></td>
    </tr>
    <tr> 
      <td colspan="5"><hr></td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"><strong><%=request.getParameter("e_type")%> 
          Examination </strong></div></td>
    </tr>
    <tr> 
      <td height="21" colspan="5"><div align="center"><strong><%=request.getParameter("sub_code")%> 
          - <%=request.getParameter("sub_name")%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="5"><div align="center"><strong>Section <%=request.getParameter("section")%> 
          : Room # <%=request.getParameter("room_no")%> : <%=request.getParameter("start_time")%> 
          - <%=request.getParameter("end_time")%> (<%=request.getParameter("mins")%> 
          mins)</strong></div></td>
    </tr>
	</table>
	 
  <table width="100%" border="1" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#BECED3"> 
      <td height="25" colspan="4"><div align="center">EXAMINATION RESULTS</div></td>
    </tr>
    <tr> 
      <td width="18%" height="25"><div align="center">TEST #</div></td>
      <td width="24%"><div align="center">TEST TYPE</div></td>
      <td width="28%"><div align="center">TOTAL POINTS</div></td>
      <td width="30%" height="25"><div align="center">YOUR SCORE</div></td>
    </tr>
 <%
 for(int i = 0; i< vExamResult.size(); ++i){
 //System.out.println(vExamResult.elementAt(i+1));
 //System.out.println(vExamResult.elementAt(i+3));
 //System.out.println(vExamResult.elementAt(i));
 
 
 iQTypeIndex =Integer.parseInt( (String)vExamResult.elementAt(i)); 
 fTotalPoints += Float.parseFloat((String)vExamResult.elementAt(i+1)); 
 fTotalScore += Float.parseFloat((String)vExamResult.elementAt(i+3)); 
 %>
    <tr> 
      <td height="25"><div align="center"><%=astrConvertTestNo[(iQTypeIndex-1)*2]%></div></td>
      <td align="center"><%=astrConvertTestNo[(iQTypeIndex-1)*2 + 1]%></td>
      <td align="center"><%=(String)vExamResult.elementAt(i+1)%></td>
      <td align="center"><%=(String)vExamResult.elementAt(i+3)%></td>
    </tr>
<%
i = i+3; 
}%>
    <tr> 
      <td  colspan="2"height="25">TOTAL SCORE : <strong><%=fTotalScore%></strong></td>
      <td  colspan="2" height="25">PERCENTAGE : <strong><%=CommonUtil.calculatePercentage(fTotalPoints,fTotalScore)%></strong></td>
    </tr>
  </table>

  <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="2">&nbsp;</td>
    </tr>

    <tr> 
      <td colspan="2"><div align="center"> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#47768F">&nbsp;</td>
    </tr>
  </table>

</body>
</html>
