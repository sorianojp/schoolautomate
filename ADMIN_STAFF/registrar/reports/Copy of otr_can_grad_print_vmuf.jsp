<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTTOPBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>

<script language="javascript">
function encodeCode(strLabel) {
	strVal = prompt('Please enter data to display','');
	if(strVal == null)
		return;
	document.getElementById(strLabel).innerHTML =  strVal;
}


function Update(strLabelID) {
	strNewVal = prompt('Please enter new Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = strNewVal;
}
function updateSubjectRow(strLabelID) {
	strNewVal = prompt('Please enter next line Value','');
	if(strNewVal == null)
		return;
	document.getElementById(strLabelID).innerHTML = document.getElementById(strLabelID).innerHTML+"<br>"+strNewVal;

}
</script>


<body topmargin="0" <%if(WI.fillTextValue("print_").equals("1")){%> onLoad="window.print();"<%}%>>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strDegreeType = null;

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));


	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	int iRowsPrinted = 0;
	int iMaxRowToDisp = Integer.parseInt(WI.fillTextValue("max_page_to_disp"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 9","rec_can_grad_print.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"rec_can_grad_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.EntranceNGraduationData eData = new enrollment.EntranceNGraduationData();
enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
student.StudentInfo studInfo = new student.StudentInfo();

Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;


if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
				(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		else {
			vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
			if(vEntranceData == null)
				strErrMsg = eData.getErrMsg();
		}
	}

}
if(strErrMsg != null){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td><font size="3"><%=strErrMsg%></font>
	</td>
  </tr>
</table>
<%dbOP.cleanUP();return;}
if(iPageNumber > 1 && false) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20">Name : 
	<%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%>
	</td>
    <td width="22%" height="20" align="right"></tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
    <td colspan="8" align="center"> 
		<font size="4">VIRGEN MILAGROSA UNIVERSITY FOUNDATION</font><br>
		<font size="1">
		Martin P. Posadas Avenue<br>
		San Carlos City, Pangasinan 2420, Philippines			</font>
      <br><br>
	  <font size="2" style="font-weight:bold">RECORDS OF CANDIDATE FOR GRADUATION</font>		</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="13%">Name: </td>
	<td width="52%" class="thinborderBOTTOM"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=((String)vStudInfo.elementAt(0)).toUpperCase()%> 
  	<%=WI.getStrValue((String)vStudInfo.elementAt(1)," ","","").toUpperCase()%></td>
	<td width="3%"> </td>
	<td width="12%">Student I.D. </td>
	<td width="20%" class="thinborderBOTTOM"><%=WI.fillTextValue("stud_id")%></td>
</tr>
<tr> 
	<td height="22">Place of Birth: </td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></td>
	<td> </td>
	<td>Date of Birth: </td>
	<td class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="13%">Sex: </td>
	<td width="7%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></td>
	<td width="12%" align="right">Nationality: &nbsp;</td>
	<td width="33%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(11), "&nbsp;")%></td>
	<td width="3%"> </td>
	<td width="12%">Civil Status</td>
	<td width="20%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(12), "&nbsp;")%></td>
</tr>
<tr>
  <td height="22">Address:</td>
  <td colspan="6" class="thinborderBOTTOM"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="23%">Parent's/Guardian's Name</td>
	<td width="42%" class="thinborderBOTTOM"><%=WI.getStrValue(vAdditionalInfo.elementAt(8), "&nbsp;")%></td>
	<td width="10%" align="right">Address: &nbsp;</td>
	<td width="25%" class="thinborderBOTTOM">
<%
strTemp = (String)vAdditionalInfo.elementAt(3);
String strMonth = null;//line 2.
if(strTemp != null) {
	if(vAdditionalInfo.elementAt(4) != null) //city
		strTemp = strTemp + ", "+(String)vAdditionalInfo.elementAt(4);
	if(vAdditionalInfo.elementAt(5) != null) {//province
		if(strTemp.length() > 60)
			strMonth = (String)vAdditionalInfo.elementAt(5);
		else
			strTemp = strTemp + ", "+(String)vAdditionalInfo.elementAt(5);
	}
	if(vAdditionalInfo.elementAt(7) != null) {//zip..
		if(strMonth != null)
			strMonth += " - "+(String)vAdditionalInfo.elementAt(7);
		else
			strTemp = strTemp + " - "+(String)vAdditionalInfo.elementAt(7);
	}
}
if(strTemp != null && strTemp.length() > 35) 
	strTemp = strTemp.substring(0,30)+"...";
%>
	<%=WI.getStrValue(strTemp, "&nbsp;")%></td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22">PRELIMINARY EDUCATION:</td>
	<td align="center" width="17%">School Year</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">Primary: </td>
	<td class="thinborderBOTTOM" width="65%">
  <%
  strTemp = WI.getStrValue(vEntranceData.elementAt(14),WI.getStrValue(vEntranceData.elementAt(3)));
  %><%=WI.getStrValue(strTemp, "&nbsp;")%>

	&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(17)) +" - "+	WI.getStrValue(vEntranceData.elementAt(18))%>&nbsp;
	</td>
</tr>
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">Intermediate: </td>
	<td class="thinborderBOTTOM" width="65%">
  <%
  strTemp = WI.getStrValue(vEntranceData.elementAt(16),WI.getStrValue(vEntranceData.elementAt(3)));
  %><%=WI.getStrValue(strTemp, "&nbsp;")%>
	&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+	WI.getStrValue(vEntranceData.elementAt(20))%>&nbsp;
	</td>
</tr>
<tr> 
	<td height="22" width="3%"></td>
	<td width="12%">High School:</td>
	<td class="thinborderBOTTOM" width="65%"><%=WI.getStrValue(vEntranceData.elementAt(5))%>&nbsp;</td>
	<td width="3%">&nbsp;</td>
	<td class="thinborderBOTTOM"  width="17%" align="center">
	<%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+	WI.getStrValue(vEntranceData.elementAt(22))%>&nbsp;
	</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td width="30%" height="22">CANDIDATE FOR THE TITLE/DEGREE :</td>
	<td class="thinborderBOTTOM"><%=(String)vStudInfo.elementAt(7)%>(<%=(String)vStudInfo.elementAt(24)%>)&nbsp;</td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td width="10%" height="22">Major :</td>
	<td width="30%" class="thinborderBOTTOM"><%=WI.getStrValue(vStudInfo.elementAt(8),"&nbsp;")%></td>
	<td width="10%" align="right">Minor :</td>
	<td width="15%" class="thinborderBOTTOM">&nbsp;</td>
	<td width="20%" align="right">Date of Graduation :</td>
	<td width="15%" class="thinborderBOTTOM"><%=WI.getStrValue(WI.fillTextValue("date_grad"), "&nbsp;")%></td>
</tr>
</table>
<br>
<%}//show only if it is not first page.. 
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr> 
	<td width="30%" height="22" class="thinborderTOPBOTTOM">Course No.</td>
	<td width="50%" class="thinborderLEFTTOPBOTTOM">Descriptive Title</td>
	<td width="10%" class="thinborderLEFTTOPBOTTOM">Grades</td>
	<td width="10%" class="thinborderLEFTTOPBOTTOM">Units</td>
</tr>
<tr>
  <td height="22" class="thinborderRIGHT">&nbsp;</td>
  <td class="thinborderRIGHT">&nbsp;</td>
  <td class="thinborderRIGHT">&nbsp;</td>
  <td>&nbsp;</td>
</tr>
</table>



<%if(iLastPage !=1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="22" class="thinborderTOPBOTTOM"> -- continued on page <%=iPageNumber + 1%> -- </td>
	</tr>
</table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" align="center">&nbsp;</td>
  </tr>
  <tr>
    <td height="20">&nbsp;</td>
  </tr>
</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
