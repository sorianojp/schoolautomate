<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,student.GWA,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrintPage()
{		
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);

	obj = document.getElementById('myTable2');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);

	
	window.print();
}

function Search(strReportType){

	if(strReportType == '1'){
		if(document.form_.gwa_score.value == ''){
			alert("Please input general weighted average.");
			return;
		}
	}	
	
	document.form_.search_.value = '1';
	document.form_.submit();
}
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}

</script>


<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#DDDDDD">
<form name="form_" action="./final_grade_report_uc.jsp" method="post">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <!--<label id="page_progress"></label>-->
			<br><img src="../../../Ajax/ajax-loader_small_black.gif">
			</font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<%
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","final_grade_report_uc.jsp");
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

//int iAccessLevel = 2;
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"final_grade_report_uc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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

ReportEnrollment enrlReport = new ReportEnrollment();
GWA gwa = new GWA();

Vector vRetResult = new Vector();
Vector vGWA = new Vector();


if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlReport.viewEnrollmentListUC(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();
	else{
		vGWA = gwa.getTopStudentNew(dbOP, request);
		if(vGWA == null)
			strErrMsg = gwa.getErrMsg();
		//System.out.println("vGWA "+vGWA);
	}
}	

String strReportType = null;

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr>
      <td colspan="5" align="center" valign="bottom" class="thinborderBOTTOM"><strong>:::: STUDENT FINAL GRADE ::::</strong></td>
    </tr>
	<tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
	
	<tr>
		<td>&nbsp;</td>
		<td colspan="2">
		<%
		strTemp = WI.fillTextValue("report_type");
		if(strTemp.length() == 0 || strTemp.equals("1")){
			strErrMsg = "checked";
			strTemp = "1";
		}
		else
			strErrMsg = "";
		%>
		<input type="radio" name="report_type" value="1" <%=strErrMsg%> onClick="document.form_.submit();" >Click to print Academic Scholars
		
		<%		
		if(strTemp.equals("2"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="radio" name="report_type" value="2" <%=strErrMsg%> onClick="document.form_.submit();" >Click to print all student
		
		</td>
		<%strReportType = strTemp;%>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term</td>		
		<td>			
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));%>
			<select name="semester">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select></td>		
	</tr>
	<%
	//System.out.println("strErrMsg "+strErrMsg);
	if(strReportType.equals("1")){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>General Weighted Average</td>
		<td><input name="gwa_score" type="text" size="5" maxlength="4" class="textbox" value="<%=WI.fillTextValue("gwa_score")%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_score');style.backgroundColor='white'"
				onkeyup="AllowOnlyFloat('form_','gwa_score')"></td>				
	</tr>
	<%}%>
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr><td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search('<%=strReportType%>');"><img src="../../../images/form_proceed.gif" border="0" align="absmiddle"></a></td>
	</tr>
	
</table>

<%
String[] astrConvertSem = {"SUMMER","FIRST TRIMESTER","SECOND TRIMESTER","THIRD TRIMESTER","FOURTH TRIMESTER","FIFTH TRIMESTER"};
if(vRetResult != null && vRetResult.size() > 0 && vGWA != null && vGWA.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td></tr>
</table>



<%
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

boolean bolIsPageBreak = false;
int iResultSize = 10;
int iLineCount = 0;
int iMaxLineCount = 70;	
int iCount = 0;	
int i = 0;

String strGrade = null;
String strUnitEarned = null;
double dGWA = 0d;
int iPageCount = 0;
double dGrade = 0d;
double dTotUnits = 0d;
Vector vSubList = new Vector();	

int iIndexOf = 0;

double dGWAScore = 0d;

if(strReportType.equals("1"))
	dGWAScore = Double.parseDouble(WI.fillTextValue("gwa_score"));
		

while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
%>

	
<table height="50px">
	<tr><td>&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td align="center" style="font-size:11px;"><strong><%=strSchoolName%></strong></td></tr>
	<tr><td align="center">Report on Final Grade</td></tr>
	<tr><td align="center"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%></td></tr>
	<tr><td align="right">Page <%=++iPageCount%></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<%
		for( ; i < vRetResult.size() ; ){
			vSubList = (Vector)vRetResult.elementAt(i+6);
			
			iIndexOf = vGWA.indexOf(vRetResult.elementAt(i+1));			
			if(iIndexOf > -1)
				dGWA = Double.parseDouble((String)vGWA.elementAt(iIndexOf + 3));
			else
				dGWA = 0d;
			
			if(strReportType.equals("1")){
				if(dGWA < dGWAScore){
					i+=10;
					iResultSize += 10;
					continue;
				}
			}
			

			dTotUnits = 0;
			dGrade = 0d;
			iCount = 0;
						
			iLineCount += 3;		
			iResultSize += 10;
	%>

	<tr>
		<td width="7%">IDNO</td>
		<td  width="30%" >: <%=vRetResult.elementAt(i+1)%></td>
		<td width="15%">Course and Year</td><td>: <%=vRetResult.elementAt(i+4)%> <%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
	</tr>
	<tr>
		<td>Name</td><td colspan="3">: <%=vRetResult.elementAt(i+2)%></td>
		
	</tr>
	<tr>
		<td>Address</td>
		<td colspan="3">: 
		<%=WI.getStrValue((String)vRetResult.elementAt(3))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(7),", ","","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(8),", ","","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(9))%>		
		
		</td>
	</tr>
	<%if(vSubList != null && vSubList.size() > 0){%>
	<tr>		
		<td valign="top" colspan="4">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td colspan="3">&nbsp;</td>
					<td width="15%" align="center">Grade</td>
					<td width="15%" align="center">Units</td>
				</tr>
				<%for(int x = 0; x < vSubList.size(); x+=4, iCount++){
					iLineCount++;
					
					strGrade = (String)vSubList.elementAt(x+2);
					strUnitEarned = (String)vSubList.elementAt(x+3);
					try{
						dGrade += Double.parseDouble(strGrade);
						dTotUnits += Double.parseDouble(strUnitEarned);
					}catch(Exception e){
					
					}		
				%>
				<tr>
					<td width="15%">&nbsp;</td>
					<td width="15%"><%=vSubList.elementAt(x+0)%></td>
					<td><%=vSubList.elementAt(x+1)%></td>
					<td width="15%" align="center"><%=WI.getStrValue(strGrade,"-")%></td>
					<td width="15%" align="center"><%=WI.getStrValue(strUnitEarned)%></td>
				</tr>
				<%}%>
				<tr>
					<td colspan="3">&nbsp;</td>
					<td width="15%" align="center" style="font-size:11px;"><strong><%=CommonUtil.formatFloat(dGWA,2)%></strong></td>
					<td width="15%" align="center" style="font-size:11px;"><strong><%=CommonUtil.formatFloat(dTotUnits,2)%></strong></td>
				</tr>
				<tr>
					<td colspan="4" align="right">General Weighted Average</td>
					<td width="15%" align="center">Total Units</td>
				</tr>
			</table>
		</td>
	</tr>
	<%}
		i+=10;
		if(iLineCount > iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;	
	}%>
	
</table>

	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>

<%}
}%>
<input type="hidden" name="gwa_con" value="0">
    <input type="hidden" name="search_">

</form>
</body>
</html>
<% dbOP.cleanUP(); %>