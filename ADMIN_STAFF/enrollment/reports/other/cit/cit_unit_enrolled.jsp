<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
	
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);	

	window.print();//called to remove rows, make bg white and call print.	
}

</script>

<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","cit_unit_enrolled.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"cit_unit_enrolled.jsp");
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

Vector vRetResult 		= new Vector();
Vector vCollegeName 	= new Vector();
Vector vGrandTotalCount = new Vector();
Vector vTotalCount 		= new Vector();     
Vector vTotalUnitsStud 	= new Vector();

ReportEnrollment reportEnrl = new ReportEnrollment();

if(WI.fillTextValue("reloadPage").length() > 0){
	vRetResult = reportEnrl.getCITUnitEnrolled(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	
}

String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	
%>
<form action="./cit_unit_enrolled.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          ENROLMENT STATUS STUDENT LOAD ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    
	
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("exclude_nstp");
		if(strTemp.length() > 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td colspan="3"><input type="checkbox" value="1" name="exclude_nstp" <%=strErrMsg%>>Exclude NSTP
		<div align="right" style="font-weight:bold; font-size:11px;">
			<a href="./cit_unit_enrolled_detailed.jsp"><font color="#CC0099">Go to Detailed Report - Per student Unit Enrolled</font></a>
		</div>
		
		</td>
	</tr>
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">SY-Term </td>
      <td width="30%" height="25"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> 
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 
	  
	  <select name="semester">
          <option value="1">1st Sem</option><%
strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
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
      <td width="57%">
	  <input type="submit" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>

	
    
    
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
<%

if(vRetResult != null && vRetResult.size() > 0){

vCollegeName = (Vector)vRetResult.remove(0);
vTotalUnitsStud = (Vector)vRetResult.remove(0);
vTotalCount = (Vector)vRetResult.remove(0);
vGrandTotalCount = (Vector)vRetResult.remove(0);
	
String strGrandTotStudCount = null;
String strGrandTotETEEAP = null;
	if(vGrandTotalCount != null && vGrandTotalCount.size() > 0){		
		strGrandTotETEEAP = (String)vGrandTotalCount.remove(1);
		strGrandTotStudCount = (String)vGrandTotalCount.remove(0);
	}
	

%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
		<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
			<font size="1">Click to print summary</font>		
		</td></tr>
		<td height="15">&nbsp;</td>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%
				if(WI.fillTextValue("exclude_nstp").length() > 0)					
					strTemp = "Student Load Net of NSTP";
				else
					strTemp = "Student Load with NSTP";
			%>
			
			<tr><td align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
				<%=strTemp%><br><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> 
				<%=WI.fillTextValue("sy_from")%><%=WI.getStrValue(WI.fillTextValue("sy_to"),"-","","")%>
			</td></tr>	
			<tr><td height="15">&nbsp;</td></tr>			
  	</table>
	
	
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="30%" valign="bottom" height="18" class="thinborder" align="center"><strong>Course Code</strong></td>
			<td width="10%" valign="bottom" class="thinborder" align="center">1st Year</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">2nd Year</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">3rd Year</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">4th Year</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">5th Year</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">Total Units Load</td>
			<td width="10%" valign="bottom" class="thinborder" align="center">Total Students Enrolled</td>
		</tr>
		
	<%
	int iIndexOf = 0;
	double dYear1 = 0d;
	String strYear1 = null;
	String strYear2 = null;
	String strYear3 = null;
	String strYear4 = null;
	String strYear5 = null;
	String strCollegeName = null;
	String strCourseName = null;
	String strTotalUnitLoad = null;
	String strTotalStudEnrollend = null;
	boolean bolDisplayData = false;
	String strPrevCourseName = "";
	
	double dSubTotUnitLoad = 0d;
	int iSubTotStudEnrl = 0;
	
	double dGrandTotUnitLoad = 0d;
	int iGrandTotStudEnrl = 0;
	//System.out.println(vRetResult);
	for(int i = 0; i < vCollegeName.size(); i++){
		dSubTotUnitLoad = 0d;
		iSubTotStudEnrl = 0;
			
			strYear1 = null;
			strYear2 = null;
			strYear3 = null;
			strYear4 = null;
			strYear5 = null;
	%>
		<tr><td colspan="8" class="thinborder" height="20"><strong><%=vCollegeName.elementAt(i)%></strong></td></tr>
		
		<%
		for(int x = 0; x < vRetResult.size(); x+=5){			
			if(!((String)vRetResult.elementAt(x)).equals((String)vCollegeName.elementAt(i)))
				continue;
			
			strCollegeName = (String)vRetResult.elementAt(x);			
			strCourseName = (String)vRetResult.elementAt(x+1);
			
			
			
			strTemp = (String)vRetResult.elementAt(x+2);//YEAR_LEVEL
				
			if(strTemp != null && strTemp.equals("1"))
				dYear1 += Double.parseDouble((String)vRetResult.elementAt(x+3));				
			if(strTemp != null && strTemp.equals("2"))
				strYear2 = (String)vRetResult.elementAt(x+3);//unit_enrolled
			if(strTemp != null && strTemp.equals("3"))
				strYear3 = (String)vRetResult.elementAt(x+3);//unit_enrolled
			if(strTemp != null && strTemp.equals("4"))
				strYear4 = (String)vRetResult.elementAt(x+3);//unit_enrolled
			if(strTemp != null && strTemp.equals("5"))
				strYear5 = (String)vRetResult.elementAt(x+3);//unit_enrolled				
			
			strYear1 = Double.toString(dYear1);//unit_enrolled	
			
			iIndexOf = x + 6;
			if(iIndexOf > vRetResult.size())
				iIndexOf = iIndexOf - 6;
			
			strPrevCourseName = (String)vRetResult.elementAt(iIndexOf);
			
			
			if(!strPrevCourseName.equals(strCourseName))
				bolDisplayData = true;
			else
				bolDisplayData = false;			
				
			if(bolDisplayData){				
				bolDisplayData = false;
		%>
		<tr>
			<td class="thinborder" style="text-indent:20px;"><%=WI.getStrValue(strCourseName,"&nbsp;")%></td>			
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strYear1,false),"-")%></td>
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strYear2,false),"-")%></td>
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strYear3,false),"-")%></td>
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strYear4,false),"-")%></td>
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strYear5,false),"-")%></td>
			<%
				strTotalUnitLoad = null;
				strTotalStudEnrollend = null;
				
				strTemp = (String)vCollegeName.elementAt(i)+"-"+strCourseName;
				iIndexOf = vTotalUnitsStud.indexOf(strTemp);				
				if(iIndexOf > -1){
					strTotalUnitLoad = (String)vTotalUnitsStud.elementAt(iIndexOf+3);
					strTotalStudEnrollend = (String)vTotalUnitsStud.elementAt(iIndexOf+4);
				}
				
			%>
			<td align="right" class="thinborder"><%=WI.getStrValue(CommonUtil.formatFloat(strTotalUnitLoad,false),"-")%></td>
			<td align="right" class="thinborder"><%=WI.getStrValue(strTotalStudEnrollend,"-")%></td>
		</tr>
		<%
		
			if(strTotalUnitLoad.indexOf("-") > -1)
				strTotalUnitLoad = "0.0";
			if(strTotalStudEnrollend.indexOf("-") > -1)
				strTotalStudEnrollend = "0.0";
				
			dSubTotUnitLoad += Double.parseDouble(strTotalUnitLoad);
			iSubTotStudEnrl += Integer.parseInt(strTotalStudEnrollend);
			
			dGrandTotUnitLoad += Double.parseDouble(strTotalUnitLoad);
			iGrandTotStudEnrl += Integer.parseInt(strTotalStudEnrollend);
			
			
			strYear1 = null;
			strYear2 = null;
			strYear3 = null;
			strYear4 = null;
			strYear5 = null;
			
			dYear1 = 0d;	
		}
		}%>
		
		
		
		
		
		<tr>
			<td class="thinborder" align="right"><strong>Total <%=strCollegeName%> </strong>&nbsp; </td>
			<%
				strTemp = strCollegeName+"-1";
				iIndexOf = vTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
				strYear1 = (String)vTotalCount.elementAt(iIndexOf + 3);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear1,false),"-")%></strong></td>
			<%
				strTemp = strCollegeName+"-2";
				iIndexOf = vTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
				strYear2 = (String)vTotalCount.elementAt(iIndexOf + 3);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear2,false),"-")%></strong></td>
			<%
				strTemp = strCollegeName+"-3";
				iIndexOf = vTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
				strYear3 = (String)vTotalCount.elementAt(iIndexOf + 3);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear3,false),"-")%></strong></td>
			<%
				strTemp = strCollegeName+"-4";
				iIndexOf = vTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
				strYear4 = (String)vTotalCount.elementAt(iIndexOf + 3);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear4,false),"-")%></strong></td>
			<%
				strTemp = strCollegeName+"-5";
				iIndexOf = vTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
				strYear5 = (String)vTotalCount.elementAt(iIndexOf + 3);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear5,false),"-")%></strong></td>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dSubTotUnitLoad,false),"-")%></strong></td>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(Integer.toString(iSubTotStudEnrl),false),"-")%></strong></td>
		</tr>
	<%}%>
	
		<tr>
			<td height="18" class="thinborder" align="right"><strong>GRAND TOTAL</strong></td>
			<%
				strTemp = "1grand";
				iIndexOf = vGrandTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
					strYear1 = (String)vGrandTotalCount.elementAt(iIndexOf + 1);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear1,false),"-")%></strong></td>
			<%
				strTemp = "2grand";
				iIndexOf = vGrandTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
					strYear2 = (String)vGrandTotalCount.elementAt(iIndexOf + 1);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear2,false),"-")%></strong></td>
			<%
				strTemp = "3grand";
				iIndexOf = vGrandTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
					strYear3 = (String)vGrandTotalCount.elementAt(iIndexOf + 1);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear3,false),"-")%></strong></td>
			<%
				strTemp = "4grand";
				iIndexOf = vGrandTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
					strYear4 = (String)vGrandTotalCount.elementAt(iIndexOf + 1);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear4,false),"-")%></strong></td>
			<%
				strTemp = "5grand";
				iIndexOf = vGrandTotalCount.indexOf(strTemp);
				if(iIndexOf > -1)
					strYear5 = (String)vGrandTotalCount.elementAt(iIndexOf + 1);
			%>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strYear5,false),"-")%></strong></td>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dGrandTotUnitLoad,false),"-")%></strong></td>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(iGrandTotStudEnrl,false),"-")%></strong></td>
		</tr>
		
		<tr>
			<td height="18" class="thinborder" align="right"><strong>Total Student</strong> </td>
			<td class="thinborder" align="right" colspan="2"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strGrandTotStudCount,false),"-")%></strong></td>
			<td class="thinborder" colspan="6">&nbsp;</td>
		</tr> 
		<tr>
			<td height="18" class="thinborder" align="right"><strong>ETEEAP</strong> &nbsp; </td>
			<td class="thinborder" align="right" colspan="2"><strong><%=WI.getStrValue(CommonUtil.formatFloat(strGrandTotETEEAP,false),"-")%></strong></td>
			<td class="thinborder" colspan="6">&nbsp;</td>
		</tr>
		<tr>
			<%
			double dTotalAll = Double.parseDouble(strGrandTotStudCount)+Double.parseDouble(strGrandTotETEEAP);
			%>
			<td height="18" class="thinborder" align="right" colspan="2"><strong>TOTAL</strong> &nbsp; </td>
			<td class="thinborder" align="right"><strong><%=WI.getStrValue(CommonUtil.formatFloat(dTotalAll,false),"-")%></strong></td>
			<td class="thinborder" colspan="6">&nbsp;</td>
		</tr>
	</table>

		
<%}%>
	
	
	
  
  
  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>