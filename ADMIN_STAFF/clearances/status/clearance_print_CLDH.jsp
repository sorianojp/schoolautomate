<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

.leftBorder {
	border-left: dashed #000000 1px;
}
.style1 {font-size: 11px}
-->
</style>
</head>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	Vector vBasicInfo = null;

	String strErrMsg = null;
	String strTemp = null;


	//put in session - not using URL/post.	
	HttpSession curSession = request.getSession(false);
	String strStudID = (String)curSession.getAttribute("stud_id");

//add security here.
	try {
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
//authenticate this user.
if(strStudID == null)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
String strClearanceNo = null;

vBasicInfo = OAdm.getStudentBasicInfo(dbOP, strStudID);
if(vBasicInfo == null)
	strErrMsg = OAdm.getErrMsg();
else{
	strClearanceNo = SOA.autoGenClearanceNum(dbOP, (String)vBasicInfo.elementAt(12),
                                    (String)curSession.getAttribute("sy_from"),
									(String)curSession.getAttribute("semester"));
}

boolean bolFinalClearance = WI.fillTextValue("print_credentials").equals("1");


String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};
%>
<body <%if(strErrMsg == null){%> onLoad="window.print();"<%}%> topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr><td width="44%">
<!--- start of one print .. -->
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="100%"><div align="center"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
            <font size="1">
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
            <%=astrConvertTerm[Integer.parseInt((String)curSession.getAttribute("semester"))]%> , <%=curSession.getAttribute("sy_from")+"-"+curSession.getAttribute("sy_to")%> 
			</font></div></td>
  </tr>
</table>
<%if(strErrMsg != null || vBasicInfo == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%dbOP.cleanUP(); return;}

 if (bolFinalClearance){ 
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td height="18" colspan="5" align="center"><b>CLEARANCE</b>
        <div align="center"></div></td></tr>
    <tr>
      <td height="24" colspan="5" align="center" valign="bottom"><strong>FOR RELEASING OF CREDENTIALS </strong></td>
      </tr>
    <tr>
      <td height="10" align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
      <td height="18" align="right" valign="bottom">&nbsp;</td>
      <td align="right" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td width="28%" height="20" align="right">TRANSFER&nbsp;</td>
      <td width="6%" align="right" valign="bottom" style="border:#000000 1px 1px 1px 1px solid;">&nbsp;</td>
      <td width="46%" align="right">GRADUATE&nbsp;</td>
      <td width="6%" height="20" align="right" valign="bottom" 
	  		style="border:#000000 1px 1px 1px 1px solid;">&nbsp;</td>
      <td width="14%" align="right" valign="bottom">&nbsp;</td>
    </tr>	
</table>
<%}%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="24%" height="18">Stud. No.</td>
      <td width="88%">: &nbsp;<%=strStudID%></strong></td>
    </tr>
    <tr>
      <td width="24%" height="18">Name</td>
      <td width="88%">: &nbsp;<%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
    </tr>
    <tr>
      <td height="18">Year Level</td>
      <td>: &nbsp;<%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
    </tr>
    <tr>
      <td height="18">Course</td>
      <td>: &nbsp;<%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<% if (!bolFinalClearance) {%>     
    <tr>
      <td height="25">LIBRARY</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="25">DEAN</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="25">ACCOUNTING</td>
      <td>&nbsp;________________________</td>
    </tr>

    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2">This certifies that I am already cleared of all liabilities and accountabilities </td>
      </tr>

    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2">Student's Copy </td>
    </tr>
    <tr>
      <td height="18" colspan="2">&nbsp;<span style="font-size:14px"><strong><%=strClearanceNo%></strong></span></td>
    </tr>
    <tr>
      <td colspan="2" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2">Prepared by : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td height="18" colspan="2"><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),4)%></td>
    </tr>
<%}else{%> 	
    <tr>
      <td height="18">SAO</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">LIBRARY</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">DEAN</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">ACCOUNTING</td>
      <td>&nbsp;________________________</td>
    </tr>

    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="2"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
          <td height="10" colspan="3" align="center"><span class="style1">
		  	<u>TO BE FILLED UP BY THE CASHIER<u> </span></td>
        </tr>
        <tr>
          <td width="32%" height="18"><span class="style1"></span></td>
          <td width="32%" height="18" align="center">
		  			<span class="style1"><u>OR NO </u></span></td>
          <td width="36%" align="center"><span class="style1"><u>AMOUNT</u></span></td>
        </tr>
        <tr>
          <td height="14" class="style1">&nbsp;</td>
          <td height="14" align="center" class="style1">&nbsp;</td>
          <td height="14" align="center" class="style1">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" class="style1">TUITION </td>
          <td height="14" align="center" class="style1">______________</td>
          <td height="14" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="18" class="style1">GRAD FEE</td>
          <td height="18" align="center" class="style1">______________</td>
          <td height="18" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="18" class="style1">YEARBOOK </td>
          <td height="18" align="center" class="style1">______________</td>
          <td height="18" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="10" colspan="3" align="right"><%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td height="18" align="right">&nbsp;</td>
          <td height="18" align="right">&nbsp;</td>
          <td height="18" align="center" class="style1">CLEARANCE NO.  </td>
        </tr>
        <tr>
          <td height="18" colspan="2"><strong>Student's Copy </strong></td>
          <td height="18" align="center"><span style="font-size:14px"><strong><%=strClearanceNo%></strong></span></td>
        </tr>
      </table></td>
      </tr>
<%}%> 
  </table>
</td>

<td width="12%">&nbsp;</td>
<td width="44%">
<!----------- Another copy ----------- print 2 copies at one time ---------------------------->
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="100%"><div align="center"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            <font size="1">
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
            <%=astrConvertTerm[Integer.parseInt((String)curSession.getAttribute("semester"))]%> , <%=curSession.getAttribute("sy_from")+"-"+curSession.getAttribute("sy_to")%> 
			</font></div></td>
  </tr>
</table>
<%if(strErrMsg != null || vBasicInfo == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%dbOP.cleanUP(); return;}

 if (bolFinalClearance){ 
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="18" colspan="5" align="center"><b>CLEARANCE</b>
      <div align="center"></div></td>
  </tr>
  <tr>
    <td height="24" colspan="5" align="center" valign="bottom"><strong>FOR RELEASING OF CREDENTIALS </strong></td>
  </tr>
  <tr>
    <td height="10" align="right" valign="bottom">&nbsp;</td>
    <td align="right" valign="bottom">&nbsp;</td>
    <td align="right" valign="bottom">&nbsp;</td>
    <td height="18" align="right" valign="bottom">&nbsp;</td>
    <td align="right" valign="bottom">&nbsp;</td>
  </tr>
  <tr>
    <td width="28%" height="20" align="right">TRANSFER&nbsp;</td>
    <td width="6%" align="right" valign="bottom" style="border:#000000 1px 1px 1px 1px solid;">&nbsp;</td>
    <td width="46%" align="right">GRADUATE&nbsp;</td>
    <td width="6%" height="20" align="right" valign="bottom" 
	  		style="border:#000000 1px 1px 1px 1px solid;">&nbsp;</td>
    <td width="14%" align="right" valign="bottom">&nbsp;</td>
  </tr>
</table>
<%}%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td width="24%" height="18">Stud. No.</td>
    <td width="76%">: &nbsp;<%=strStudID%></strong></td>
  </tr>
  <tr>
    <td width="24%" height="18">Name</td>
    <td width="76%">: &nbsp;<%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
  </tr>
  <tr>
    <td height="18">Year Level</td>
    <td>: &nbsp;<%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
  </tr>
  <tr>
    <td height="18">Course</td>
    <td>: &nbsp;<%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
  </tr>
  <tr>
    <td height="18">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
<% if (!bolFinalClearance) {%>    
  <tr>
    <td height="25">LIBRARY</td>
    <td>&nbsp;________________________</td>
  </tr>
  <tr>
    <td height="25">DEAN</td>
    <td>&nbsp;________________________</td>
  </tr>
  <tr>
    <td height="25">ACCOUNTING</td>
    <td>&nbsp;________________________</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="18" colspan="2">This certifies that I am already cleared of all liabilities and accountabilities </td>
    </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td height="18" colspan="2">Accounting's Copy </td>
  </tr>
  <tr>
    <td height="18" colspan="2"><strong>&nbsp;<span style="font-size:14px"><%=strClearanceNo%></span></strong></td>
  </tr>
    <tr>
      <td colspan="2" align="right">&nbsp;</td>
    </tr>
    <tr>
      <td height="18" colspan="2">Prepared by : &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getTodaysDateTime()%></td>
    </tr>
    <tr>
      <td height="18" colspan="2"><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),4)%></td>
    </tr>
<%}else{%> 	
    <tr>
      <td height="18">SAO</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">LIBRARY</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">DEAN</td>
      <td>&nbsp;________________________</td>
    </tr>
    <tr>
      <td height="18">ACCOUNTING</td>
      <td>&nbsp;________________________</td>
    </tr>

    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

    <tr>
      <td height="10" colspan="2" align="center"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
          <td height="10" colspan="3" align="center"><span class="style1"><u>TO BE FILLED UP BY THE CASHIER </u></span></td>
        </tr>
        <tr>
          <td width="32%" height="18"><span class="style1">&nbsp;</span></td>
          <td width="32%" height="18" align="center"><span class="style1"><u>OR NO </u></span></td>
          <td width="36%" align="center"><span class="style1"><u>AMOUNT</u></span></td>
        </tr>
        <tr>
          <td height="14" class="style1">&nbsp;</td>
          <td height="14" align="center" class="style1">&nbsp;</td>
          <td height="14" align="center" class="style1">&nbsp;</td>
        </tr>
        <tr>
          <td height="14" class="style1">TUITION </td>
          <td height="14" align="center" class="style1">______________</td>
          <td height="14" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="18" class="style1">GRAD FEE</td>
          <td height="18" align="center" class="style1">______________</td>
          <td height="18" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="18" class="style1">YEARBOOK </td>
          <td height="18" align="center" class="style1">______________</td>
          <td height="18" align="center" class="style1">______________</td>
        </tr>
        <tr>
          <td height="10" colspan="3" align="right"><%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
        </tr>
        <tr>
          <td height="18" align="right">&nbsp;</td>
          <td height="18" align="right">&nbsp;</td>
          <td height="18" align="center" class="style1">CLEARANCE NO.</td>
        </tr>
        <tr>
          <td height="18" colspan="2"><strong>Registrar's Copy </strong></td>
          <td height="18" align="center"><span style="font-size:14px"><strong><%=strClearanceNo%></strong></span></td>
        </tr>
      </table></td>
      </tr>
<%}%> 
</table></td>
</tr>
</table>
</body>
</html>

<%
//remove information from session.
		curSession.removeAttribute("stud_id");
		curSession.removeAttribute("sy_from");
		curSession.removeAttribute("sy_to");
		curSession.removeAttribute("semester");
		curSession.removeAttribute("type_index");
dbOP.cleanUP();
%>