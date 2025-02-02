<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body>
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLESchedule,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	
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
	vExamSch = qS.getExamSchedule(dbOP,request, true);//show only the valid exam schedules.
	dbOP.cleanUP();
	
	if(vExamSch == null || vExamSch.size() ==0)
		strErrMsg = qS.getErrMsg();

%>

  <table width="100%" border="0" >
    <tr> 
      <td colspan="2"><div align="center"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">SAN 
          PEDRO COLLEGE<br>
          Davao City</font> </div></td>
    </tr>
    <tr> 
      <td height="20"  colspan="2"><div align="center"><strong><%=request.getParameter("college_name")%></strong></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25"  colspan="2"><div align="center">LIST OF EXAMINATION 
        SCHEDULES FOR SUBJECT <strong><%=request.getParameter("subject_name")%> 
        </strong>FOR<strong> <%=request.getParameter("exam_period_name")%> </strong>EXAMINATION</div></td>
    </tr>
 <%
 if(strErrMsg != null)
 {%>
    
    <tr> 
      <td colspan="2"><%=strErrMsg%></td>
    </tr>
<%}%>
  </table>
<%
if(vExamSch != null && vExamSch.size() >0)
{%>  
	
  <table width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="10%" height="21"><div align="center"><font size="1">EXAM ID</font></div></td>
      <td width="17%" height="21"><div align="center"><font size="1">EXAMINER NAME</font></div></td>
      <td width="10%"><div align="center"><font size="1">SECTION</font></div></td>
      <td width="8%"><div align="center"><font size="1">BATCH</font></div></td>
      <td width="10%"><div align="center"><font size="1">ROOM #</font></div></td>
      <td width="15%"><div align="center"><font size="1">ROOM LOCATION</font></div></td>
      <td width="10%"><div align="center"><font size="1">DURATION</font></div></td>
      <td width="15%"><div align="center"><font size="1">DATE OF EXAM (mm/dd/yyyy)</font></div></td>
      <td width="10%"><div align="center"><font size="1">EXAM TIME</font></div></td>
    </tr>
<%
String[] astrConvertAMPM = {"AM","PM"};
String[] astrConvertBatch={"N/A","Batch 1","Batch 2","Batch 3"};
for(int i=0; i< vExamSch.size(); ++i){%>
    <tr> 
      <td height="25" align="center"><font size="1"><%=(String)vExamSch.elementAt(i+12)%></font></td>
	  <td height="25" align="center"><font size="1"><%=(String)vExamSch.elementAt(i+1)%> - <%=(String)vExamSch.elementAt(i+2)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+3)%></font></td>
	  <td align="center"><font size="1"><%=astrConvertBatch[Integer.parseInt((String)vExamSch.elementAt(i+11))]%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+4)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+5)%></font></td>
      <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+6)%> mins</font></td>
	  <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+7)%></font></td>
	  <td align="center"><font size="1"><%=(String)vExamSch.elementAt(i+8)%>:<%=(String)vExamSch.elementAt(i+9)%> <%=astrConvertAMPM[Integer.parseInt((String)vExamSch.elementAt(i+10))]%></font></td>
    </tr>
<%
i = i+12;
}%>
  </table>

<%
}//vExamSched is not null. 
%>  

<script language="JavaScript">
window.print();
	
</script>
</body>
</html>
