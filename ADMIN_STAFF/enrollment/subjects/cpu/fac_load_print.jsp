

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	this.SubmitOnce("form_");
}

</script>

<%@ page language="java" import="utility.*, enrollment.SubjectSectionCPU, java.util.Vector"%>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CLASS PROGRAMS","fac_load_report.jsp");
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
														"Enrollment","CLASS PROGRAMS",request.getRemoteAddr(),
														"fac_load_report.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
int iCtr = 0;
int iCtr2 = 0;
int iCtr3 = 0;
Vector vMiscDetails = null;
Vector vAcadLoad = null;
Vector vNonAcadLoad = null;

boolean hasMisc = true;
boolean hasAcad = true;
boolean hasAddl = true;
boolean isLab = true;

double dHrLecTemp = 0d;
double dHrLabTemp = 0d;
double dLdLecTemp = 0d;
double dLdLabTemp = 0d;
double dLdTotalTemp = 0d;

double dHrLecSum = 0d;
double dHrLabSum = 0d;
double dLdLecSum = 0d;
double dLdLabSum = 0d;
double dLdTotalSum = 0d;

double dAddlTemp = 0d;
double dAddlSum = 0d;

double dMegaSum = 0d;


String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};
SubjectSectionCPU subSecCPU = new SubjectSectionCPU();

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0 && 
	WI.fillTextValue("semester").length()>0)
{
	vRetResult = subSecCPU.getFacultyLoadReport(dbOP,request);
	if (vRetResult == null)
		strErrMsg = subSecCPU.getErrMsg();
	
}	
%>
<body bgcolor="#FFFFFF">
<%if (strErrMsg != null){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
	<td height="25"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
</table>
<% return;}%>
<%if (vRetResult!= null && vRetResult.size()>0){%>
	<%for (iCtr = 0; iCtr < vRetResult.size(); iCtr+=4){
	vMiscDetails = (Vector)vRetResult.elementAt(iCtr+1);
	vAcadLoad = (Vector)vRetResult.elementAt(iCtr+2);
	vNonAcadLoad = (Vector)vRetResult.elementAt(iCtr+3);
	
	if (vMiscDetails == null || vMiscDetails.size()==0)
		hasMisc = false;
	else 
		hasMisc = true;
	
	
	if (vAcadLoad == null || vAcadLoad.size()==0)
		hasAcad = false;
	else
		hasAcad = true;
	
	if (vNonAcadLoad == null || vNonAcadLoad.size()==0)
		hasAddl = false;
	else
		hasAddl = true;
		
		dHrLabSum = 0d;
		dHrLecSum = 0d;
		dLdLabSum = 0d;
		dLdLecSum = 0d;
		dLdTotalSum = 0d;
		dAddlSum = 0d;
		dMegaSum = 0d;
		%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
	<tr>
		<td width="20%">&nbsp;</td>
		<td width="30%">&nbsp;</td>
		<td width="30%">&nbsp;</td>
		<td width="20%">&nbsp;</td>
	</tr>
    <tr>
      <td align="center" height="40" colspan="4"><font size="2"><strong>Central Philippine University - Iloilo City, Philipines<br>
      Instructor's Academic Load Report<br>
      </strong></font></td>
    </tr>
    <tr>
		<td colspan="2" height="25"><font style="font-size:11px">Name: <%if (hasMisc){%><%=WI.formatName((String)vMiscDetails.elementAt(1),(String)vMiscDetails.elementAt(2),(String)vMiscDetails.elementAt(3),7)%><%} else {%>Anonymous<%}%></font></td>
    	<td align="right" colspan="2"><font style="font-size:11px"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
		<%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>&nbsp;</font></td>
    </tr>
    <tr>
		<td height="25"><font style="font-size:11px">Emp No: <%if (hasMisc){%><%=(String)vMiscDetails.elementAt(0)%><%} else {%>&nbsp;<%}%></font></td>    	
		<td><font style="font-size:11px">College: <%if (hasMisc){%><%=WI.getStrValue((String)vMiscDetails.elementAt(4),"&nbsp;")%><%} else {%>&nbsp;<%}%></font></td>    	
		<td><font style="font-size:11px">Department: <%if (hasMisc){%><%=WI.getStrValue((String)vMiscDetails.elementAt(5),"&nbsp;")%><%} else {%>&nbsp;<%}%></font></td>    	
   		<td>&nbsp;</td>
    </tr>
	</table>
<%if (hasAcad){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
	<tr>
		<td height="10" colspan="11"><hr size="1"></hr></td>
	</tr>
	<tr>
		<td rowspan="2" width="10%"><font style="font-size:11px">Course <br>
		Code</font></td>
		<td rowspan="2" width="7%"><font style="font-size:11px">Stub<br>Code</font></td>
		<td rowspan="2" width="7%"><font style="font-size:11px">Credits</font></td>
		<td rowspan="2" width="7%"><font style="font-size:11px">Stud</font></td>
		<td rowspan="2" width="30%"><font style="font-size:11px">Schedule</font></td>
		<td colspan="2" align="center"><font style="font-size:11px">Hrs/Week</font></td>
		<td colspan="3" align="center"><font style="font-size:11px">Load Units</font></td>
		<td rowspan="2" width="10%"><font style="font-size:11px">Status</font></td>
	</tr>
	<tr>
		<td width="5.8%"><font style="font-size:11px">Lec</font></td>
		<td width="5.8%"><font style="font-size:11px">Lab</font></td>
		<td width="5.8%"><font style="font-size:11px">Lec</font></td>
		<td width="5.8%"><font style="font-size:11px">Lab</font></td>
		<td width="5.8%"><font style="font-size:11px">Total</font></td>
	</tr>
	<tr>
		<td height="10" colspan="11"><hr size="1"></hr></td>
	</tr>
<%for (iCtr2=0;iCtr2<vAcadLoad.size();iCtr2+=12){

	if (WI.getStrValue((String)vAcadLoad.elementAt(iCtr2+5),"0").equals("0")){
		isLab = false;
		dHrLabTemp = 0d;
		dLdLabTemp = 0d;
		dHrLecTemp = ((Double)vAcadLoad.elementAt(iCtr2+6)).doubleValue();
		dLdLecTemp = ((Double)vAcadLoad.elementAt(iCtr2+8)).doubleValue();
		dLdTotalTemp = dLdLecTemp;
		
		dHrLecSum += dHrLecTemp;
		dLdLecSum += dLdLecTemp;
		dLdTotalSum += dLdTotalTemp;

	}else{
		isLab = true;
		dHrLabTemp = ((Double)vAcadLoad.elementAt(iCtr2+7)).doubleValue();
		dLdLabTemp = ((Double)vAcadLoad.elementAt(iCtr2+8)).doubleValue();
		dHrLecTemp = 0d;
		dLdLecTemp = 0d;
		dLdTotalTemp = dLdLabTemp;
		
		dHrLabSum += dHrLabTemp;
		dLdLabSum += dLdLabTemp;
		dLdTotalSum += dLdTotalTemp;

}


%>
	<tr>
		<td class="thinborderBOTTOM" height="25"><%=(String)vAcadLoad.elementAt(iCtr2+1)%></td>
		<td class="thinborderBOTTOM"><%=(String)vAcadLoad.elementAt(iCtr2)%></td>
<%if (isLab)
		strTemp = (String)vAcadLoad.elementAt(iCtr2+3);
   else
   		strTemp = (String)vAcadLoad.elementAt(iCtr2+2);
%>		
		<td class="thinborderBOTTOM"><%=strTemp%></td>
		<td class="thinborderBOTTOM"><%=WI.getStrValue((String)vAcadLoad.elementAt(iCtr2+4),"0")%></td>
		<td class="thinborderBOTTOM"><%=(String)vAcadLoad.elementAt(iCtr2+11)%></td>
		<td class="thinborderBOTTOM"><%=comUtil.formatFloat(dHrLecTemp,false)%></td>
		<td class="thinborderBOTTOM"><%=comUtil.formatFloat(dHrLabTemp,false)%></td>
		<td class="thinborderBOTTOM"><%=comUtil.formatFloat(dLdLecTemp,false)%></td>
		<td class="thinborderBOTTOM"><%=comUtil.formatFloat(dLdLabTemp,false)%></td>
		<td class="thinborderBOTTOM"><%=comUtil.formatFloat(dLdTotalTemp,false)%></td>
		<td class="thinborderBOTTOM"><%=(String)vAcadLoad.elementAt(iCtr2+10)%></td>
	</tr>
	<%}%>
	<tr>
		<td height="10" colspan="11"><hr size="1"></hr></td>
	</tr>
	<tr>
		<td height="25" colspan="5" align="right"><font style="font-size:12px"><<<<&nbsp; &nbsp;  &nbsp; &nbsp;  TOTAL&nbsp; &nbsp;  &nbsp; &nbsp;  >>>>&nbsp; &nbsp;  </font></td>
		<td><font style="font-size:11px"><%=comUtil.formatFloat(dHrLecSum,false)%></font></td>
		<td><font style="font-size:11px"><%=comUtil.formatFloat(dHrLabSum,false)%></font></td>
		<td><font style="font-size:11px"><%=comUtil.formatFloat(dLdLecSum,false)%></font></td>
		<td><font style="font-size:11px"><%=comUtil.formatFloat(dLdLabSum,false)%></font></td>
		<td><font style="font-size:11px"><%=comUtil.formatFloat(dLdTotalSum,false)%></font></td>
		<td>&nbsp;</td>
	</tr>
</table>
<%} 
if (hasAddl){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
<%for (iCtr3 = 0; iCtr3 < vNonAcadLoad.size(); iCtr3+=4){
	dAddlTemp = ((Double)vNonAcadLoad.elementAt(iCtr3+2)).doubleValue();
	dAddlSum += dAddlTemp;
%>
<tr>
	<td width="32%" height="25"><font style="font-size:11px"><%=(String)vNonAcadLoad.elementAt(iCtr3)%></font></td>
	<td width="52%"><font style="font-size:11px"><%=(String)vNonAcadLoad.elementAt(iCtr3+1)%></font></td>
	<td width="16%"><font style="font-size:11px"><%=comUtil.formatFloat(dAddlTemp,false)%></font></td>
</tr>
<%}
	dMegaSum = dAddlSum + dLdTotalSum;%>
<tr>
	<td class="thinborderTOP" height="25">&nbsp;</td>
	<td align="left" class="thinborderTOP" >GRAND TOTAL&nbsp;</td>
	<td class="thinborderTOP"><%=comUtil.formatFloat(dMegaSum,false)%></td>
</tr>
</table>
<%}%>
	  	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" >
  <tr> 
    <td height="10" colspan="7"><hr size="1"></hr>
    </td>
  </tr>
  <tr> 
    <td class="thinborderTOP" height="25" colspan="7"><font style="font-size:11px">&nbsp;Laboratory 
      Hour 10 - local point</font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:11px">&nbsp;Study Load 
      &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<%=comUtil.formatFloat(((Double)vMiscDetails.elementAt(6)).doubleValue(),false)%> unit(s) towards <%=WI.getStrValue((String)vMiscDetails.elementAt(8),"&nbsp;")%> in <%=WI.getStrValue((String)vMiscDetails.elementAt(9),"&nbsp;")%></font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:11px">&nbsp;Other Responsibilities 
      outside CPU</font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:11px">&nbsp;NUMBER OF OVERLOAD 
      UNITS </font><font size="1">( To be filled out by immediate supervisor)</font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:11px">&nbsp;Counseling 
      conference hours with students &nbsp;<%=WI.getStrValue((String)vMiscDetails.elementAt(7),"&nbsp;")%></font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:12px">&nbsp;Load and Overload 
      Units Verified Correct By: </font></td>
  </tr>
  <tr> 
    <td height="30" colspan="7">&nbsp;</td>
  </tr>
  <tr valign="top"> 
    <td width="20%" height="30" align="center" class="thinborderTOP"><font size="1" style="font-size:11px">Dept. 
      Chariman</font></td>
    <td width="6%"><font size="1">&nbsp;</font></td>
    <td width="20%" align="center"class="thinborderTOP"><font style="font-size:11px">Dean/Director/Principal</font></td>
    <td width="7%"><font size="1">&nbsp;</font></td>
    <td width="20%" align="center" class="thinborderTOP"><font size="1" style="font-size:11px">Teacher's 
      Signature</font></td>
    <td width="7%"><font size="1">&nbsp;</font></td>
    <td width="20%" align="center" class="thinborderTOP"><font style="font-size:11px">Date 
      of Submission</font></td>
  </tr>
  <tr> 
    <td height="25" colspan="7"><font style="font-size:12px">&nbsp;APPROVED: </font></td>
  </tr>
  <tr> 
    <td height="20" colspan="7">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25" align="center" valign="top" class="thinborderTOP"><font style="font-size:11px">VPAA</font></td>
    <td colspan="6">&nbsp;</td>
  </tr>
  <tr> 
    <td class="thinborderTOP" colspan="5" height="25"><font size="1"> ** &nbsp; 
      Final copies should be submitted in quadruplate</font></td>
    <td class="thinborderTOP" align="right" colspan="2"><font size="1"> Printed: 
      <%=WI.getTodaysDateTime()%>&nbsp;</font></td>
  </tr>
</table>
	  	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//for loop%>
 <script language="JavaScript">
		window.print();
	</script>
<%}%>


</body>
</html>
<%
dbOP.cleanUP();
%>
