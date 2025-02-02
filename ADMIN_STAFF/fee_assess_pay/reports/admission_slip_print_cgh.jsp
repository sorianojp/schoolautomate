<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<script src="../../../jscript/common.js"></script>
<body onLoad="CloseWnd();">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vRetResult = null;
Vector vStudDetail= null;
String strGrYearLevel = "";
int iGrYearLevel = Integer.parseInt(WI.getStrValue(WI.fillTextValue("gr_year_level"),"0"));

ReportEnrollment reportEnrl= new ReportEnrollment();
vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("offering_sem"));


if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else {
	vStudDetail = (Vector)vRetResult.elementAt(0);
}

//1 = midterm, 2 = final.. 
String strPmtSchedule = WI.fillTextValue("pmt_schedule");

if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}
	int iMaxRows = 11;
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="100%" height="28">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;
	<%if(!strPmtSchedule.equals("1")){%>XXXXXX<%}else{%>
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	XXXXXX
	<%}%>
	</td>
  </tr>
</table>
<table width="90%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%strTemp = WI.fillTextValue("sy_from");
strTemp = strTemp.substring(2);
strTemp = strTemp + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+
	Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from")) + 1).substring(2)  ;
	%><%=strTemp%>
</td>
  </tr>
  <tr> 
    <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<%=(String)vStudDetail.elementAt(4)%></td>
  </tr>
  <tr> 
    <td height="25" valign="top"><%=(String)vStudDetail.elementAt(2)%></td>
  </tr>
</table><br>	

<table width="100%" cellpadding="0" cellspacing="0" >
  <tr> 
    <td height="10"  width="61%">&nbsp;</td>
    <td  align="center">&nbsp;</td>
  </tr>
  <%
 int iTotalLoad = 0;//System.out.println(vRetResult);
 int iIndex = 0;int i = 0; 
 for( iIndex=1,i=1; i< vRetResult.size(); i += 11, iIndex++){
 //do not show the re-enrolled subjects. 
 strTemp =(String)vRetResult.elementAt(i+1);
 if (strTemp.length() > 40)	strTemp = strTemp.substring(0,38)+"..";
 %>
  <tr style="font-size:9px;"> 
    <td width="61%" height="17"><%=(String)vRetResult.elementAt(i)%></td>
    <td  align="center">&nbsp; <%if( vRetResult.elementAt(i + 2) != null && ((String)vRetResult.elementAt(i + 2)).compareTo("N/A") == 0){%>
      xxxxxxxxx re-enrolled xxxxxxxxx 
      <%}%> </td>
  </tr>
  <%}%>
</table>
<script language="JavaScript">
//get this from common.js
//this.autoPrint();

//this.closeWnd = 1;
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>
