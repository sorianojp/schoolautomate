<%
//include non-employee.. added nov 11, 2014 to include NAS of CIT. 	
request.setAttribute("inc_nonemployee", "1");
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee awol detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript">
function PrintPage(){
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	window.print();
}

</script>
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
	font-size:11px;
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
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strImgFileExt = null;
	String strTemp2 = null;
	String strTemp3  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-STATISTICS & REPORTS-Summary Emp With Absent (Detail)",
								"summary_emp_with_absent_detail.jsp");

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
														"summary_emp_with_absent_detail.jsp");	
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
strTemp = WI.fillTextValue("emp_id");

ReportEDTR rd= new ReportEDTR(request);
enrollment.Authentication authentication = new enrollment.Authentication();
Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
if(vEmpRec == null || vEmpRec.size() ==0)
	strErrMsg = authentication.getErrMsg();


vRetResult = rd.viewEmpAbsenceDetailNew(dbOP,request);
 if (vRetResult == null || vRetResult.size() == 0) 
	strErrMsg = rd.getErrMsg();

String[] astrWeekDays = {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY","SATURDAY","&nbsp;"};
%>

	<%=WI.getStrValue(strErrMsg)%>
<% if (vRetResult !=null && vRetResult.size()>0 && vEmpRec != null && vEmpRec.size() > 0){%>
  <form action="" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>
<div align="center">
          <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></p>
          <table width="400" border="0" align="center">
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
                <%=WI.getStrValue(strTemp3)%><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
                </font> 
              </td>
            </tr>
          </table>
          <br>
        </div>
	</td>
  </tr>
 </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
      <td width="11%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>DATE 
      OF ABSENCE</strong></td>
      <td width="27%" height="25" align="center" bgcolor="#EBEBEB" class="thinborder"><strong>DAY 
      OF ABSENCE</strong></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%>&nbsp;<%=astrWeekDays[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+1),"7"))]%></td>
      <td class="thinborder">&nbsp; (<%=(String)vRetResult.elementAt(i+2)%> hrs)</td>
    </tr>
    <%} // end for loop%>
    <tr> 
      <td height="25" colspan="2" class="thinborder"><strong>TOTAL NUMBER OF ABSENCE(S) 
        : <%=(int)(vRetResult.size() /3)%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" id="footer">
    <tr> 
      <td height="15">&nbsp; </td>
    </tr>
    <tr>
      <td><div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>print 
          employee absence detail </div></td>
    </tr>
  </table>
    <%}%>
    <input type="hidden" name="date_fr" value="<%=WI.fillTextValue("date_fr")%>">
    <input type="hidden" name="date_to" value="<%=WI.fillTextValue("date_to")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>