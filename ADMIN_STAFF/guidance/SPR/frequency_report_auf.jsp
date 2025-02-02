<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalRecordExtn,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Personal Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	function ReloadPage(strShow){		
		document.form_.show_frequency.value = strShow;
		
		if(strShow.length > 0){
			var iCount = document.form_.click_count.value;
			
			var strErrMsg = "Please select atleast 1 field to show information.";
			
			for(var i = 1; i < iCount; i++){
				if(eval('document.form_.name_'+i+'.checked == true')){
					strErrMsg = "";
					break;
				}
			}
			
			if(strErrMsg.length > 0){
				alert(strErrMsg);
				return;
			}	
		}
		
		document.form_.submit();
	}
	
	function PrintPage(){
	
		if(!confirm("Click OK to print report"))
			return;
	
		document.bgColor = "#FFFFFF";

		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		document.getElementById("myADTable1").deleteRow(0);
		
		document.getElementById("myADTable2").deleteRow(0);
		document.getElementById("myADTable3").deleteRow(0);
		
		window.print();
	}
	
</script>
<body>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Guidance & Counseling-SPR","frequency_report.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","SPR",request.getRemoteAddr(),
															"frequency_report.jsp");
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
	//end of security
	
	
Vector vRetResult = null;
StudentPersonalRecordExtn sprExtn = new StudentPersonalRecordExtn();




boolean bolShowInfo 				= false;

double dTotPercent = 0d;
double dPercentage = 0d;
int iTotal         = 0;
int iTemp          = 0;

//if(WI.fillTextValue("show_frequency").length() > 0){
//	vRetResult = sprExtn.getFrequencyReport(dbOP, request);
//	if(vRetResult == null)
//		strErrMsg = sprExtn.getErrMsg();	
//	else
//		bolShowInfo = true;
//}
%>
<form name="form_" method="post" action="frequency_report_auf.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr>
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: STUDENT PERSONAL RECORD FREQUENCY REPORT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">School year </td>
      <td height="25"> <%
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
	  readonly="yes"> 
	  
	  &nbsp; &nbsp;<select name="offering_sem">
	  <option value="">Select Semester</option>
<%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp.equals("1"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="1" <%=strErrMsg%>>1st Sem</option>

<%
if(strTemp.equals("2"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="3" <%=strErrMsg%>>3rd Sem</option>

<%
if(strTemp.equals("4"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="4" <%=strErrMsg%>>4th Sem</option>

<%
if(strTemp.equals("0"))
	strErrMsg = "selected";
else
	strErrMsg = "";
%><option value="0" <%=strErrMsg%>>Summer</option>
</select></td>
      
    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="18%">Course: </td>
			<td width="79%">
				<select name="course_index" onChange="ReloadPage('');" style="width:400px;">
          <option value="">&lt;Select a course&gt;</option>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name as cname",
			 	" from course_offered where IS_DEL=0 and is_valid=1 order by cname asc", request.getParameter("course_index"), false)%>
        </select>			</td>			
		</tr>
		<tr>
		   <td height="25">&nbsp;</td>
		   <td>Year Level</td>
		   <td>
				<select name="year_level" onChange="ReloadPage('');">
					<option value="">Select All</option>
					<%
					strTemp = WI.fillTextValue("year_level");
					if(strTemp.equals("1"))
						strErrMsg = "selected";
					else
						strErrMsg = "";
					%><option value="1" <%=strErrMsg%>>1st Year</option>
					<%					
					if(strTemp.equals("2"))
						strErrMsg = "selected";
					else
						strErrMsg = "";
					%><option value="2" <%=strErrMsg%>>2nd Year</option>
					<%					
					if(strTemp.equals("3"))
						strErrMsg = "selected";
					else
						strErrMsg = "";
					%><option value="3" <%=strErrMsg%>>3rd Year</option>
					<%					
					if(strTemp.equals("4"))
						strErrMsg = "selected";
					else
						strErrMsg = "";
					%><option value="4" <%=strErrMsg%>>4th Year</option>
					<%					
					if(strTemp.equals("5"))
						strErrMsg = "selected";
					else
						strErrMsg = "";
					%><option value="5" <%=strErrMsg%>>5th Year</option>
				</select>			</td>
	   </tr>
		<tr>
		   <td height="25" colspan="3">Click to Show Information</td>
	   </tr>
		<tr>
			<%
			String[] astrFieldName = {
					"",
					"Age",
					"Gender",
					"Citizenship",
					"Civil Status",
					"Religion",
					"Hometown",
					"Living Arrangement",
					"School Type",
					"Name of School",
					"Admission Status",
					"Activities that contributed knowledge about AUF",
					"Person who chose AUF for College Education",
					"Reason for Choosing AUF",
					"Primary Reason for Choosing the Course",
					"Father’s Educational Attainment",
					"Mother’s Educational Attainment",
					"Father’s Occupation",
					"Mother’s Occupation",
					"Father’s Place of Work",
					"Mother’s Place of Work",
					"Parent’s Marital Status",
					"Living Arrangement",
					"Monthly Income of Parents",
					"No. of Children in the family",
					"Birth Order",
					"Aspects in which Students need Assistance",
					"Need Counseling"
			};
			%>
		   <td height="25" colspan="2"></td>		   
		   <td>
				<%
				int i = 1;
				for(i = 1; i < astrFieldName.length; i++)	{
				strTemp = WI.fillTextValue("name_"+i);
				if(strTemp.equals(Integer.toString(i)))
					strErrMsg = "checked";
				else
					strErrMsg = "";
				%>
				<input type="checkbox" name="name_<%=i%>" value="<%=i%>" <%=strErrMsg%>><%=astrFieldName[i]%><br>		
				<%}%>
				<input type="hidden" name="click_count" value="<%=i%>">
			</td>
	   </tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:ReloadPage('1');"><img src="../../../images/form_proceed.gif" border="0"></a>
					<font size="1">Click to view frequency information.</font>			</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>


<%

int iCount = 0;

if(WI.fillTextValue("name_1").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 1);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;

%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Age</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>AGE</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=3){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i+1)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+2),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}


if(WI.fillTextValue("name_2").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 2);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Gender</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>GENDER</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_3").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 3);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Citizenship</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Citizenship</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_4").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 4);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Civil Status</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Civil Status</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_5").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 5);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Religion</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Religion</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_6").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 6);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Hometown</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Hometown</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_7").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 7);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Living Arrangement</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Living Arrangement</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_8").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 8);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to School Type</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>School Type</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_9").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 9);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to School of Origin</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Name of School</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_10").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 10);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Admission Status</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="52%" rowspan="3" align="center" class="thinborder"><strong>Academic Status</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="24%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="24%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_11").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 11);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to activities that contributed knowledge about AUF</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="68%" rowspan="3" align="center" class="thinborder"><strong>Activities</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="16%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="16%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_12").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 12);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution According to the Person Who Chose AUF for College Education</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="68%" rowspan="3" align="center" class="thinborder"><strong>Person</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="16%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="16%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_13").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 13);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Reason for Studying at AUF</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="68%" rowspan="3" align="center" class="thinborder"><strong>Reason for choosing AUF</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="16%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="16%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_14").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 14, 1);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>
<br>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Primary Reason for Choosing the Course<br>
	RANK 1</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Primary reason for choosing the course</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_14").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 14, 2);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>RANK 2</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Primary reason for choosing the course</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_14").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 14, 3);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>RANK 3</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="70%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Primary reason for choosing the course</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_15").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 15);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Father's Educational Attainment</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Father's Educational Attainment</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_16").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 16);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Mother's Educational Attainment</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr><td width="70%" rowspan="3" align="center" class="thinborder"><strong>Mother's Educational Attainment</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_17").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 17);
if(vRetResult != null && vRetResult.size() > 3){
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Father’s Occupation</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Father's Occupation </strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_18").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 18);
if(vRetResult != null && vRetResult.size() > 3){
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Mother’s Occupation</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Mother's Occupation </strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_19").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 19);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Father’s Place of Work </strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Father's Place of Work </strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_20").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 20);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>.Frequency and Percentage Distribution according to Mother’s Place of Work</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Mother's Place of Work </strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_21").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 21);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Parents’ Marital Status </strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Parent's Marital Status</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>



<%}
}

if(WI.fillTextValue("name_22").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 22);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Living Arrangement</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Living Arrangement</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>



<%}
}

if(WI.fillTextValue("name_23").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 23);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Month Income of Parents</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="50%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="70%" rowspan="3" align="center" class="thinborder"><strong>Monthly Income</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="15%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" style="padding-left:15px;"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_24").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 24);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Number of Children in the Family</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="56%" rowspan="3" align="center" class="thinborder"><strong>Number of Children</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="22%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="22%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}

}


if(WI.fillTextValue("name_25").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 25);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to the Ordinal Position in the Family</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="56%" rowspan="3" align="center" class="thinborder"><strong>Birth Order</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="22%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="22%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}

if(WI.fillTextValue("name_26").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 26);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Aspects in which Students Need Assistance</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="56%" rowspan="3" align="center" class="thinborder"><strong>Aspects</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="22%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="22%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}
if(WI.fillTextValue("name_27").length() > 0){
vRetResult = sprExtn.getFrequencyReport(dbOP, request, 27);
if(vRetResult != null && vRetResult.size() > 1){
bolShowInfo = true;
%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="25"><strong>Table <%=++iCount%>. Frequency and Percentage Distribution according to Number of Students who Need/do not Need Counseling</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="40%" align="center" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
	   <td width="56%" rowspan="3" align="center" class="thinborder"><strong>Need Counseling</strong></td>
	</tr>
	<tr>
		<td class="thinborder" height="17" align="center" colspan="2"><strong>TOTAL</strong></td>
	</tr>
	<tr>
		<td width="22%" height="17" align="center" class="thinborder"><strong>F</strong></td>
		<td width="22%" align="center" class="thinborder"><strong>%</strong></td>
	</tr>
	<%
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	dTotPercent = 0d;
	for(i =0; i < vRetResult.size(); i+=2){	
	%>
	<tr>
		<td class="thinborder" height="17" align="center"><%=vRetResult.elementAt(i)%></td>
		<%
		iTemp = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"0"));
		if(iTotal > 0)
			dPercentage = sprExtn.getPercentage((double)iTemp, (double)iTotal, 100);
		else
			dPercentage = 0d;
		dTotPercent += dPercentage;
		%>
		<td class="thinborder" align="center"><%=iTemp%></td>
		<td class="thinborder" align="center"><%=CommonUtil.formatFloat(dPercentage,true)%></td>
	</tr>
	<%}%>
	<tr>
		<td class="thinborder" height="17" align="center"><strong>TOTAL</strong></td>
		<td class="thinborder" align="center"><strong><%=iTotal%></strong></td>
		<td class="thinborder" align="center"><strong><%=CommonUtil.formatFloat(dTotPercent,true)%></strong></td>
	</tr>
</table>
<%}
}


if(bolShowInfo){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
	<tr><td align="right">
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
</table>


<%}%>



  
<table bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
<tr>
<td height="25" bgcolor="#A49A6A">&nbsp;</td>
</tr>
</table>
	
	<input type="hidden" name="show_frequency">
</form>
</body>
</html>
<%
sprExtn.removeTempTable(dbOP);
dbOP.cleanUP();
%>