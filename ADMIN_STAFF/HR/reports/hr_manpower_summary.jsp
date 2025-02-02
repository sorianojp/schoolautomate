<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style>

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
	
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	window.print();
}
</script>

<body marginheight="0" >
<%@ page language="java" import="utility.*,java.util.Date, java.util.Vector,hr.HRStatsReports" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Manpower Grand Total","hr_manpower_summary.jsp");

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

	vRetResult = hrStat.manpowerStatsSummary(dbOP);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
		


%>
<form action="hr_educ_reports.jsp" method="post" name="form_" >
<% if (strErrMsg != null) {%>
&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
	  <td height="25" colspan="4" bgcolor="#FFFFFF" align="center"><p><font size="2"><strong>
	  	  <%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
          <br>
          <strong>HUMAN RESOURCE DEPARTMENT</strong></font></p></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#FFFFFF"><div align="center"> <strong>MANPOWER 
          GRAND TOTAL AS OF <%=WI.formatDate((Date)null,10).toUpperCase()%></strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult.size() > 1)  {
	Vector vTemp = (Vector)vRetResult.elementAt(0);
	int iNumFTStatus = vTemp.size();
	
%> 
  <table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
    <tr>
      <td width="15%" height="30" class="thinborder">&nbsp;</td>
	  <% for (int k = 0; k < iNumFTStatus;k++){
	  
	  	//strTemp = "FT" + ((String)vTemp.elementAt(k)).charAt(0);
		strTemp = "FT <br> " + ((String)vTemp.elementAt(k));
	  %>
      <td align="center" class="thinborder">
	  	<strong><%=strTemp%></strong>	  </td>
	  <%}
	  
	  	if (strSchCode.startsWith("AUF")) 
			strTemp = "PT(OUT)";
		else
			strTemp = "PT";
	  
	  %> 
      
	  
	  <td width="8%" align="center" class="thinborder"><strong><%=strTemp%></strong></td>
      <% if(strSchCode.startsWith("AUF")){%> 	  
	  <td width="8%" align="center" class="thinborder"><strong>PT(CON)</strong></td>	  
      <td width="12%" align="center" class="thinborder"><strong>CONSULTANT</strong></td>
      <td width="14%" align="center" class="thinborder">
	  			<font size="1"><strong>TOTAL W/ CON </strong></font>	   </td>
	  <%} // show only for AUf%>	  
      <td width="13%" align="center" class="thinborder">
	  			<strong><font size="1">TOTAL HEAD COUNT </font></strong>	  </td>
    </tr>
    <% 
	
	String strCurrentStatus = null;
	
	int iRowConcurrent = (strSchCode.startsWith("AUF"))?4:1; // temp value.. 
	int[] aiColumnTotal =  new int[iNumFTStatus+iRowConcurrent];

//	int iMaxColumn = 3 + iNumFTStatus - 1;
	
//	System.out.println("iMaxColumn : " + iMaxColumn);
	
	iRowConcurrent = 0; // reset value for conCurrent.. 
	int iRowTotal = 0;
	int iTotalFullTime = 0;
	int iColumn = 0;
	String[] astrTeachingStaff={"NTP","FACULTY"};
	String strIsTeachingStaff = null;
	int  k = 0; 
	
//	System.out.println("vRetResult : " + vRetResult);
					 
%>
    
<%
	boolean bolInfiniteLoop = true;
	for (int i = 1; i < vRetResult.size();) {
	bolInfiniteLoop = true;
	 iRowTotal = 0;
	 iColumn = 0;
	 iRowConcurrent = 0;

	 strIsTeachingStaff = (String)vRetResult.elementAt(i+2);
%>
    <tr>
      <td height="21" class="thinborder">&nbsp;
	  			<%=astrTeachingStaff[Integer.parseInt(WI.getStrValue(strIsTeachingStaff,"0"))]%>		</td>
  <%for (k = 0; k < iNumFTStatus;k++){
  	strTemp = "0";
	
	if( i < vRetResult.size() && 
		strIsTeachingStaff.equals((String)vRetResult.elementAt(i+2)) &&
		((String)vRetResult.elementAt(i)).equals("1") &&
		((String)vTemp.elementAt(k)).equals((String)vRetResult.elementAt(i+1))){

		strTemp = (String)vRetResult.elementAt(i+3);
		iTotalFullTime += Integer.parseInt(strTemp);
		iRowTotal += Integer.parseInt(strTemp);
		aiColumnTotal[iColumn] += Integer.parseInt(strTemp);
		bolInfiniteLoop = false;
		i += 4;		
	}
	 iColumn++;
  %>	  
      <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
  <%}
	strTemp = "0";
	if( i < vRetResult.size() && 
		strIsTeachingStaff.equals((String)vRetResult.elementAt(i+2)) &&
		((String)vRetResult.elementAt(i)).equals("0"))
//		status need not to be check for part time
//		 && ((String)vTemp.elementAt(k)).equals((String)vRetResult.elementAt(i+1))
	{
		strTemp = (String)vRetResult.elementAt(i+3);
		iRowTotal += Integer.parseInt(strTemp);
		aiColumnTotal[iColumn] += Integer.parseInt(strTemp);
		bolInfiniteLoop = false;
		i += 4;		
	}
	 iColumn++;	
  %> 
      <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
<%if (strSchCode.startsWith("AUF")){
	strTemp = "0";
	if( i < vRetResult.size() && 
		strIsTeachingStaff.equals((String)vRetResult.elementAt(i+2)) &&
		((String)vRetResult.elementAt(i)).equals("-1")) 
	{ 
//		 status need to be check for consultants.. 
//		 && ((String)vTemp.elementAt(k)).equals((String)vRetResult.elementAt(i+1)))
		strTemp = (String)vRetResult.elementAt(i+3);
		iRowConcurrent = Integer.parseInt(strTemp);
		aiColumnTotal[iColumn] += Integer.parseInt(strTemp);		
		bolInfiniteLoop = false;
		i += 4;		
	}
	 iColumn++;
%> 
      <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
<%
	strTemp = "0";
	if( i < vRetResult.size() && 
		strIsTeachingStaff.equals((String)vRetResult.elementAt(i+2)) &&
		((String)vRetResult.elementAt(i)).equals("-2")) 
	{ 
//		 status need to be check for consultants.. 
//		 && ((String)vTemp.elementAt(k)).equals((String)vRetResult.elementAt(i+1)))
		strTemp = (String)vRetResult.elementAt(i+3);
		iRowTotal += Integer.parseInt(strTemp);
		aiColumnTotal[iColumn] += Integer.parseInt(strTemp);		
		bolInfiniteLoop = false;
		i += 4;		
	}
	iColumn++;
	aiColumnTotal[iColumn] += iRowTotal + iRowConcurrent; 
%>
      <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
	 
      <td align="center" class="thinborder">&nbsp;<%=iRowTotal + iRowConcurrent%></td>
<%}%> 	  
      <td align="center" class="thinborder">&nbsp;<%=iRowTotal%></td>
    </tr>
    
    <%
	
		if (bolInfiniteLoop){
			System.out.println(" infinite loop: hr_manpower_summary.jsp");
			System.out.println(" i : " + i);
			break;
		}
	
	  } // end for loop
	%>
    <tr style="font-weight:bold">
      <td height="16" class="thinborder">&nbsp;GRAND TOTAL</td>
	  <%
	  	iColumn = 0;
		iRowTotal = 0;
	   for (k = 0; k < iNumFTStatus; ++k) {
		iRowTotal += aiColumnTotal[iColumn];
	   %>
      <td align="center" class="thinborder">&nbsp;<%=aiColumnTotal[iColumn++]%></td>
	  <%
	  	}
		iRowTotal += aiColumnTotal[iColumn];
	  %> 
      <td align="center" class="thinborder">&nbsp;<%=aiColumnTotal[iColumn++]%></td>
	  <%
	  if (strSchCode.startsWith("AUF")) { 

		iRowConcurrent = aiColumnTotal[iColumn];
	  %>
      <td align="center" class="thinborder">&nbsp;<%=aiColumnTotal[iColumn++]%></td>
      <% iRowTotal += aiColumnTotal[iColumn]; %>
	  <td align="center" class="thinborder">&nbsp;<%=aiColumnTotal[iColumn++]%></td>
	  <% //iRowTotal += aiColumnTotal[iColumn]; %>
      <td align="center" class="thinborder">&nbsp;<%=aiColumnTotal[iColumn]%></td>
	  <%} // hide 2 columns for non AUF%> 
      <td align="center" class="thinborder">&nbsp;<%=iRowTotal%></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="1" cellspacing="0">
    <tr>
      <td width="17%" height="16">&nbsp;</td>
      <td width="83%" align="center">&nbsp;</td>
    </tr>

    <tr style="font-weight:bold">
      <td height="16" style="font-size:11px">TOTAL FULL-TIME </td>
      <td  style="font-size:11px">&nbsp;<%=iTotalFullTime%> </td>
    </tr>
  </table>
<%}
  if (vRetResult!= null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">

    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
  </table>
<%}
 }
%>
  
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>