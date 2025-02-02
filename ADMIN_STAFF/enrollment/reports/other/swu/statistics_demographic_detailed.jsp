<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 0;
	int iIndexOf = 0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS","statistics_demographic_detailed.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
	function submitForm(){
		document.form_.proceed.value = "1";
		document.form_.submit();
	}
	
function PrintThisPage() {
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);	
	document.getElementById('myADTable4').deleteRow(0);	
	document.bgColor = "#FFFFFF";
	alert("Click OK to print this page");
	window.print();
}
</script>
<body bgcolor="#D2AE72">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"statistics_demographic_detailed.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
ReportEnrollment reportEnrl = new ReportEnrollment();
Vector vRetResult = null;
Vector vRetResultDetailed = null;
Vector vIslandGroup = null;
if(WI.fillTextValue("proceed").length() > 0){
	vRetResultDetailed = reportEnrl.getDemographicEnrollmentStatistics(dbOP, request);
	
	if(vRetResultDetailed == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{	
		vIslandGroup = (Vector)vRetResultDetailed.remove(0);
		vRetResult = (Vector)vRetResultDetailed.remove(0);
	}
}

%>
<form name="form_" action="./statistics_demographic_detailed.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong>STATISTICS - DEMOGRAPHIC REPORT - DETAILED</strong></div></td>
    </tr>
	<tr> 
      <td width="4%" height="25"></td>
      <td width="96%" colspan="3"><font size="2"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
        <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("is_basic");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
        <td height="25" colspan="4">
		<input type="checkbox" name="is_basic" value="1" <%=strErrMsg%>>Click to generate basic report		</td>
        <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="12%" height="25">School year </td>
      <td width="12%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
      <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="29%" height="25"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0){

String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};
String[] astrIslandGroup = {"Luzon","Visayas","Mindanao"};
String strIslandName = null;
int iTotalMale = 0;
int iTotalFemale = 0;
int iSubTotal = 0;
int iCountRight = 0;
int iCount = 0;
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable4">
	<tr><td colspan="2" align="right"><a href="javascript:PrintThisPage();"><img src="../../../../../images/print.gif" border="0"></a></td></tr>
</table>

<%




	for(int i=0; i < vIslandGroup.size(); i+=2){
	iTemp = 1;
	int iDetailedSize = 0;	
		
	String strProvince = "";
	String strPrevProvince = "";
	boolean bolShowTotal = false;
	int iRowPrinted = 0;
	int iMaxRowPrint = 20;
	boolean bolPageBreak = false;
	int iCountLeft = 0;
	
	iTotalMale = 0;
	iTotalFemale = 0;
	iSubTotal = 0;
	strIslandName = astrIslandGroup[Integer.parseInt((String)vIslandGroup.elementAt(i))];
	
	if(i > 0){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<tr>
		<td width="14%" valign="top"> <img src="../../../../../images/logo/<%=strSchCode%>.gif" width="90" height="90" border="0"></td>
		<td width="86%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr><td colspan="2"><strong><font size="+2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td></tr>
				<tr>
					<td height="20" width="54%" style="font-size:15px; font-weight:bold;">Electronic Data Processing</td>
					<%if(strSchCode.startsWith("SWU")){%>
					<td width="46%" rowspan="2" valign="top">		
						<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
							<tr><td width="18%"><i><font size="1">Phone: </font></i></td>
							<td width="82%"><i><font size="1">415-5555 loc. 134</font></i></td>
							</tr>
							<tr><td><i><font size="1">Website: </font></i></td><td><i><font size="1" color="#0000FF"><u>swu.edu.ph</u></font></i></td></tr>
							<tr><td><i><font size="1">E-mail: </font></i></td><td><i><font size="1">edp@swu.edu.ph</font></i></td></tr>
						</table>
					
					</td>
					<%}%>
				</tr>
				<tr><td height="20" style="font-size:12px;"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td></tr>
			</table>
	  </td>
	</tr>
	<tr><td colspan="2" align="center"><div  style="border-bottom:solid 2px #000000; width:80%;"></div></td></tr>
	<tr><td colspan="2" align="center" valign="bottom" height="40">
		<font size="3"><strong><%=strIslandName.toUpperCase()%> STATISTICS</strong></font>
	</td></tr>
	<tr><td colspan="2" align="center" height="20"><strong>
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></strong></td></tr>
	<tr><td height="15" colspan="2" align="center"><font size="1">Date and Time Printed : <%=WI.getTodaysDateTime()%></font></td></tr>
	<tr><td colspan="2" height="15"></td></tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	
	
	<tr>
		<td height="300" width="27%" valign="top" align="center" class="thinborderBOTTOM"><strong><%=strIslandName%> Statistics</strong>
		<br><img src="../../../../../images/<%=strIslandName%>.gif" height="300" width="340" border="0">
		<div style="font-size:14px; text-align:left; width:300px; height:15px; position:relative; left:50; top:-50;">
			Total number of students <%=vIslandGroup.elementAt(i+1)%></div>
		</td>
		<td width="73%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr><td colspan="4"><strong><font size="2"><%=strIslandName.toUpperCase()%></font></strong></td></tr>
				<tr>
					<td height="14" width="73%">&nbsp;</td>
					<td align="right" width="8%" style="padding-right:10px; font-size:9px;" class="thinborderRIGHT"><strong>Male</strong></td>
					<td align="right" width="10%" style="padding-right:10px; font-size:9px" class="thinborderRIGHT"><strong>Female</strong></td>
					<td align="right" width="9%" style="padding-right:10px; font-size:9px"><strong>Total</strong></td>
				</tr>
				<%
				
				
				for(int j = 0; j < vRetResult.size(); j+=5){
					if(!((String)vRetResult.elementAt(j)).equals((String)vIslandGroup.elementAt(i)))
						continue;
				%>
				<tr>
					<td height="14" style="font-size:9px"><%=(String)vRetResult.elementAt(j+1)%></td>
					<%
					iTotalMale   += Integer.parseInt((String)vRetResult.elementAt(j+2));
					iTotalFemale += Integer.parseInt((String)vRetResult.elementAt(j+3));
					iSubTotal    += Integer.parseInt((String)vRetResult.elementAt(j+4));
					%>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResult.elementAt(j+2)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResult.elementAt(j+3)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResult.elementAt(j+4)%></td>
				</tr>
				
				<%}%>
				<tr>
					<td height="20">&nbsp;</td>
					<td valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalMale%></td>
					<td valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalFemale%></td>
					<td valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iSubTotal%></td>					
				</tr>
			</table>			
	  </td>	  
	</tr>
</table>

<%
	bolPageBreak = false;
	bolShowTotal = true;
	while(vRetResultDetailed.size() > iDetailedSize){
	bolPageBreak = false;
	%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="30" colspan="3" valign="bottom"><strong><i><font size="2"><u><%=strIslandName.toUpperCase()%> PROVINCES</u></font></i></strong></td></tr>
	
	
	<%
	if(iTemp == 1)
		strTemp = "380";
	else
		strTemp = "890";
	%>
	<tr>
		<td valign="top" width="49%" height="<%=strTemp%>px">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
			
			
			<%
			
			if(bolShowTotal){
				iTotalMale = 0;
				iTotalFemale = 0;
				iSubTotal = 0;
			}
			strProvince = "";
			strPrevProvince = "";
			iRowPrinted = 0;
			iCount = 0;
			for(iCountLeft = iDetailedSize; iCountLeft < vRetResultDetailed.size(); iCountLeft+=6,iDetailedSize+=6){
			bolPageBreak = false;
			if(!((String)vRetResultDetailed.elementAt(iCountLeft)).equals((String)vIslandGroup.elementAt(i)))
				continue;	
				
			if(iCount == 0){
			%>
				<tr>
					<td height="14" width="">&nbsp;</td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px;" class="thinborderRIGHT"><strong>Male</strong></td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px" class="thinborderRIGHT"><strong>Female</strong></td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px"><strong>Total</strong></td>
				</tr>
			<%}
			
			iCount++;
							
			strProvince = (String)vRetResultDetailed.elementAt(iCountLeft+1);
			if(!strPrevProvince.equals(strProvince)){
				strPrevProvince = strProvince;	
				iRowPrinted++;
				if(iRowPrinted > 1)	{						
					iRowPrinted++;
		%>
				
				<tr>
					<td height="20">&nbsp;</td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalMale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalFemale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iSubTotal%></td>					
				</tr>
				<%
				
				iTotalMale = 0;
				iTotalFemale = 0;
				iSubTotal = 0;
				}%>
				<tr>
					<td colspan="4" style="font-size:9px"><strong><%=strProvince%> (<%=WI.getStrValue((String)vRetResult.elementAt(vRetResult.indexOf(strProvince) + 3))%>) 
					</strong></td>
				</tr>
				<%}
				iRowPrinted++;
				%>
				<tr>
					<td height="14" style="font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountLeft+2)%></td>
					<%
					iTotalMale   += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountLeft+3));
					iTotalFemale += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountLeft+4));
					iSubTotal    += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountLeft+5));
					%>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountLeft+3)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountLeft+4)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountLeft+5)%></td>
				</tr>
					
				<%
					if(iRowPrinted >= iMaxRowPrint)	{				
						iCountLeft+=6;
						iDetailedSize+=6;
						bolPageBreak = false;
						break;					
					}
				}
				
				
				if((iCountLeft + 1) > vRetResultDetailed.size())
					bolShowTotal = true;
				else{
					if(((String)vRetResultDetailed.elementAt(iCountLeft + 1)).equals(strProvince)){
						bolShowTotal = false;
					}else
						bolShowTotal = true;
				}
				
				
				
				
				if(iCountLeft != 0 && bolShowTotal && iCount > 0)	{
				%>
				<tr>
					<td height="20">&nbsp;</td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalMale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalFemale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iSubTotal%></td>					
				</tr>
				<%}%>
			</table>
		</td>
		<td>&nbsp;</td>
		
		
		
		<td valign="top" width="49%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				
				<%
				if(bolShowTotal){
					iTotalMale = 0;
					iTotalFemale = 0;
					iSubTotal = 0;
				}
				strProvince = "";
				strPrevProvince = "";
				
				
				iRowPrinted = 0;
				iCount = 0;
				for(iCountRight = iCountLeft; iCountRight < vRetResultDetailed.size(); iCountRight+=6,iDetailedSize+=6){	
					bolPageBreak = false;				
					if(!((String)vRetResultDetailed.elementAt(iCountRight)).equals((String)vIslandGroup.elementAt(i)))
						continue;
						
					if(iCount == 0){
					%>
				<tr>
					<td height="14" width="">&nbsp;</td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px;" class="thinborderRIGHT"><strong>Male</strong></td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px" class="thinborderRIGHT"><strong>Female</strong></td>
					<td align="right" width="13%" style="padding-right:10px; font-size:9px"><strong>Total</strong></td>
				</tr>
				
					
				<%	}
					iCount++;
					strProvince = (String)vRetResultDetailed.elementAt(iCountRight+1);
					if(!strPrevProvince.equals(strProvince)){
						strPrevProvince = strProvince;	
						iRowPrinted++;
						
						if(iRowPrinted > 1)	{
							iRowPrinted++;
				%>
				
				<tr>
					<td height="20">&nbsp;</td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalMale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalFemale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iSubTotal%></td>					
				</tr>
				<%
				
				iTotalMale = 0;
				iTotalFemale = 0;
				iSubTotal = 0;
				}%>
				<tr>
					<td colspan="4" style="font-size:9px"><strong><%=strProvince%> (<%=WI.getStrValue((String)vRetResult.elementAt(vRetResult.indexOf(strProvince) + 3))%>)
					</strong></td>
				</tr>
				<%}
				
				iRowPrinted++;
				%>
				
						

				<tr>
					<td height="14" style="font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountRight+2)%></td>
					<%
					iTotalMale   += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountRight+3));
					iTotalFemale += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountRight+4));
					iSubTotal    += Integer.parseInt((String)vRetResultDetailed.elementAt(iCountRight+5));
					%>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountRight+3)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountRight+4)%></td>
					<td align="right" style="padding-right:10px; font-size:9px"><%=(String)vRetResultDetailed.elementAt(iCountRight+5)%></td>
				</tr>
				
				<%
					if(iRowPrinted >= iMaxRowPrint){
						iCountLeft+=6;
						iDetailedSize+=6;
						bolPageBreak = true;	
						break;
					}
					
				}//end of loop
				
				
				if((iCountRight + 1) > vRetResultDetailed.size())
					bolShowTotal = true;
				else{
					if(((String)vRetResultDetailed.elementAt(iCountRight + 1)).equals(strProvince)){
						bolShowTotal = false;
					}else
						bolShowTotal = true;
				}
				
				if(iCountLeft != 0 && bolShowTotal && iCount > 0)	{
				%>
				<tr>
					<td height="20">&nbsp;</td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalMale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iTotalFemale%></td>
					<td class="thinborderTOP" valign="bottom" style="padding-right:10px; font-size:9px" align="right"><%=iSubTotal%></td>					
				</tr>
				<%}%>
			</table>
		</td>
	</tr>	
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td colspan="3" align="right" style="font-size:9px;">Page <%=iTemp++%></td></tr>
</table>
<%

	if(bolPageBreak){
		iMaxRowPrint = 60;
	%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}
	
	bolPageBreak = false;
	
	}%>
	
	
	<%} //end of loop island_group%>
<%}//end of vRetResult != null%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
<tr bgcolor="#A49A6A"><td height="25" colspan="3">&nbsp;</td></tr>
</table>
<input type="hidden" name="proceed">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
