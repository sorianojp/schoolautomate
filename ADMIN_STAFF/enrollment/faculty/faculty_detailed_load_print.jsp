<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}


-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.FacultyManagement,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Faculty-load print","faculty_detailed_load_print.jsp");
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

	FacultyManagement FM = new FacultyManagement();
	Vector vRetResult = null;
	Vector vUserDetail = FM.viewFacultyDetail(dbOP,WI.fillTextValue("ui"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	if(vUserDetail == null)
		strErrMsg = FM.getErrMsg();
	else
	{
		vRetResult = FM.viewFacultyLoadDetail(dbOP,WI.fillTextValue("ui"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		if(vRetResult == null)
			strErrMsg = FM.getErrMsg();
	}
if(strErrMsg == null) strErrMsg = "";
//dbOP.cleanUP();
if(strErrMsg.length() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="2%" height="25">&nbsp;</td>
    <td><strong><%=strErrMsg%></strong></td>
  </tr>
</table>
<%dbOP.cleanUP();return;}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="30"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,true)%>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong><%=WI.getStrValue(vUserDetail.elementAt(4))%><br>
        <%=WI.getStrValue(vUserDetail.elementAt(5))%></strong></div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><strong> FACULTY LOAD/SCHEDULE<br>
        </strong>School Offering year - <%=request.getParameter("sy_from")%> to <%=request.getParameter("sy_to")%></div></td>
    </tr>
    <tr>
      <td height="10"><div align="center"></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>

    <td width="28%" height="25">Employee ID: <strong><%=(String)vUserDetail.elementAt(0)%></strong></td>

    <td width="70%">Employee Name : <strong><%=(String)vUserDetail.elementAt(1)%></strong></td>
    </tr>
    <tr>

    <td height="25">Gender : <strong><%=(String)vUserDetail.elementAt(3)%></strong></td>

    <td>Employment Status : <strong><%=(String)vUserDetail.elementAt(2)%></strong></td>
    </tr>
    <tr>

    <td height="25">TOTAL UNITS LOAD : <strong><%=(String)vUserDetail.elementAt(6)%></strong></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center"><strong>MONDAY</strong></td>
    <td align="center"><strong>TUESDAY</strong></td>
    <td align="center"><strong>WEDNESDAY</strong></td>
    <td align="center"><strong>THURSDAY</strong></td>
    <td align="center"><strong>FRIDAY</strong></td>
    <td height="25" align="center"><strong>SATURDAY</strong></td>
    <td align="center"><strong>SUNDAY</strong></td>
  </tr>
  <%
	String[] convertAMPM={" am"," pm"};
for(int i = 0; i< vRetResult.size();){%>
  <tr>
    <%strTemp = "";
		  while( ((String)vRetResult.elementAt(i)).compareTo("1") ==0) //this is monday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center" height="25"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while( vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("2") ==0) //this is Tuesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
		  			(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("3") ==0) //this is Wednesday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("4") ==0) //this is Thursday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("5") ==0) //this is Friday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("6") ==0) //this is Saturday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
    <%strTemp = "";
		  while(vRetResult.size() > 10 && ((String)vRetResult.elementAt(i)).compareTo("0") ==0) //this is Sunday
		  {if(strTemp.length() > 0) strTemp += "<br>";
		  	strTemp += WI.getStrValue(vRetResult.elementAt(i+12),"<br>","")+
					(String)vRetResult.elementAt(i+1)+":"+(String)vRetResult.elementAt(i+2)+
					convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+3))]+" to "+(String)vRetResult.elementAt(i+4)+
					":"+(String)vRetResult.elementAt(i+5)+ convertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))]+"<br>Section: "+
					(String)vRetResult.elementAt(i+7)+"<br> Room#."+WI.getStrValue((String)vRetResult.elementAt(i+8))+"<br> Subject:"+
					(String)vRetResult.elementAt(i+9)+"("+(String)vRetResult.elementAt(i+10)+")";
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
			vRetResult.removeElementAt(i);
			}%>
    <td align="center"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
  </tr>
  <%
	//i = i+9;
	}%>
</table>
 <script language="JavaScript">
	window.print();
alert("Press any key to start printing.");
window.setInterval("javascript:window.close();",0);
 </script>

</body>
</html>

