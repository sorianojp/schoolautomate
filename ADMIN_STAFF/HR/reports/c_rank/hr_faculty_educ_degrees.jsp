<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Educational Degrees</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}
	td {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
a:link {
	text-decoration: none;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{

	document.getElementById("main_header").deleteRow(0);
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);
	document.getElementById("header").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);
	document.getElementById("footer").deleteRow(0);	
	
	window.print();
//	document.form_.print_page.value="1";
//	this.SubmitOnce("form_");	
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

</script>

<body marginheight="0" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	if (WI.fillTextValue("print_page").equals("1")){ 
	%>
	<jsp:forward page="./hr_faculty_educ_degrees_print.jsp" />
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_faculty_educ_degrees.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Executive Management System","ENROLLMENT",request.getRemoteAddr(),
														null);
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getFacultyEducationalDegrees(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
}

	

//System.out.println(vRetResult);

%>
<form action="./hr_faculty_educ_degrees.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="main_header">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4" align="center"><strong>:::: 
        FACULTY EDUCATIONAL DEGREES ::::</strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="header">
    <tr> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
	    <td colspan="3">
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("is_ntp"), "0");
				if(strTemp.equals("0")){
					strTemp = "checked";
					strErrMsg = "";
				}
				else{
					strTemp = "";
					strErrMsg = "checked";
				}
			%>
			<input type="radio" name="is_ntp" value="0" <%=strTemp%>>Display NTP only
			<input type="radio" name="is_ntp" value="1" <%=strErrMsg%>>Display Faculty Summary Education Degrees Only
			</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%" class="fontsize11">Academic Year / Term </td>
      <td width="32%">&nbsp;
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 	  
	  
<select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		    if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (false){
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
      </select></td>
      <td width="46%"><a href="javascript:showList()"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
   <tr>
     <td  colspan="4">&nbsp;</td>
   </tr>
  </table>
  
 <% if (vRetResult != null && vRetResult.size() > 1) {
 	
	Vector vRanks = (Vector)vRetResult.elementAt(0);
	
	int iNumRanks = vRanks.size();
	int[] iColTotals = new int[iNumRanks*2];
	int iIndex = 0;
	int iTotalFullTime = 0;
	int iTotalPartTime = 0;
	
	for (int iNit = 0; iNit < iColTotals.length ; iNit++)
		iColTotals[iNit] = 0;
		
	int iRank = 0;
	int iRowTotals = 0; 
	String[] astrSemester={"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	if (strSchCode.startsWith("AUF"))
		iNumRanks--;
	
%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
     <td><div align="center"><strong><font size="3">Faculty Educational Degrees </font></strong></div></td>
   </tr>
   <% 
		if (WI.fillTextValue("semester").equals("0"))
			strTemp = astrSemester[0] + ", "  + WI.fillTextValue("sy_to");
		else
			strTemp = astrSemester[Integer.parseInt(WI.fillTextValue("semester"))] + 
						", A.Y. "  + WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to");
	%>
   <tr>
     <td><div align="center"><strong>(<%=strTemp%>)</strong></div></td>
   </tr>
   <tr>
     <td>&nbsp;</td>
   </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr>
     <td width="22%" rowspan="2" align="center" class="thinborder"><strong><font size="2">COLLEGE</font></strong></td>
     <% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %>
     <td colspan="2" align="center" class="thinborder"><strong><%=(String)vRanks.elementAt(iIndex)%></strong></td>
     <%} 
	  	if (strSchCode.startsWith("AUF")) { 
	  %>
     <td colspan="2" align="center" class="thinborder"><strong><%=(String)vRanks.elementAt(iIndex)%></strong></td>
     <%}%>
     <td width="10%" align="center" class="thinborder"><strong>TOTAL </strong></td>
   </tr>
   <tr>
     <% for (iIndex = 0; iIndex < iNumRanks ; iIndex++){ %>
     <td width="10%" class="thinborder" ><div align="center">Full-Time</div></td>
     <td width="10%" class="thinborder" ><div align="center">Part-Time</div></td>
     <%}
	  	if (strSchCode.startsWith("AUF")) { 
	  %>
     <td width="10%" class="thinborder" ><div align="center">Full-Time</div></td>
     <td width="10%" class="thinborder" ><div align="center">Part-Time</div></td>
     <%}%>
     <td width="10%" class="thinborder" >&nbsp;</td>
   </tr>
   <% 
	boolean bolIncremented = false;
	String strCurrentCollege = null;
	Vector vDocLawyers = (Vector)vRetResult.elementAt(1);
	
	int k = 0; // index for the lawyers and dcotrs.. 
	
	for (int i = 2; i<vRetResult.size(); ) {
		
		strCurrentCollege = (String)vRetResult.elementAt(i);
		iRank = 0; 
		bolIncremented = false;
		iRowTotals = 0;
%>
   <tr>
     <td class="thinborder">&nbsp;<%=strCurrentCollege%></td>
     <% for (iRank = 0 ;  iRank < iNumRanks; iRank++) {
	  
	 	if (i < vRetResult.size()
			&& strCurrentCollege.equals(WI.getStrValue(vRetResult.elementAt(i)))
			&& (WI.getStrValue(vRetResult.elementAt(i+2))).equals("1")
			&& (WI.getStrValue(vRetResult.elementAt(i+1))).equals((String)vRanks.elementAt(iRank))) { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			i += 4; bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
     <td class="thinborder"><div align="center"><%=strTemp%></div></td>
     <%if (i < vRetResult.size()
			&& strCurrentCollege.equals((String)vRetResult.elementAt(i))
			&& ((String)vRetResult.elementAt(i+2)).equals("0")
			&& ((String)vRetResult.elementAt(i+1)).equals((String)vRanks.elementAt(iRank)))  { 
			
			strTemp = (String)vRetResult.elementAt(i+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));
			iColTotals[iRank*2+1] += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"0"));			
			i += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
     <td class="thinborder"><div align="center"><%=strTemp%></div></td>
     <%
	  } // for loop irank
	  if (strSchCode.startsWith("AUF")) {
		if (k < vDocLawyers.size()
			&& strCurrentCollege.equals((String)vDocLawyers.elementAt(k))
			&& ((String)vDocLawyers.elementAt(k+2)).equals("1")){
//			&& ((String)vDocLawyers.elementAt(i+1)).equals((String)vRanks.elementAt(iRank))

			strTemp = (String)vDocLawyers.elementAt(k+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));
			iColTotals[iRank*2] += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));	
					
			k += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
	  %>
     <td width="10%" class="thinborder" ><div align="center"><%=strTemp%></div></td>
     <%
			if (k < vDocLawyers.size()
			&& strCurrentCollege.equals((String)vDocLawyers.elementAt(k))
			&& ((String)vDocLawyers.elementAt(k+2)).equals("0")){
//			&& ((String)vDocLawyers.elementAt(i+1)).equals((String)vRanks.elementAt(iRank))

			strTemp = (String)vDocLawyers.elementAt(k+3);
			iRowTotals += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));
			iColTotals[iRank*2+1] += Integer.parseInt(WI.getStrValue((String)vDocLawyers.elementAt(k+3),"0"));			
			k += 4;  bolIncremented = true; 
		}else{
			strTemp = "-";
		}
		
	   %>
     <td width="10%" class="thinborder" ><div align="center"><%=strTemp%></div></td>
	<% } // end do not show for other schools%>
     <td class="thinborder"><div align="center"><%=iRowTotals%></div></td>
   </tr>
   <%
	if (!bolIncremented){ // infinite loop
		break;
	}
  } // for loop i = 1
%>
   <tr>
     <td height="25" class="thinborder">&nbsp;&nbsp;&nbsp;&nbsp;TOTAL</td>
     <% 
	  iRowTotals = 0; 
	  for (iRank = 0 ;  iRank < iNumRanks; iRank++) {
	  	iRowTotals += iColTotals[iRank*2] + iColTotals[iRank*2+1];
		iTotalFullTime += iColTotals[iRank*2];
		iTotalPartTime += iColTotals[iRank*2+1];
	  %>
     <td align="center" class="thinborder"><%=iColTotals[iRank*2]%></td>
     <td align="center" class="thinborder"><%=iColTotals[iRank*2+1]%></td>
     <%}
	  	if (strSchCode.startsWith("AUF")) {
		iRowTotals += iColTotals[iRank*2] + iColTotals[iRank*2+1];
		iTotalFullTime += iColTotals[iRank*2];
		iTotalPartTime += iColTotals[iRank*2+1];
	  %>
     <td align="center" class="thinborder"><%=iColTotals[iRank*2]%></td>
     <td align="center" class="thinborder"><%=iColTotals[iRank*2+1]%></td>
     <%}%>
     <td align="center" class="thinborder"><%=iRowTotals%></td>
   </tr>
 </table>
<% if (strSchCode.startsWith("AUF")) {%> 
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td width="5%">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
  	<td width="35%">
		Total Full Time Employees </td>
    <td width="8%">&nbsp;</td>
    <td>&nbsp;</td>
    <td width="37%">Combined Full time &amp; Part Time Employees </td>
    <td width="8%">&nbsp;</td>
    <td width="7%">&nbsp;</td>
  </tr>
  <tr>
    <td>Percentage of BS Degree Holder </td>	
    <td align="right"> <strong> <%=CommonUtil.formatFloat(((double)iColTotals[0]/
									(double)iTotalFullTime)*100d,true)%> </strong></td>
    <td>&nbsp;</td>
    <td>Percentage of BS Degree Holder </td>
    <td align="right"> <strong> <%=CommonUtil.formatFloat(((double)(iColTotals[0]+iColTotals[1])/
								(double)(iTotalFullTime + iTotalPartTime))*100d,true)%> </strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>Percentage of MA/MS Holder </td>
    <td align="right"> <strong> <%=CommonUtil.formatFloat((
				(double)(iColTotals[2]+iColTotals[6])/(double)iTotalFullTime)*100d,true)%> </strong></td>
    <td>&nbsp;</td>
    <td>Percentage of MA/MS Degree Holder </td>
    <td align="right"> <strong> <%=CommonUtil.formatFloat((
					(double)(iColTotals[2]+iColTotals[3]+iColTotals[6]+iColTotals[7])/
					(double)(iTotalFullTime + iTotalPartTime))*100d,true)%> </strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>Percentage of Ph.D. Holder </td>
    <td align="right"> <strong> <%=CommonUtil.formatFloat(((double)iColTotals[4]/
							(double)iTotalFullTime)*100d,true)%> </strong></td>
    <td>&nbsp;</td>
    <td>Percentage of Ph.D Degree Holder </td>
    <td align="right"> <strong> <%=CommonUtil.formatFloat(((double)(iColTotals[4]+iColTotals[5])/
							(double)(iTotalFullTime + iTotalPartTime))*100d,true)%> </strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>Percentage of Combined MA/PhD Holder </td>
    <td align="right"> 
				<strong> 
					<%=CommonUtil.formatFloat(((double)(iColTotals[2]+iColTotals[4]+iColTotals[6])/
							(double)iTotalFullTime)*100d,true)%></strong>
	</td>
    <td>&nbsp;</td>
    <td>Percentage of Combined MA/Ph.D holder </td>
    <td align="right">&nbsp; <strong> 
	  <%=CommonUtil.formatFloat(((double)(iColTotals[2]+iColTotals[4]+iColTotals[6]+
											iColTotals[3]+iColTotals[5]+iColTotals[7])/
			(double)(iTotalFullTime + iTotalPartTime))*100d,true)%> </strong></td>
    <td>&nbsp;</td>
  </tr>
  </table>
 <%}
 } // show only percentage if AUF 
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>	
	<% if (vRetResult != null && vRetResult.size() > 1) { %> 
    <tr>
      <td height="25"><div align="center"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a><font size="1">click to print report</font> </div></td>
    </tr>
	<%}%> 

  </table>
  <input type="hidden" name="print_page" value="0">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>