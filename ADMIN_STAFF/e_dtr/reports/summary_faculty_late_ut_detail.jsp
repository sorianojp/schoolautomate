<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Late Time In Detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

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

-->
</style>

<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrintPage()
{
	document.getElementById("footer_").deleteRow(0);
	window.print();
}

</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%

	WebInterface WI = new WebInterface(request);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");

if( WI.fillTextValue("print_page").compareTo("1") ==0)
{   
%>
	<jsp:forward page="./summary_emp_late_timein_detail_print.jsp" />
<% return;}


	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Staff-eDaily Time Record-Statistics & Reports-Summary of Employees with Late Time-in Record","summary_emp_late_timein.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}								
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_late_timein.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);
Vector vRetResult  = null;

if (WI.fillTextValue("viewRecords").compareTo("1") == 0){
	vRetResult = RE.searchLateAndUndertime(dbOP);	
	if (vRetResult == null || vRetResult.size() == 0){
		strErrMsg = RE.getErrMsg();
	}
	
}

String[] astrMonth = {"","January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};

%>
<form action="./summary_emp_late_timein_detail.jsp" name="dtr_op" method="post">
<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","&nbsp;")%>
<% if (vRetResult !=null){ 
	enrollment.Authentication authentication = new enrollment.Authentication();
    Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	strTemp = WI.fillTextValue("emp_id");

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td></td>
    </tr>
    <tr>
      <td><table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  
  <%if(vRetResult != null && vRetResult.size() > 0 ) { %>
  
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#ECF3FB"> 
 <% 
  	strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date");
	
	 if (WI.fillTextValue("month").length() > 0) {
	 	strTemp = astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("month"),"0"))];
		
		strTemp += " " + WI.fillTextValue("year");
	 }
%>
      <td height="25"  colspan="4" align="center" class="thinborder"><strong>DETAIL 
      OF FACULTY LATE/UNDERTIME (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="22%" height="20" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>DATE</strong></td>
      <td width="29%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>LATE (min) </strong></td>
      <td width="29%" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>UNDERTIME (min) </strong></td>      
    </tr>
<%  
	System.out.println("\n vRetResult.size(): " + vRetResult.size());
	for ( int i = 0 ; i< vRetResult.size(); i+=4){  	
%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>      
    </tr>
    <%} // end for loop%>
  </table>
  <%}%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="31%" height="18">&nbsp;</td>
      <td width="19%">&nbsp;</td>
      <td width="41%">&nbsp;</td>
      <td width="9%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="footer_" >
    <tr valign="bottom"> 
      <td align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click to print list </td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_only_total" value="">  
  <input type="hidden" name="from_date" value="<%=WI.fillTextValue("from_date")%>">
  <input type="hidden" name="to_date" value="<%=WI.fillTextValue("to_date")%>">
  <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  <input type="hidden" name="show_only_deduct" 
  									value="<%=WI.fillTextValue("show_only_deduct")%>">
  <input type="hidden" name="month" 
  									value="<%=WI.fillTextValue("month")%>">
  <input type="hidden" name="year" 
  									value="<%=WI.fillTextValue("year")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>