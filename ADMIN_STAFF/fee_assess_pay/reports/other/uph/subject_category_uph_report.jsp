<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
   	document.getElementById('myADTable2').deleteRow(0);
	
   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {
	document.form_.show_list.value='';
	document.form_.submit();
}
function DeleteProj() {
	document.form_.delete_proj.value='1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","subject_category_uph_report.jsp");
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
														"subject_category_uph_report.jsp");
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

Vector vRetResult = null;
ReportFeeAssessment rfa = new ReportFeeAssessment();

if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = rfa.generateRevenueReportUPHPerSubjectType(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rfa.getErrMsg();
	else	
		vRetResult.remove(0);	///not used.. 
}

%>

<form name="form_" method="post" action="./subject_category_uph_report.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          INCOME PER SUBJECT CATEGORY ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="12%" height="25">SY/Term</td>
      <td height="25" colspan="2"> 
<%
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
    
    
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
		<input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1'">	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong><%=WI.fillTextValue("nstp_val")%> INCOME  REPORT PER CATEGORY <br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td height="24" align="right">Date and time printed : &nbsp;<%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr align="center" style="font-weight:bold">
      <td width="3%" style="font-size:9px;" align="left" class="thinborder">Count</td> 
      <td width="14%" height="24" style="font-size:9px;" align="left" class="thinborder">Course Code</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Year Level </td>
      <td width="15%" style="font-size:9px;" class="thinborder">Computer Lec </td>
      <td width="15%" style="font-size:9px;" class="thinborder">Computer Lab </td>
      <td width="15%" style="font-size:9px;" class="thinborder">RLE</td>
	  <td width="15%" style="font-size:9px;" class="thinborder">Internship </td>
      <td width="15%" style="font-size:9px;" class="thinborder">Total Fee </td>
    </tr>
	<%
	int iCount = 0;
	double dCompLec    = 0d; double dTotalCompLec    = 0d;
	double dCompLab    = 0d; double dTotalCompLab    = 0d;
	double dRLE        = 0d; double dTotalRLE        = 0d;
	double dInternship = 0d; double dTotalInternship = 0d;
	while(vRetResult.size() > 0) {
		dCompLec    = 0d;
		dCompLab    = 0d;
		dRLE        = 0d;
		dInternship = 0d;
	%>
    <tr align="right">
      <td align="left" class="thinborder"><%=++iCount%>.</td> 
      <td height="24" align="left" class="thinborder"><%=vRetResult.elementAt(0)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(1)%></td>
      <%
		strTemp = (String)vRetResult.elementAt(2); 
		while(true) {
			if(!vRetResult.elementAt(2).equals(strTemp))
				break;
			if(vRetResult.elementAt(3).equals("0"))
				dCompLec += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(4), ",",""));
			else if(vRetResult.elementAt(3).equals("1"))
				dCompLab += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(4), ",",""));
			else if(vRetResult.elementAt(3).equals("2"))
				dRLE     += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(4), ",",""));
			else if(vRetResult.elementAt(3).equals("3"))
				dInternship += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(4), ",",""));
			
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			if(vRetResult.size() == 0)
				break;	
		}
		dTotalCompLec    += dCompLec;
		dTotalCompLab    += dCompLab;
		dTotalRLE        += dRLE;
		dTotalInternship += dInternship;
	  %>	  
	  
	  <td class="thinborder"><%=CommonUtil.formatFloat(dCompLec, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dCompLab, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dRLE, true)%></td>
	  <td class="thinborder"><%=CommonUtil.formatFloat(dInternship, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dCompLec+dCompLab+dRLE+dInternship, true)%></td>
    </tr>
	<%}%>
    <tr align="right" style="font-weight:bold">
      <td align="left" class="thinborder">&nbsp;</td>
      <td height="24" align="left" class="thinborder">TOTAL : </td>
      <td align="left" class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCompLec, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCompLab, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalRLE, true)%></td>
	      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalInternship, true)%></td>
          <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCompLec+dTotalCompLab+dTotalRLE+dTotalInternship, true)%></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
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
<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
