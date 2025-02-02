<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
 	document.bgColor = "#FFFFFF";
    document.getElementById('myADTable1').deleteRow(0);
	
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
	
    document.getElementById('myADTable3').deleteRow(0);
    document.getElementById('myADTable3').deleteRow(0);
	
    alert("Click OK to print this page");
 	window.print();//called to remove rows, make bk white and call print.
}
function SetCourseName() {
	document.form_.course_name.value = document.form_.course_index[document.form_.course_index.selectedIndex].text;
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
//end of authenticaion code.

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_from2").length() > 0) {//this is time to call tuition comparison
	enrollment.ReportFeeAssessment rfa = new enrollment.ReportFeeAssessment();
	vRetResult  = rfa.compareTuitionFee(dbOP, request);
	if(vRetResult == null) {
		strErrMsg = rfa.getErrMsg();	
		%>
		<p style="font-size:14px; font-family:Geneva, Arial, Helvetica, sans-serif; color:#FF0000"><%=strErrMsg%></p>
		<%
		dbOP.cleanUP();
		return;
	}
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
int iSLNo = 0; 
int iPgCount = 0; 
int iDef = Integer.parseInt( WI.getStrValue(WI.fillTextValue("rows_pg"),"30"));

double dTotalCur = 0d; double dTotalPrev = 0d; double dTotalDiff = 0d; double dCurPerPg = 0d; double dPrevPerPg = 0d; double dDiffPerPg =0d;
if(vRetResult != null && vRetResult.size() > 0) {
	for(int i = 0; i < vRetResult.size();) {
	iPgCount = 0; dCurPerPg = 0d; dPrevPerPg = 0d; dDiffPerPg =0d;
	%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  <td width="5%" height="20"><div align="center"><font size="1">DIFFERENCE 
			  OF TUITION FEE INCREASE<br>
			  <%=WI.fillTextValue("sy_from")%> v/s <%=WI.fillTextValue("sy_from2")%><br>
			  <strong>
			  <% if(WI.fillTextValue("yr_level").length() > 0){%>
			  	<%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.fillTextValue("yr_level")))%>
			  <%}else{%>
			  	<%=dbOP.getResultOfAQuery("select edu_level_name from BED_LEVEL_INFO where edu_level = "+WI.fillTextValue("edu_level"), 0)%>
			  <%}%>
			  </strong><br>
			  </font> </div></td>
		</tr>
		<tr> 
		  <td height="20">&nbsp;</td>
		</tr>
	  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#cccccc"> 
      <td width="5%" height="19" class="thinborder"><div align="center"><font size="1"><strong>SL # </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Student ID </strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>Student Name </strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Course</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>Current Tuition </strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>Previous Tuition </strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>Difference</strong></font></div></td>
    </tr>
    <%
	for(; i < vRetResult.size(); i += 6){//System.out.println(vRetResult.elementAt(i + 2));%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=++iSLNo%></td>
      <td height="20" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=dbOP.getBasicEducationLevel(Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 2), "0")), true)%></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 3)).doubleValue(), true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 4)).doubleValue(), true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 5)).doubleValue(), true)%></div></td>
    </tr>
    <%
		dCurPerPg  += ((Double)vRetResult.elementAt(i + 3)).doubleValue(); 
		dPrevPerPg += ((Double)vRetResult.elementAt(i + 4)).doubleValue(); 
		dDiffPerPg += ((Double)vRetResult.elementAt(i + 5)).doubleValue();
		
		++iPgCount; 
		if(iPgCount == iDef) {
			i += 6;
			break;
		}
	}
	dTotalCur += dCurPerPg; dTotalPrev += dPrevPerPg;  dTotalDiff += dDiffPerPg;
	%>
    <tr> 
      <td height="20" colspan="4" class="thinborder"><div align="right">Sub total(per pg) : &nbsp;</div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dCurPerPg, true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dPrevPerPg, true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dDiffPerPg, true)%></div></td>
    </tr>
  </table>
<%if(iPgCount == iDef){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//break only if it is not last page.

}//for condition to display header of each page.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="19" class="thinborderBOTTOMLEFT">
        <div align="right"><font size="1">TOTAL : &nbsp;</font></div></td>
      <td width="12%" class="thinborderBOTTOM"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalCur, true)%></font></div></td>
      <td width="12%" class="thinborderBOTTOM"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalPrev, true)%></font></div></td>
      <td width="12%" class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalDiff, true)%></font></div></td>
    </tr>
  </table>
<%}//if(vRetResult != null && vRetResult.size() > 0)%>
</body>
</html>
<%
dbOP.cleanUP();
%>