<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cashier_report_summary.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"scholarship_details.jsp");
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

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();
if(WI.fillTextValue("show_basic").equals("1"))
	feeEx.setBasic(true);
Vector vRetResult = feeEx.getScholarshipDetail(dbOP, request);
if(vRetResult == null)
	strErrMsg = feeEx.getErrMsg();

%>

<form name="form_" method="post" action="./scholarship_details.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOLARSHIP SUMMARY REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="20%" height="25">School year /Term</td>
      <td height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF")){
strTemp = WI.fillTextValue("show_basic");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>   <tr>
      <td height="25">&nbsp;</td>
      <td height="25">
	  <input type="radio" name="show_basic" value="1" <%=strTemp%>> Show Grade School 
	  </td>
      <td height="25">
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else
	strTemp = "";
%>
	  	  <input type="radio" name="show_basic" value="0" <%=strTemp%>> Show College 
	  </td>
      <td height="25">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">
	  <input type="checkbox" name="cleanup" value="1">
        <font color="#0000FF"><strong>Recompute ?(it will slow down the process)
        </strong></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="image" src="../../../images/refresh.gif">
      </td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="3"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="3"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="3" valign="top"><div align="center"><strong>SUMMARY
          OF SCHOLARSHIP GRANTS AND DISCOUNTS<br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td width="35%" height="24" align="right">Date and time printed : </td>
      <td width="23%" height="24">&nbsp;<%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="7">&nbsp;</td>
    </tr>
    <tr> 
      <td width="6%" height="24"><div align="center"><strong><font size="1">NOS</font></strong></div></td>
      <td width="33%"><strong><font size="1">NAME</font></strong></td>
      <td width="10%"><strong><font size="1">COURSE</font></strong></td>
      <td width="14%"><div align="center"><strong><font size="1">KIND</font></strong></div></td>
      <td width="9%"><div align="left"><strong><font size="1">PECENTAGE</font></strong></div></td>
      <td width="17%"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="11%"><div align="center"><strong><font size="1">TOTAL</font></strong></div></td>
    </tr>
<%
double dTempDiscount = 0d; double dDiscPerCatg = 0d;
double dTotalDisc    = 0d;
int iStudCount       = 0; String strGrantName = null;
String[] astrConvertDiscUnit = {" (amt)",""," (unit)"};
for(int i = 0; i < vRetResult.size(); i += 6) {
if(vRetResult.elementAt(i + 2) != null)
	strGrantName = (String)vRetResult.elementAt(i + 2);//System.out.println(vRetResult);
	dTempDiscount = ((Double)vRetResult.elementAt(i + 3)).doubleValue();
	dTotalDisc    += dTempDiscount;
	dDiscPerCatg  += dTempDiscount;
	%>
   <tr>
      <td height="24">&nbsp;<%=++iStudCount%></td>
      <td><%=(String)vRetResult.elementAt(i)%></td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=strGrantName%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)+astrConvertDiscUnit[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td><%=CommonUtil.formatFloat(dTempDiscount,true)%></td>
      <td align="right"><%if( vRetResult.size() - 6 == i || (vRetResult.size() - 7) >= i && vRetResult.elementAt(i + 2 + 6) != null){%>
	  	<u><%=CommonUtil.formatFloat(dDiscPerCatg,true)%></u>
	  <%dDiscPerCatg = 0d;iStudCount = 0;}%></td>
    </tr>
<%if(dDiscPerCatg ==0d){%>
   <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%}%>
    </tr>
<%}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="24" colspan="2" class="thinborderTOP"><div align="right"><strong>T 
          O T A L&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong></div>
        <div align="right"></div></td>
      <td width="19%" class="thinborderTOP"><div align="right"><strong><u><%=CommonUtil.formatFloat(dTotalDisc,true)%></u></strong></div></td>
    </tr>
    <tr> 
      <%//System.out.println(request.getSession(false).getAttribute("userId"));
	//System.out.println(CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1));%>
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24"><div align="center">Prepared By : </div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
